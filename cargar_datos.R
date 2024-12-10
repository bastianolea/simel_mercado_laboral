library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(glue)
library(purrr)

# cargar metadatos
metadatos <- read_rds("metadatos/metadata_oportunidades_empleo.rds")

# lista de archivos existentes
archivos <- fs::dir_ls("datos", recurse = TRUE) |> as.character()


# A: cargar un id específico, buscando por id
.id = "DF_TOBE_EDAD"

# B: cargar de un id, por su posición
.id <- metadatos |> 
  slice(5) |> 
  pull(id)


datos_simel <- map(metadatos$id, \(.id) {
  # .id <- metadatos$id[4]
  message(paste("cargando dato", .id))
  
  # obtener ruta desde el id
  archivo_ruta <- archivos |> 
    str_subset(tolower(.id)) |>
    first()
  
  # revisar si existe
  if (is.na(archivo_ruta)) {
    warning(paste("el id", .id, "no tiene archivo"))
    return(NULL)
  } else {
    message(paste("ruta:", archivo_ruta))
  }
  
  # cargar
  dato <- archivo_ruta |> 
    read_csv(show_col_types = F, name_repair = "unique_quiet") |> 
    clean_names()
  
  var_desagregacion <- c("sexo", "edad", "rama", "tdcon", "area_ref")
  
  dato_2 <- dato |> 
    select(region = area_ref, 
           fecha = time_period, 
           # edad, 
           any_of(var_desagregacion),
           valor = obs_value) |> 
    mutate(id = .id)
  
  # si la fecha es solo año
  if (is.numeric(dato_2$fecha)) {
    dato_2 <- dato_2 |> 
      rename(año = fecha)
  }
  
  # P3M significa que son trimensuales
  
  return(dato_2)
})

# sin datos: DF_NMICI_EDU, DF_TMICI_EDU

# unir datos
datos_simel_2 <- datos_simel |> 
  list_rbind() |> 
  select(id, fecha, año, valor, everything())


datos_simel_2 |> 
  readr::write_rds("resultados/simel_datos.rds")

# crear nivel de fecha (año, mes, semestre, etc)
# pivotar grupo a long, una sola columna de grupo
# agregar metadatos?