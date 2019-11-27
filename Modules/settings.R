settings_ui <- function(id) {
    ns <- NS(id)
    
    box(
        width = 12,
        title = "Settings",
        solidHeader = TRUE,
        collapsible = TRUE,
         column(
            width = 12,
            uiOutput(ns('groupers'))
        ),
        column(
            width = 12,
            uiOutput(ns('daterange'))
        ),
        column(
            width = 12,
            actionButton(inputId = ns("recalculate"), "recalculate")
        ),
        column(addSpinner(
            plotOutput(ns("emptyplot"), height = "100px"),
            spin = "bounce",
            color = colors[1]
        ),
        width = 12
        )
    )
        
    
}

settings_server <- function(input,
                           output,
                           session,
                           data) {
    ns <- session$ns

    ###############
    ## LOAD DATA ##
    ###############
    
    data <- reactiveValues(
        fulldata = list(),
        datapoints = 0,
        config = default_config
    )
    
    observe({
        # cat("Getting entity set names...\n")
        # shinyjs::addCssClass(id = "emptyplot",
        #                      class = "recalculating")
        # con <- DBI::dbConnect(
        #     RPostgres::Postgres(),
        #     dbname = "chronicle",
        #     host = "localhost",
        #     port = 5432,
        #     user = "jokedurnez"
        # )
        # dataset = tbl(con, 'chronicle')
        lin = "https://raw.githubusercontent.com/Lattice-Works/chronicle-analysis/master/examples/preprocessed/ChronicleData_preprocessed-DrZevia_subset_missingday.csv"
        dataset = read_csv(
            url(lin)
        )
        
        data[["fulldata"]] = dataset
        data[["datapoints"]] = dataset %>% count %>% pull(n) %>% first
        shinyjs::removeCssClass(id = "emptyplot",
                                class = "recalculating")
    })
    
    observe({
        data[['summary']] = data$fulldata %>% get_summary(config = data$config)
    })
    
    observeEvent(input$recalculate, {
        data[['config']][['groupers']] = c("participant_id", input$groupers)
        data[['summary']] = data$fulldata %>% get_summary(config = data$config)

        
    })
    
    ###################
    ## INPUT OBJECTS ##
    ###################
    
    
    output$groupers <- renderUI({
        checkboxGroupButtons(
            inputId = ns("groupers"),
            "Groupers:",
            choices = c(  "hour", "weekday", "daytime"),
            selected = c( "hour"),
            justified = FALSE
        )
    })
    
    output$daterange <- renderUI({
        dateRangeInput(
            inputId = ns("daterange"),
            "Date range (not functional yet):",
            start = ymd("2018-07-01"), end = today()
        )
    })
    
    output$emptyplot <- renderPlot({empty_plot()})
    
    return(data)
    
}
    
    