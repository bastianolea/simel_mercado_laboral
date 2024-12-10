library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(glue)

metadatos <- read_rds("metadatos/metadata_oportunidades_empleo.rds")

metadatos$id

# todos los datos
metadatos |> pull(titulo)

# datos por territorio
metadatos |> 
  filter(str_detect(titulo, "comuna|provincia|municip|regi")) |> 
  select(titulo, id) |> 
  print(n=Inf)


# cargar archivos ----
archivos <- fs::dir_ls("datos", recurse = TRUE) |> as.character()

archivos

datos <- read_csv(archivos[15]) |> 
  janitor::clean_names() |> 
  glimpse()

datos |> 
  select(structure_id, 
         freq, indicador, area_ref)
         
# datos |> 
#   janitor::remove_empty("cols") |> 
#   count(edad)

datos |> 
  select(notas)



metadatos$id

metadatos |> 
  filter(id == "DF_DES_EDAD")

# metadatos de un id
metadatos |> 
  filter(id == metadatos$id[4]) |> 
  glimpse()

# extraer metadatosde un id
dato <- metadatos |> 
  slice(5) |> 
  glimpse()

# ruta al archivo, construida igual como se hace al descargarlo
archivo <- glue("datos/{dato$categoria_id}/simel_{tolower(dato$id)}.csv")
# algunos datos tienen "no records found" (como DF_NMICI_EDU), porque no existen en el sitio (ergo no se descargaron)

read_csv(archivo) |> 
  janitor::clean_names() |> 
  janitor::remove_empty("cols")

read_csv(archivo) |> 
  janitor::clean_names() |> 
  janitor::remove_empty("cols") |> 
  glimpse()

# todos tienen una misma estructura

# variables de desagregación
# sexo
# edad
# rama
# tdcon
# area_ref
# seleccionar con any_of()

# en nombres de archivos
# sexo
# edad
# edu
# rama
# conur
# provincias
# nacion
# ciuo
# tramohora
# cise
# vienen después del tercer guion bajo

# —----

metadatos |> 
  filter(id == "DF_TOBE_EDAD") |> 
  select(titulo, producto, institucion, categoria, fecha) |> 
  glimpse()


