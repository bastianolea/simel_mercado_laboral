library(jsonlite)
library(dplyr)

library(rjson)

# url <- "https://sdmx.ine.gob.cl/rest/data/CL01,DF_NMICI_SEXO,1.0/A...?dimensionAtObservation=AllDimensions"
url <- "https://sdmx.ine.gob.cl/rest/data/CL01,DF_NMICI_SEXO,1.0/A..."

json <- jsonlite::fromJSON(url)

json$dataSets |> names()
json$dataSets |> as_tibble()

json$dataSets$series


estructura <- jsonlite::fromJSON("https://sdmx.ine.gob.cl/rest/dataflow/CL01/DF_NMICI_SEXO/1.0?references=all")



# sacar desde el csv
readr::read_csv("https://sdmx.ine.gob.cl/rest/data/CL01,DF_NMICI_SEXO,1.0/all?dimensionAtObservation=AllDimensions&format=csvfilewithlabels")
