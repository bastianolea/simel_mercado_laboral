library(dplyr)
library(rvest)
library(RSelenium)
library(purrr)
library(tidyr)
library(stringr)
library(glue)
library(here)
source("simel_funciones.R")

# scraping y obtención de datos desde Simel - https://de.ine.gob.cl

# definir categoría ----
# categoría del sitio a scrapear

categoria = "Oportunidades de empleo"
categoria_id = "oportunidades_empleo"
url = "https://de.ine.gob.cl/?fs[0]=Dimensiones%20Trabajo%20Decente%2C0%7COportunidades%20de%20empleo%23OPORTUNIDADES_EMPLEO%23&pg=0&fc=Dimensiones%20Trabajo%20Decente&bp=true&snb=100"

categoria = "Igualdad de oportunidades y trato en el trabajo"
categoria_id = "igualdad_oportunidades"
url = "https://de.ine.gob.cl/?fs[0]=Dimensiones%20Trabajo%20Decente%2C0%7CIgualdad%20de%20oportunidades%20y%20trato%20en%20el%20trabajo%23IGUALDAD_OPORTUNIDADES%23&pg=0&fc=Dimensiones%20Trabajo%20Decente&bp=true&snb=14"

categoria = "Ingresos adecuados y trabajo productivo"
categoria_id = "ingreso_adecuado"
url = "https://de.ine.gob.cl/?fs[0]=Dimensiones%20Trabajo%20Decente%2C0%7CIngresos%20adecuados%20y%20%20trabajo%20productivo%23INGRESOS%23&pg=0&fc=Dimensiones%20Trabajo%20Decente&bp=true&snb=71"

categoria = "Estabilidad y seguridad del trabajo"
categoria_id = "estabilidad_seguridad"
url = "https://de.ine.gob.cl/?fs[0]=Dimensiones%20Trabajo%20Decente%2C0%7CEstabilidad%20y%20seguridad%20del%20trabajo%23ESTABILIDAD_SEGURIDAD%23&pg=0&fc=Dimensiones%20Trabajo%20Decente&bp=true&snb=8"

#—----

# scraping ----

# abrir server
remote_driver <- simel_navegador_crear()
# remote_driver |> simel_visitar(url)

# obtener enlaces
enlaces_datos <- remote_driver |> simel_scraping_enlaces_datos(url)

# obtener metadatos
metadatos <- remote_driver |> simel_scraping_metadatos(enlaces_datos, categoria, categoria_id)
simel_guardar_metadatos(metadatos, categoria_id)

# descargar datos
simel_descargar_datos(metadatos$id, categoria_id)

# terminar sesión
simel_navegador_cerrar(driver)
