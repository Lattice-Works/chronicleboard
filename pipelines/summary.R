#' get_summary
#'
#' @param data: input dataframe 
#' @param config: configuration (currently defined in global.R)
#'
#' @return data: summary table
#' @export
#'
#' @examples
get_summary <- function(data, config) {
    lazy = 'src' %in% names(data)
    
    if (data %>% count %>% pull(n) == 0) {
        logger("No data.")
        return(tibble())
    }
    
    # only get relevant columns
    if (!lazy){
        data = data %>% mutate(
            start_timestamp = as.POSIXct(date + hms(starttime)),
            end_timestamp = as.POSIXct(date + hms(endtime))
        )        
    }

    data = data %>% select(names(config$basecols)) %>% rename(!!config$basecols)


    # apply datetime filters
    data <- data %>% 
        trim_dates(
            only_fullday = config$only_fullday,
            maxdays = config$maxdays,
            min_datetime = config$min_datetime,
            max_datetime = config$max_datetime
        )
    
    if (data %>% count %>% pull(n) == 0) {
        logger("No data within time restrictions.")
        return(tibble())
    }
    
    # add recodes of apps
    data <- data %>%
        add_recode(config$recodefile)
    
    # derive daywise summary
    data <- data %>% get_daily_summary(
        groupers = config$groupers,
        weekdays = config$weekdays,
        daytime = config$daytime
    )

    return(data)
    
    
    
}
