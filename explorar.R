library(readr)
library(dplyr)
library(stringr)

metadatos <- read_rds("metadatos/metadata_oportunidades_empleo.rds")

metadatos$id

# todos los datos
metadatos |> pull(titulo)

# datos por territorio
metadatos |> 
  filter(str_detect(titulo, "comuna|provincia|municip|regi")) |> 
  pull(titulo)


# cargar archivos ----
archivos <- fs::dir_ls("datos", recurse = TRUE) |> as.character()

archivos

datos <- read_csv(archivos[145]) |> 
  janitor::clean_names() |> 
  glimpse()

datos |> 
  select(structure_id, 
         freq, indicador, area_ref)
         
datos |> 
  janitor::remove_empty("cols") |> 
  count(edad)

datos |> 
  select(notas)




metadatos |> 
  filter(id == "DF_DES_EDAD")



read_csv(archivos[99]) |> 
  janitor::clean_names() |> 
  janitor::remove_empty("cols") |> 
  glimpse()

# todos tienen una misma estructura