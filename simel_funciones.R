# esperar una cantidad de tiempo aleatoria
esperar <- function(x = 1) {
  x_random <- seq(x*1, x*2.2, by = 0.05) |> sample(1)
  Sys.sleep(x_random)
}

cronometro_iniciar <- function() {
  tiempo_inicio <<- Sys.time()
}

cronometro_terminar <- function() {
  tiempo_fin <<- Sys.time()
}

# esperar_cronometro <- function() {
#   duracion <- tiempo_fin - tiempo_inicio
#  esperar(as.numeric(duracion))
# }
cronometro_esperar <- function(mult = 1) {
  cronometro_terminar()
  duracion <- as.numeric(tiempo_fin - tiempo_inicio)
  message(glue("esperando {round(duracion * mult, 1)} segundos"))
  
  esperar(duracion * mult)
}

