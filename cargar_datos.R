library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(glue)
library(purrr)


# cargar metadatos ----
metadatos <- read_rds("metadatos/metadata_oportunidades_empleo.rds")


# acargar datos ----
# lista de archivos existentes
archivos <- fs::dir_ls("datos", recurse = TRUE) |> as.character()

# cargar todos los datos disponibles 
datos_simel_crudo <- map(metadatos$id, \(.id) {
  # .id <- metadatos$id[4]
  # .id <- "DF_TOI_CIUO_SEXO"
  # .id <- "DF_FFT_EDU"
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
    clean_names() |> 
    mutate(id = .id)
  
  return(dato)
})


# limpiar ----
datos_simel <- map(datos_simel_crudo, \(dato) {

  if (is.null(dato)) return(NULL)
  
  .id <- first(dato$id)
  .indicador <- first(dato$indicador)
  
  message(paste("limpiando", .id))
  
  # extraer variables de desagregación desde el id
  var_desagregacion <- str_extract(.id, paste0("(?<=", .indicador, ").*")) |> 
    str_remove("^_") |> 
    str_split(pattern = "_") |> 
    unlist() |> 
    tolower()
  
  # var_desagregacion <- c("sexo", "edad", "rama", "tdcon", "area_ref", "ciuo", "ciuo88")
  
  # seleccionar columnas
  dato_2 <- dato |> 
    select(region = area_ref, 
           fecha = time_period, 
           indicador,
           # edad, 
           any_of(var_desagregacion),
           valor = obs_value,
           everything()) |> 
    mutate(grupo = paste0(var_desagregacion, collapse = "+"),
           grupo_l = list(var_desagregacion))
  
  # remover columnas vacías
  dato_3 <- dato_2 |> 
    select(-any_of(c("structure_id", "structure"))) |> 
    remove_empty("cols")
  
  # # si la fecha es solo año
  # if (is.numeric(dato_3$fecha)) {
  #   dato_3 <- dato_3 |> 
  #     rename(año = fecha)
  # }
  
  # tipos
  dato_4 <- dato_3 |> 
    mutate(fecha = as.character(fecha))
  
  # unique(dato_4$region) == "_T"
  
  return(dato_4)
})

# sin datos: DF_NMICI_EDU, DF_TMICI_EDU

datos_simel[[5]]

# unir datos
datos_simel_2 <- datos_simel |> 
  list_rbind() |> 
  select(id, fecha, valor, indicador, grupo, everything())

# extraer variables de desagregación posibles
var_desagregacion <- datos_simel_2$grupo_l |> unlist() |> unique()


# ordenar columnas
datos_simel_3 <- datos_simel_2 |> 
  relocate(any_of(var_desagregacion), .after = grupo)


# guardar ----
datos_simel_3 |>
  arrow::write_parquet("resultados/simel_datos.parquet")
