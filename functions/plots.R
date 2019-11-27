plot_dumbbell <- function(data) {
    data_sorted = data %>% 
        group_by(participant_id) %>%
        summarise(
            min_date = min(start_timestamp, na.rm=TRUE),
            max_date = max(end_timestamp, na.rm=TRUE)
        ) %>%
        collect() %>%
        arrange(min_date)
    
    plt = ggplot(data_sorted,
                 aes(
                     x = min_date,
                     xend = max_date,
                     y = participant_id,
                     group = participant_id
                 )) +
        geom_dumbbell(
            colour_xend = colors[1],
            colour_x = colors[2],
            size_x = 3,
            size_xend = 3,
            size = 1,
            colour = nacol,
            show.legend = TRUE
        ) +
        theme_minimal() +
        xlab("Time range by participant") +
        ylab("Participant")
    return (plt)
}


empty_plot <- function() {
    par(mar = c(0,0,0,0))
    plot(0,
         type = 'n',
         axes = FALSE,
         ann = FALSE)
}

hour_plot <- function(dat){
    if ('hour' %in% names(dat)){
        var = 'hour'
        xlab = 'Hour of day'
    } else if ('weekday' %in% names(dat)) {
        var = 'weekday'
        xlab = "Weekday"
    } else if ('daytime' %in% names(dat)) {
        var = 'daytime'
        xlab = "Daytime"
    } else {
        return (NULL)
    }
        
        plot = ggplot(dat,
                      aes_string(x = var,
                                 y = 'mean_duration_minutes'
                      ))
        plot = plot + geom_bar(stat = 'identity', fill = colors[1])
        
        plot = plot + theme_light() +
            scale_fill_manual(values = colors,
                              aesthetics = "fill",
                              na.value = nacol) +
            xlab(xlab) +
            ylab("Mean duration (minutes)")
        
        
        if (var == 'hour') {
            timekey = list()
            timekey[[as.character(0)]] = "12 AM"
            for (i in 1:11){
                timekey[[as.character(i)]] = paste0(i, " AM")
            }
            timekey[[as.character(12)]] = "12 PM"
            for (i in 13:23){
                timekey[[as.character(i)]] = paste0(i-12, " PM")
            }

                        plot +
            scale_x_continuous(labels = as.vector(unlist(timekey)), breaks = (1:(length(timekey)))-1) +
            theme(axis.text.x = element_text(angle = 90, hjust = 1), panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank())        
    } else {return (plot)}

    
}