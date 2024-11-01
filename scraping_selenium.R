library(dplyr)
library(rvest)
library(purrr)
library(tidyr)
library(lubridate)
library(stringr)
library(glue)
library(RSelenium)
library(readr)

source("simel_funciones.R")

# abrir server ----
f_profile <- makeFirefoxProfile(list(browser.download.dir = "~/Documents/Trabajo/Osvaldo Anid Idea/simel/"
                                     # browser.download.folderList = 2L,
                                     # browser.download.manager.showWhenStarting = FALSE,
                                     # browser.helperApps.neverAsk.saveToDisk="text/xml",
                                     # browser.tabs.remote.autostart = FALSE,
                                     # browser.tabs.remote.autostart.2 = FALSE,
                                     # browser.tabs.remote.desktopbehavior = FALSE
))

driver <- rsDriver(port = 4566L, browser = "firefox", chromever = NULL, 
                   extraCapabilities = f_profile)

remote_driver <- driver[["client"]]


# entrar al sitio ----
# página de resultados
url <- "https://de.ine.gob.cl/?fs[0]=Dimensiones%20Trabajo%20Decente%2C0%7COportunidades%20de%20empleo%23OPORTUNIDADES_EMPLEO%23&pg=0&fc=Dimensiones%20Trabajo%20Decente&bp=true&snb=100"

remote_driver$navigate(url); esperar()

# obtener enlaces ----

## obtener enlaces página 1 ----
# sitio_enlaces <- remote_driver$getPageSource()
# 
# # obtener enlaces de resultados
# enlaces_resultados <- sitio_enlaces[[1]] |> 
#   read_html() |> 
#   html_elements(".MuiCard-root") |> 
#   html_elements("a") |> 
#   html_attr("href")
# 
# enlaces_resultados


## obtener todos los enlaces ----
# obtener cantidad de páginas que hay que avanzar

n_paginas <- sitio_enlaces[[1]] |> 
  read_html() |> 
  html_elements(".MuiGrid-container") |> 
  html_elements(".MuiTypography-root") |> 
  html_elements(xpath = "/html/body/div[1]/div/div[3]/div/div/div[2]/div[3]/div/div/p[2]") |>
  html_text() |> 
  str_extract("\\d+") |> 
  as.numeric()

message(glue("total de {n_paginas} páginas a scrapear"))

# obtener enlaces por cada página
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


# obtener metadatos ----
# obtener título del dato, fecha, fuente y otros desde la página de cada dato

# por cada enlace del paso anterior
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
                      "enlace" = enlace[1])
  
  return(metadatos)
})

# obtener ids desde enlaces
metadatos <- metadatos_scraping |> 
  list_rbind() |> 
  mutate(id = str_extract(enlace, "DF_\\w+")) |> 
  relocate(id, .after = titulo)

metadatos


# descargar datos ----

## presionando botones ----
# # navegar a resultado
# url_dato <- paste0("https://de.ine.gob.cl", enlaces_resultados[3])
# 
# remote_driver$navigate(url_dato); esperar()
# 
# # apretar botón "descarga"
# remote_driver$
#   findElement("css selector", 
#               ".jss93 > div:nth-child(2) > span:nth-child(2) > button:nth-child(1) > span:nth-child(1)")$
#   clickElement()
# 
# # apretar descargar
# remote_driver$
#   findElement("xpath", 
#               "/html/body/div[3]/div[3]/ul/a[2]/span")$
#   clickElement()


## desde url ----

# id_datos <- enlaces_resultados |> 
#   str_extract("DF_\\w+")

# https://sdmx.ine.gob.cl/rest/data/CL01,DF_NMICI_EDAD,1.0/all?&format=csvfilewithlabels
# download.file("https://sdmx.ine.gob.cl/rest/data/CL01,DF_NMIC_CISE_EDAD,1.0/all?&format=csvfilewithlabels",
#               "file.csv")

# descargar todos
map(metadatos$id, \(id) {
  message("descargando {id}")
  
  cronometro_iniciar()
  download.file(glue("https://sdmx.ine.gob.cl/rest/data/CL01,{id},1.0/all?&format=csvfilewithlabels"),
                glue("datos/{tolower(id)}.csv")) |> try()
  cronometro_esperar(5)
})


# terminar sesión ----
# remote_driver$close()
# remote_driver$quit()
driver$server$stop()