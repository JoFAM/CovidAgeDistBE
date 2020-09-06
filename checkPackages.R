# Checks and loads the necessary packages
#----------------------------------------

if(!suppressWarnings(library("doesntexist", logical.return = TRUE,
            quietly = TRUE))){
    stop("Package needs installing.", call. = FALSE)
}
