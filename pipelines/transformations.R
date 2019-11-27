#' add_recode
#'
#' @param dataframe: tibble containing column app_fullname
#' @param recodefile: string location of recodefile
#'
#' @return dataframe: tibble  containing all columns in recodefile
#' @export
#'
#' @examples
add_recode <- function(dataframe, recodefile = NULL) {
    if (typeof(recodefile) == "character") {
        if (!file.exists(recodefile)) {
            logger("The recoding file does not exist.")
        }
        recodes <- read_csv(recodefile)
        if ("app_fullname" %in% names(recodes))
            dataframe <-
            dataframe %>% left_join(recodes, copy = TRUE, by = "app_fullname")
    }
    
    return(dataframe)
}

#' trim_dates
#'
#' @param dataframe: tibble containing columns start_timestamp and end_timestamp
#' @param only_fullday: boolean to remove the first and last day to exclude incomplete days
#' @param maxdays: optional integer to indicate the maximum number of days from the start day to use
#' @param min_datetime: optional datetime to filter out dates before a certain date
#' @param max_datetime optional datetime to filter out dates after a certain date
#'
#' @return dataframe: tibble containing column start_timestamp and end_timestamp
#' @export
#'
trim_dates <-
    function(dataframe,
             only_fullday = FALSE,
             maxdays = NULL,
             min_datetime = NULL,
             max_datetime = NULL,
             logger = list('warnings' = c(), 'errors' = c())) {
        if (only_fullday) {
            min_date <-
                dataframe %>% pull(start_timestamp) %>% min %>% ceiling_date(unit = "day")
            max_date <-
                dataframe %>% pull(end_timestamp) %>% max %>% floor_date(unit = "day")
            dataframe <-
                dataframe %>% filter(start_timestamp > min_date &
                                         end_timestap < max_date)
        }
        if (typeof(min_datetime) != "NULL") {
            if (typeof(min_datetime) != "double") {
                logger("Unrecognized min_datetime format.")
            } else {
                dataframe <- dataframe %>% filter(start_timestamp > min_datetime)
            }
        }
        if (typeof(max_datetime) != "NULL") {
            if (typeof(min_datetime) != "double") {
                logger("Unrecognized max_datetime format.")
            } else {
                dataframe <- dataframe %>% filter(end_timestamp < max_datetime)
            }
        }
        if (typeof(maxdays) != "NULL") {
            if (typeof(maxdays) != "integer") {
                logger("maxdays is not an integer.")
            } else {
                min_date <-
                    dataframe %>% pull(start_timestamp) %>% min %>% floor_date(unit = "day")
                max_date <- min_date + days(maxdays) - 1
                dataframe <-
                    dataframe %>% filter(start_timestamp < max_date)
            }
        }
        
        return (dataframe)
    }

