library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(glue)

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

# C: cargar de un id, por una búsqueda
.id <- metadatos |>
  select(titulo, id) |> 
  filter(str_detect(titulo, "microemprend")) |> 
  filter(str_detect(titulo, "sexo")) |> 
  mutate(nchar = nchar(titulo)) |> 
  arrange(nchar) |> 
  pull(id) |> 
  first()


# obtener ruta desde el id
archivo_ruta <- archivos |> 
  str_subset(tolower(.id)) |>
  first()
# una alternativa sería constuir la ruta con el id y categoria_id

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

# P3M significa que son trimensuales

dato_2
