vizzies_ui <- function(id){
    ns <- NS(id)
    tabPanel("Vizzies",
             fluidRow(
                 box(
                     width = 12,
                     solidHeader = TRUE,
                     title = "Chronicle data",
                     status = "info",
                     plotOutput(ns("vizzy"))
                     
                 )
             )
    )
}


# SERVER FUNCTIONS

vizzies_server <-
    function(input,
             output,
             session,
             data) {
        
        output$vizzy <-
            renderPlot({
                hour_plot(data$summary)
            })
        
        
    }