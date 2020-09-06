#------------------------------------
# Create the dataset from the website of Epistat
#------------------------------------

message("Downloading data.")
#-----------------------------------------------------------------
# Try to download the data. Construct an informative error message
# when this doesn't work.

tmp <- tryCatch(
  read.csv("https://epistat.sciensano.be/Data/COVID19BE_CASES_AGESEX.csv"),
  error = function(e){}, warning = function(w){
    stop("The data file could not be downloaded. The server of epistat might be temporarily down. Check whether you can access\nhttps://epistat.wiv-isp.be/Covid/",
         call. = FALSE)
  })

#----------------------------------------------------------------
# Process the data :
# - remove the missing data
# - calculate the rolling mean of weekly totals for every region,
# age group and sex.
message("Processing data.")

# Missing values in the dataset indicate no counts.
replaceby0 <- function(x){
  x[is.na(x)] <- 0
  x
}

# Process data: remove missing values, calculate rolling sums.
# Cases give 
cases <- tmp %>%
  na.omit() %>%
  mutate(DATE = as.Date(DATE)) %>%
  group_by(DATE, REGION, AGEGROUP, SEX) %>%
  summarise(CASES = sum(CASES)) %>%
  ungroup() %>%
  pivot_wider(names_from = SEX,
              values_from = CASES) %>%
  mutate(Female = replaceby0(F),
         Male = replaceby0(M)) %>%
  select(-F, -M) %>%
  group_by(REGION, AGEGROUP) %>%
  mutate(Female = zoo::rollmean(Female, 7, align = "right",
                                 fill = NA),
         Male = zoo::rollmean(Male, 7, align = "right",
                               fill = NA),
         All = Female + Male) %>%
  na.omit() %>%
  ungroup()

allregions <- cases %>%
  group_by(DATE, AGEGROUP) %>%
  summarise_at(vars(Female, Male, All),
               sum)

message("Succes!")
