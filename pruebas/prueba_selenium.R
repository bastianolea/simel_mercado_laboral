

# instalar rselenium
# install.packages("RSelenium")
# vignette("basics", package = "RSelenium")

library(RSelenium)

# instalar docker desktop
# https://rpubs.com/johndharrison/RSelenium-Docker
# https://medium.com/@fabiokeller/how-to-make-rselenium-work-on-macos-monterey-with-docker-7fde9c9de5ae

# instalar imagen:
# docker pull selenium/standalone-firefox:latest

# ejecutar imagen:
# docker run -d -p 4445:4444 selenium/standalone-firefox:latest

# ver imágenes en ejecución
# docker ps


# system("docker run -d -p 4446:4444 selenium/standalone-firefox")

remDr <- remoteDriver(port = 4444,
                      remoteServerAddr = "localhost",
                      browserName = "firefox")
remDr$open()

remDr$navigate("http://www.google.com/ncr")
remDr$getTitle()

SeleniumSession$new()
