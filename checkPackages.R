# Checks and loads the necessary packages
#----------------------------------------

toload <- c("doesntexist","shinydashboard","whatnow")

if(!suppressWarnings(
  id <- all(sapply(toload, library, logical.return = TRUE))
)){
  errmessage <- paste("Following packages need installing:",
                      toload[!id], collapse = "\n")
  stop(errmessage, call. = FALSE)
}
