#------------------------------------
# Create the dataset from the website of Epistat
#------------------------------------

message("Downloading data.")
#-----------------------------------------------------------------
# Try to download the data. Construct an informative error message
# when this doesn't work.

rawcases <- tryCatch(
  read.csv("https://epistat.sciensano.be/Data/COVID19BE_CASES_AGESEX.csv",
           fileEncoding = "UTF8"),
  error = function(e){}, warning = function(w){
    stop("The data file could not be downloaded. The server of epistat might be temporarily down. Check whether you can access\nhttps://epistat.wiv-isp.be/Covid/",
         call. = FALSE)
  }) %>%
  mutate(DATE = as.Date(DATE)) %>%
  filter(!is.na(DATE) & DATE < Sys.Date()-1)

rawtest <- tryCatch(
  read.csv("https://epistat.sciensano.be/Data/COVID19BE_tests.csv",
           fileEncoding = "UTF8"),
  error = function(e){}, warning = function(w){
    stop("The data file could not be downloaded. The server of epistat might be temporarily down. Check whether you can access\nhttps://epistat.wiv-isp.be/Covid/",
         call. = FALSE)
  }) %>%
  mutate(DATE = as.Date(DATE)) %>%
  filter(!is.na(DATE) & DATE < Sys.Date()-1)

rawhospit <- tryCatch(
  read.csv("https://epistat.sciensano.be/Data/COVID19BE_HOSP.csv",
           fileEncoding = "UTF8"),
  error = function(e){}, warning = function(w){
    stop("The data file could not be downloaded. The server of epistat might be temporarily down. Check whether you can access\nhttps://epistat.wiv-isp.be/Covid/",
         call. = FALSE)
  }) %>%
  mutate(DATE = as.Date(DATE)) %>%
  filter(!is.na(DATE) & DATE < Sys.Date()-1)

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

# Calculate the change
changeabsolute <- function(x){
  n <- length(x)
  c(rep(NA,7), (x[8:n] - x[1:(n-7)]))
}
  
changepercent <- function(x){
  n <- length(x)
  c(rep(NA,7), (x[8:n] - x[1:(n-7)])/ x[1:(n-7)] * 100 )
}

#---------------------------------
# Process data: all cases and tests
allcases <- rawcases %>%
  group_by(DATE) %>%
  summarise(CASES = sum(CASES)) %>%
  full_join(rawtest, by = "DATE") %>%
  mutate(CASES = zoo::rollmean(CASES, 7,fill = NA, align = "right"),
         TESTS = zoo::rollmean(TESTS_ALL, 7, fill = NA, align = "right")) %>%
  select(-TESTS_ALL) %>%
  na.omit() 

n <- read.csv("AgedistPopBe.csv")

# Process data: cases by region and agegroup
cases <- rawcases %>%
  na.omit() %>%
  group_by(DATE, REGION, AGEGROUP, SEX) %>%
  summarise(CASES = sum(CASES)) %>%
  ungroup() %>%
  pivot_wider(names_from = c(SEX,REGION),
              values_from = CASES) %>%
  mutate(across(where(is.numeric), replaceby0)) %>%
  mutate(F_Belgium = F_Brussels + F_Flanders + F_Wallonia,
         M_Belgium = M_Brussels + M_Flanders +M_Wallonia,
         All_Belgium = F_Belgium + M_Belgium,
         All_Flanders = F_Flanders + M_Flanders,
         All_Wallonia = F_Wallonia + M_Wallonia,
         All_Brussels = F_Brussels + M_Brussels) %>%
  pivot_longer(contains("_"),
               names_to = "TEMP",
               values_to = "CASES") %>%
  separate(TEMP, into = c("GENDER","REGION"), sep = "_") %>%
  pivot_wider(values_from = CASES, names_from = AGEGROUP) %>%
  mutate(across(where(is.numeric), replaceby0)) %>%
  pivot_longer(matches("\\d[-+]"), 
               names_to = "AGEGROUP",
               values_to = "CASES") %>%
  group_by(AGEGROUP, GENDER, REGION) %>%
  mutate(CASES = zoo::rollmean(CASES, 7, align = "right",
                                                   fill = NA)) %>%
  na.omit() %>%
  left_join(n, by = c("AGEGROUP","REGION","GENDER")) %>%
  mutate(RELCASES = CASES/POP * 100000,
         CHANGE = changeabsolute(CASES),
         RELCHANGE = changeabsolute(RELCASES),
         PERCHANGE = changepercent(CASES))

# Process data: hospitalisation


totals <- rawhospit %>%
  select(-c(PROVINCE,NR_REPORTING)) %>%
  group_by(DATE) %>%
  summarise(across(where(is.numeric), sum)) %>%
  mutate(REGION = "All")

hospit <- rbind(select(rawhospit, -c(PROVINCE,NR_REPORTING)),
                totals) %>%
  mutate(across(where(is.numeric),
                ~ zoo::rollmean(., 7, align = "right",
                                fill = NA))) %>%
  na.omit()

message("Writing data...")
write.csv(cases,
          file = paste0("Data/cases",Sys.Date(),".csv"))
write.csv(allcases,
          file = paste0("Data/allcases",Sys.Date(),".csv"))
write.csv(hospit,
          file = paste0("Data/hospit", Sys.Date(), ".csv"))

message("Succes!")
