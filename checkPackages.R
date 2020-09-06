# Checks and loads the necessary packages
#----------------------------------------

Check whether the necessary packages are installed.
if(!suppressWarnings(library("doesntexist", logical.return = TRUE,
            quietly = TRUE))){
    stop("Package needs installing.", call. = FALSE)
}
