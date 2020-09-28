# Checks and loads the necessary packages
#----------------------------------------

toload <- c("dplyr",
            "tidyr",
            "shinydashboard",
            "ggplot2",
            "patchwork",
            "shinyWidgets")

# library gives a warning when package cannot be found. 
# character.only forces library to only accept character values.
# This is needed to apply library over a character vector.
# logical.return forces library to return FALSE if 
# installation didn't succeed.

id <- suppressWarnings(
  sapply(toload, 
         library, 
         logical.return = TRUE,
         character.only = TRUE,
         quietly = TRUE,
         warn.conflicts = FALSE)
)

# Test installation and return the packages that need to
# be installed.
if(!all(id)){
  errmessage <- paste("To run the app, the following packages should be installed first:",
                      paste(toload[!id], collapse = "\n"), 
                      sep = "\n")
  stop(errmessage, call. = FALSE)
} else if(packageVersion("dplyr") <= '1.0.0'){
  stop("The package dplyr is outdated. Please update this to version 1.0.x, otherwise the code won't work. Best way to do this, is to restart R and reinstall dplyr. You can check the current version using:\npackageVersion('dplyr')", call. = FALSE)
}

# Get rid of annoying messages
options(dplyr.summarise.inform = FALSE)
