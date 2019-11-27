library(tidyverse)
library(lubridate)

source("pipelines/utils.R")
source("pipelines/transformations.R")
source("pipelines/summary.R")

config = list(
    only_fullday = FALSE,
    maxdays = NULL,
    min_datetime = NULL,
    max_datetime = NULL,
    recodefile = NULL,
    # recodefile = paste0(
    #     "/Users/jokedurnez/Documents/pipelines/chronicle-analysis/examples/",
    #     "categorisation.csv"
    # ),
    groupers = c("participant_id", 'hour', 'weekday', 'daytime'),
    weekdays = 1:5,
    daytime = c(10, 18),
    basecols = c(
        "participant_id" = "participant_id",
        "app_fullname" = "app_fullname", 
        "start_timestamp" = "start_timestamp", 
        "end_timestamp" = "end_timestamp", 
        "engage_60s" = "engage_60s",
        "engage_300s" = "engage_300s",
        "switch_app" = "switch_app")
)


# example 2:
# reading data from a local file
# to test if the output is the same as
# the current output.

lin = "https://raw.githubusercontent.com/Lattice-Works/chronicle-analysis/master/examples/preprocessed/ChronicleData_preprocessed-DrZevia_subset_missingday.csv"
data2 = read_csv(
    url(lin)
)

output2 = data2 %>% get_summary(config = config)


# example 1:
# reading data from a local database
# to test if we can use dbplyr everywhere to
# reduce loading and computation times
# 
# con <- DBI::dbConnect(
#     RPostgres::Postgres(),
#     dbname = "chronicle",
#     host = "localhost",
#     port = 5432,
#     user = "jokedurnez"
# )
# data1 = tbl(con, 'chronicle')
# output1 = data1 %>% get_summary(config = config)

