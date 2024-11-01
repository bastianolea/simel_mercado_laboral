


# esperar una cantidad de tiempo aleatoria pero no inferir al valor entregado
esperar <- function(x = 2) {
  x_random <- seq(x*1, x*2.2, by = 0.05) |> sample(1)
  Sys.sleep(x_random)
}

# ejecutar antes de una operación que tome tiempo
cronometro <- function() {
  tiempo_inicio <<- Sys.time()
}

# ejecutar después de la operación que toma tiempo, y espera esa cantidad de tiempo multiplicada por x
cronometro_esperar <- function(mult = 2) {
  tiempo_fin <<- Sys.time()
  duracion <- as.numeric(tiempo_fin - tiempo_inicio)
  message(glue("esperando {round(duracion * mult, 1)} segundos"))
  
  esperar(duracion * mult)
}

# abre un server de selenium para poder iniciar el scraping
# si el puerto está ocupado, usar simel_navegador_cerrar() antes
# output: el objeto remote_driver, que se usa para controlar Selenium
simel_navegador_crear <- function(puerto = 4566L) {
  driver <<- rsDriver(port = puerto, browser = "firefox", chromever = NULL, 
                     extraCapabilities = makeFirefoxProfile(list(browser.download.dir = here()))
  )
  
  remote_driver <<- driver[["client"]]
  return(remote_driver)
}

# controla el navegador para que visite el sitio indicado
simel_visitar <- function(remote_driver, url) {
  remote_driver$navigate(url)
  esperar() 
}

# obtiene todos los enlaces a los datos, como un vector
# input: la primera página con lista de datos (resultado de búsqueda o por apretar una de las categorías en https://de.ine.gob.cl
# output: todos los enlaces a cada uno de los datos entregados por la plataforma en al categoría del enlace provisto
simel_scraping_enlaces_datos <- function(remote_driver, url) {

  # ir al inicio, por si está en otro sitio
  # remote_driver |> simel_visitar(url)
  remote_driver$navigate(url)
  esperar() 
  
  # obter código de fuente del primer sitio
  sitio_enlaces <- remote_driver$getPageSource()
  
  sitio_enlaces_2 <- sitio_enlaces[[1]] |> rvest::read_html()
  
  # obtener cantidad de páginas que hay que avanzar
  n_paginas <- sitio_enlaces_2 |> 
    html_elements(".MuiGrid-container") |> 
    # html_elements(".MuiTypography-root") |> 
    # html_elements(xpath = "/html/body/div[1]/div/div[3]/div/div/div[2]/div[3]/div/div/p[2]") |>
    html_elements(".jss266") |> 
    html_elements(".MuiTypography-body2") |>
    html_text() |> 
    str_flatten() |> 
    str_extract("\\d+") |> 
    as.numeric()
  
  if (is.na(n_paginas)) n_paginas = 1
  message(glue("total de {n_paginas} páginas a scrapear"))
  
  # obtener enlaces por cada página de datos
  enlaces_datos_scraping <- map(1:n_paginas, \(pagina) {
    message(glue("enlaces: obteniendo enlaces en página {pagina}"))
    
    if (pagina > 1) {
      message(glue("cambiando a página {pagina}"))
      # presionar siguiente página
      remote_driver$
        findElement("xpath",
                    "/html/body/div[1]/div/div[3]/div/div/div[2]/div[3]/div/button[3]/span")$
        clickElement()
      
      esperar()
    }
    
    # obtener código de la página
    sitio_enlaces <- remote_driver$getPageSource()
    
    # obtener enlaces de la página
    enlaces_resultados <- sitio_enlaces[[1]] |>
      read_html() |>
      html_elements(".MuiCard-root") |>
      html_elements("a") |>
      html_attr("href")
    
    message(glue("{length(enlaces_resultados)} enlaces encontrados en página {pagina}"))
    
    return(enlaces_resultados)
  })
  
  # vector de enlaces
  enlaces_datos <- paste0("https://de.ine.gob.cl", unlist(enlaces_datos_scraping))
  message(glue("{length(enlaces_datos)} enlaces de datos obtenidos en total"))
  
  # remote_driver <<- remote_driver()
  return(enlaces_datos)
}



# input: vector con enlaces a datos (simel_scraping_enlaces_datos())
# output: dataframe con título del dato, fecha, fuente y otros desde la página de cada dato
simel_scraping_metadatos <- function(remote_driver,
                                     enlaces_datos,
                                     categoria, categoria_id) {
  
  # obtener título del dato, fecha, fuente y otros desde la página de cada dato
  metadatos_scraping <- map(enlaces_datos, \(enlace) {
    # enlace <- enlaces_resultados_paginas_2[10]
    
    # navegar
    message(glue("metadatos: navegando a {enlace}"))
    remote_driver$navigate(enlace); esperar(3)
    
    sitio_dato <- remote_driver$getPageSource()
    
    sitio_dato_2 <- sitio_dato[[1]] |> 
      read_html() |> 
      html_elements("#id_overview_component")
    
    titulo <- sitio_dato_2 |> 
      html_elements("h1") |> 
      html_text()
    
    etiquetas <- sitio_dato_2 |> 
      html_elements(".jss119") |>
      html_text()
    
    texto <- sitio_dato_2 |> 
      html_elements(".MuiTypography-body2") |>
      html_text()
    
    fecha <- texto |> str_subset("(A|a)ctualizaci(o|ó)n") |> str_remove("^\\w+ \\w+: ")
    producto <- texto |> str_subset("(P|p)roducto") |> str_remove("^\\w+: ")
    institucion <- texto |> str_subset("(I|i)nstituci(o|ó)n") |> str_remove("^\\w+: ")
    
    # unir metadatos
    metadatos <- tibble("titulo" = titulo[1],
                        "fecha" = fecha[1],
                        "producto" = producto[1],
                        "institucion" = institucion[1],
                        "enlace" = enlace[1],
                        "categoria" = categoria, 
                        "categoria_id" = categoria_id)
    
    message(" ")
    return(metadatos)
  })
  
  metadatos <- metadatos_scraping |> 
    list_rbind() |> 
    mutate(id = str_extract(enlace, "DF_\\w+")) |> 
    relocate(id, .after = titulo)
  
  return(metadatos)
}

# forma estandarizada de guardar los metadatos con el nombre de la categoría
simel_guardar_metadatos <- function(metadatos, nombre_categoria) {
  archivo <- glue("metadatos/metadata_{nombre_categoria}.rds")
  
  metadatos |> 
    readr::write_rds(archivo) 
  message("guardado ", archivo)
}


# input: vector de IDs de cada dato (simel_scraping_metadatos()$id)
# output: ninguno, pero descarga los datos a la carpeta datos/
simel_descargar_datos <- function(enlaces, carpeta) {
  walk(enlaces, \(id) {
    message(glue("descargando {id}"))
    
    # crear carpeta
    dir.create(path = glue("datos/{carpeta}"), showWarnings = F)
    
    # descargar, con espera
    cronometro()
    download.file(glue("https://sdmx.ine.gob.cl/rest/data/CL01,{id},1.0/all?&format=csvfilewithlabels"),
                  glue("datos/{carpeta}/simel_{tolower(id)}.csv")) |> try()
    cronometro_esperar(5)
  })
}

# cierra el server de selenium para desocupar el puerto
simel_navegador_cerrar <- function(driver) {
  driver$server$stop()
}