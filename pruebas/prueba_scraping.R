# library(rvest)
# 
# url <- "https://de.ine.gob.cl/?fs[0]=Dimensiones%20Trabajo%20Decente%2C0%7COportunidades%20de%20empleo%23OPORTUNIDADES_EMPLEO%23&pg=0&fc=Dimensiones%20Trabajo%20Decente&bp=true&snb=100"
# 
# sitio <- url |> 
#   session() |> 
#   read_html_live()
# 
# sitio |> 
#   html_elements(".id_search_page")


