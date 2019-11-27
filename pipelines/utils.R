
#' logger
#'
#' @param message: message to log 
#' @param level: level of logger, with 0 the highest level (KIRBY)
#'
#' @return NULL
#' @export
#'
#' @examples
logger <- function(message, level=1){
    time = as.character(now())
    prefix = ifelse(level == 0, "༼ つ ◕_◕ ༽つ", "")
    print(paste(prefix, time, ":", message))
    
    return(NULL)
}
