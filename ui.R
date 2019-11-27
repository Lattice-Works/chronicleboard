source("global.R")

# Define UI for application that draws a histogram
tagList(
    useShinyjs(),
    # extendShinyjs(text = jscode),
    navbarPage(
        id = "navbar",
        title =
            div(
                img(src = "logomark.png",
                    class = "logo"),
                "ChronicleBoard",
                class = "navbar-title"
            ),
        theme = "custom.css",
        fluid = FALSE,
        windowTitle = "ChronicleBoard",
        header = tags$head(
            tags$style(HTML(
                "#page-nav > li:first-child { display: none; }"
            )),
            tags$link(rel = "stylesheet", type = "text/css", href = "AdminLTE.css"),
            tags$link(rel = "stylesheet", type = "text/css", href = "shinydashboard.css"),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
            tags$link(rel = "icon", type = "image/png", href = "favicon.png"),
            tags$script(src = "https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js")
        ),
        tabPanel(
            tags$style("html, body {overflow: visible !important;"),
            tags$style("
                       body {
                       -moz-transform: scale(0.75, 0.75); /* Moz-browsers */
                       zoom: 0.8; /* Other non-webkit browsers */
                       zoom: 80%; /* Webkit browsers */
                       }
                       "),
            title = "Home",

                      tabsetPanel(
                        type = "pills",
                        home_ui("home"),
                        tabPanel(
                            "Insights",
                            fluidRow(
                                column(
                                    width = 12,
                                    settings_ui("settings")
                                )
                            ),
                            fluidRow(
                                column(
                                    width =12,
                                    box(
                                        width = 12,
                                    tabsetPanel(
                                        type = "tabs",
                                        vizzies_ui("vizzies"),
                                        table_ui("tables")
                                    )
                                    )
                                )
                            )
                            
                            
                            )
                        )
                )
        )
            
        
)