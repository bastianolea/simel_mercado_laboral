
# Datos del Sistema de Información del Mercado Laboral (Simel)


![](https://de.ine.gob.cl/assets/siscc/data-explorer/images/dotstat-data-simel-logo.png)

El [Sistema de Información del Mercado Laboral (SIMEL)](https://www.simel.gob.cl) es una plataforma virtual desarrollada por las instituciones que componen la Mesa para la Coordinación de las Estadísticas del Trabajo 1 con el apoyo técnico de la Organización Internacional del Trabajo (OIT).

El SIMEL permite obtener información objetiva y actualizada sobre el mercado del trabajo, la que estará disponible para investigadores, tomadores de decisiones y la ciudadanía en general.

----

Este repositorio permite descargar los datos estadísticos de SIMEL con un solo script, obteniendo cada conjunto de datos en archivos `csv` individuales.

El script `simel_scraping.R` ejecuta un controlador de Selenium que utiliza Firefox para navegar por el sitio y obtener los datos. Retorna los datos en `csv` en la carpeta `datos/{categoria}/`, y los metadatos en la carpeta `metadatos`.

No usa la API porque no entendí cómo usarla 🥲


----

1. cargar_datos.R: output: `resultados/simel_datos.parquet`
2. explorar_datos.R
