home_ui <- function(id) {
    ns <- NS(id)
    tabPanel("Overview",
             tags$style("html, body {overflow: visible !important;"),
             fluidRow(
                 column(
                     width = 12,
                                valueBoxOutput(ns('datapoints'), width = 3),
                                valueBoxOutput(ns('count_avage'), width = 3),
                                valueBoxOutput(ns('count_homeless'), width = 3),
                                valueBoxOutput(ns('count_veteran'), width = 3)
                     ),
                 column(
                     width =12,
                     box(
                         width = 12,
                         title = "Participant timeranges",
                         plotOutput(ns("time"))
                     )
                 )
             )
    )
    
}

home_server <- function(input,
                        output,
                        session,
                        data) {
    ns <- session$ns
    

    ####################
    ## OUTPUT OBJECTS ##
    ####################
    

    output$datapoints <- renderValueBox({valueBox(data[['datapoints']], "total number of datapoints")})
    output$count_avage <- renderValueBox({valueBox(0, "participants")})
    output$count_homeless <- renderValueBox({valueBox(0, "first date")})
    output$count_veteran <- renderValueBox({valueBox(0, "last date")})
    output$count_male <- renderValueBox({valueBox(0, "?")})

    output$time <-
        renderPlot({
            plot_dumbbell(data[['fulldata']])
        })
    # this is just a dummpy plot for the spinner
    # should find better solution !
    output$emptyplot <-renderPlot({empty_plot()})
    
    return(data)
    
}