#' summarize
#'
#' @param dataframe: tibble
#' @param unit: unit to be get summary for
#' @param weekday: days in integer (starting from monday) considered weekday
#' @param daytime: lower and upper limits for daytime (eg. c(10,18))
#'
#' @return dataframe: tibble, this table summarises daily usage for the given grouper
#' @export
#'
#' @examples
get_daily_summary <-
    function(dataframe,
             groupers = c("participant_id", "hour", "weekday", "daytime"),
             weekdays = 1:5,
             daytime = c(10, 18)) {
        
        lazy = 'src' %in% names(dataframe)
        
        ## TO DO:
        #
        # - day is now just day of month, which is not correct chronologically
        # - addition of categories
        # - participant_id --> gonn depend on whether we do this multilevel or one by one

        if (!("day" %in% groupers)){
            groupers = c(groupers, "day")
        }
        dataframe <- dataframe %>%
            mutate(day = day(start_timestamp))
        
        if ("hour" %in% groupers){
            dataframe <- dataframe %>%
                mutate(hour = hour(start_timestamp))
        }
        
        if ("weekday" %in% groupers){
            dataframe <- dataframe %>%
                mutate(weekday = wday(start_timestamp) %in% weekdays)
        }
        
        if ("daytime" %in% groupers){
            rng <- daytime[1]:daytime[2]
            dataframe <- dataframe %>%
                mutate(daytime = hour(start_timestamp)) %>%
                mutate(daytime = daytime %in% rng) %>%
                mutate(daytime = hour(start_timestamp) %in% rng)
        }
        
        # calculate duration
        # this piece needs a separate approach for
        # lazytables and tibbles.
        
        # these two pieces generate slightly different results
        # my understanding is that lubridate (not lazy) rounds the timestamps
        # to seconds when calculating difftime whereas this is
        # not the case in dbplyr.
        
        if (lazy) {
            dataframe = dataframe %>% 
                mutate(timediff = end_timestamp - start_timestamp) %>%
                mutate(
                    duration_seconds = second(timediff) + minute(timediff)*60 + hour(timediff)*60*60,
                    duration_minutes = duration_seconds/60
                    ) %>% 
                select(-c(timediff))
                
        } else {
            dataframe = dataframe %>% 
                mutate(
                    duration_seconds = as.numeric(difftime(end_timestamp, start_timestamp, units="secs")),
                    duration_seconds = ifelse(duration_seconds > 0, duration_seconds, duration_seconds + 24*60*60),
                    duration_minutes = duration_seconds / 60
                )
        }
        
        # group by all groupers and day
        # only difference btw lazy/non-lazy: 
        # - count vs length
        # - distinct vs unique
        
        if (lazy){
            dataframe <- dataframe %>%
                group_by(!!!syms(groupers)) %>%
                summarise(
                    appcount = as.numeric(count(distinct(app_fullname))),
                    duration_minutes = as.numeric(sum(duration_minutes, na.rm=TRUE)),
                    engage_60s = as.numeric(count(engage_60s)),
                    engage_300s = as.numeric(count(engage_300s)),
                    app_switches = as.numeric(count(switch_app))
                ) %>%
                ungroup()
        } else {
            dataframe <- dataframe %>%
                group_by(!!!syms(groupers)) %>%
                summarise(
                    appcount = as.numeric(length(unique(app_fullname))),
                    duration_minutes = as.numeric(sum(duration_minutes, na.rm=TRUE)),
                    engage_60s = as.numeric(length(engage_60s)),
                    engage_300s = as.numeric(length(engage_300s)),
                    app_switches = as.numeric(length(switch_app))
                ) %>%
                ungroup()
        }
        
        fill_var = list(
            hour = 1:24,
            weekday = c(TRUE, FALSE),
            daytime = c(TRUE, FALSE),
            day = min(dataframe %>% pull(day)):max(dataframe %>% pull(day))
        )
        
        fill_var = fill_var[groupers[groupers!='participant_id']]
        
        fill_val = list(
            appcount = 0,
            duration_minutes = 0,
            engage_60s = 0,
            engage_300s = 0,
            app_switches = 0,
            participant_id = dataframe %>% pull(participant_id) %>% first
        )

        dataframe <- dataframe %>% 
            collect() %>%
            complete(!!!(fill_var), fill = fill_val) %>%
            ungroup() %>%
            mutate(day = as.character(day))
        
        grouper_sans_day = groupers[groupers != "day"]
        dataframe <- dataframe %>%
            group_by(!!!syms(grouper_sans_day)) %>%
            summarise(
                mean_appcount = mean(appcount),
                mean_duration_minutes = mean(duration_minutes),
                mean_engage_60s = mean(engage_60s),
                mean_engage_300s = mean(engage_300s),
                mean_app_switches = mean(app_switches),
                std_appcount = sd(appcount),
                std_duration_minutes = sd(duration_minutes),
                std_engage_60s = sd(engage_60s),
                std_engage_300s = sd(engage_300s),
                std_app_switches = sd(app_switches),
                days = length(unique(day))
            )
        
        return(dataframe)
    }
