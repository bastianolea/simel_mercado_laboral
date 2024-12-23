library(dplyr)
library(arrow)
library(readr)

# desde cargar_datos.R
simel <- arrow::read_parquet("resultados/simel_datos.parquet")

unique(simel$id)

metadatos <- read_rds("metadatos/metadata_oportunidades_empleo.rds")


# determinar grupos de desagregación
simel_2 <- simel |> 
  mutate(total = if_else(region == "_T", TRUE, FALSE)) |> 
  mutate(region = if_else(region == "_T", NA, region)) |> 
  # mutate(grupo = case_when(!is.na(region) & !is.na(sexo) ~ "region+sexo",
  #                          !is.na(region) & !is.na(edad) ~ "region+edad",
  #                          !is.na(region) & !is.na(rama) ~ "region+rama",
  #                          !is.na(sexo) ~ "sexo",
  #                          !is.na(edad) ~ "edad",
  #                          !is.na(rama) ~ "rama",
  #                          !is.na(region) & nchar(region) == 2 ~ "region",
  #                          !is.na(region) & nchar(region) == 3 ~ "provincia"))

simel_2 |> count(region, grupo, sort = T) |> 
  print(n=Inf)

# agregar metadatos
simel_3 <- simel_2 |> 
  relocate(grupo, .after = id) |> 
  left_join(metadatos |> select(titulo, id, institucion),
            by = "id")
  
simel_3 |> 
count(grupo)

metadatos |> slice_sample(n = 1) |> select(titulo, id, producto)

metadatos |> filter(id == "DF_TOI_CIUO_SEXO") 

simel_3 |> 
  filter(id == "DF_TOI_CIUO_SEXO")


metadatos |> filter(id == "DF_OCUCIUO_CIUO88_EDAD")

simel_3 |> 
  filter(id == "DF_OCUCIUO_CIUO88_EDAD")
