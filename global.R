library(shinydashboard)
library(shinyWidgets)
library(openlattice)
library(lubridate)
library(tidyverse)
library(shinyjs)
library(shiny)
library(ggalt)

source("Modules/authentication.R")
source("Modules/home.R")
source("Modules/tables.R")
source("Modules/vizzies.R")
source("Modules/settings.R")
source("functions/plots.R")
source("pipelines/utils.R")
source("pipelines/transformations.R")
source("pipelines/summary.R")

colors = c(
    '#455aff',
    '#ffe671',
    '#ff3c5d',
    '#00be84',
    '#ff9a58',
    '#dd9e00',
    "#a3adff",
    '#008f63',
    '#80dfc2',
    '#ffb7a2',
    '#6124e2',
    '#44beff',
    '#00bace',
    '#ddb2ff',
    "#ff9a58",
    "#00be84",
    "#bc0000",
    "#a939ff",
    "#ffde00",
    "#f25497",
    "#2f69ff",
    "#00583d"
)

default_config = list(
    only_fullday = FALSE,
    maxdays = NULL,
    min_datetime = NULL,
    max_datetime = NULL,
    recodefile = NULL,
    # recodefile = paste0(
    #     "/Users/jokedurnez/Documents/pipelines/chronicle-analysis/examples/",
    #     "categorisation.csv"
    # ),
    groupers = c("participant_id", 'hour'),
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

jscode <- "
    shinyjs.collapse = function(boxid) {
    $('#' + boxid).closest('.box').find('[data-widget=collapse]').click();
    }
    "    

nacol <- "#dcdce7"

