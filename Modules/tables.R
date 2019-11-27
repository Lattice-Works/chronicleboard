table_ui <- function(id){
    ns <- NS(id)
    tabPanel("Summary table",
             fluidRow(
                 box(
                     width = 12,
                     solidHeader = TRUE,
                     title = "Chronicle data",
                     DT::dataTableOutput(outputId = ns("chronicle_table")),
                     status="info"
                 ),
                 column(12, align = "center", downloadButton(ns("download_chronicle"), "Download"))
             ),
    )
}


# SERVER FUNCTIONS

table_server <-
    function(input,
             output,
             session,
             data) {
        
        output$chronicle_table <- DT::renderDataTable({
            data$summary
        },
        options = list(scrollX = TRUE))
        
        output$download_chronicle <- downloadHandler(
            filename = "CAFE_chronicle.csv",
            content = function(file) {
                write.csv(
                    data$summary,
                    file,
                    row.names = FALSE
                )
            }
        )
        

    }