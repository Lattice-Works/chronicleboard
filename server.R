shinyServer(function(input, output, session) {
    
    jwt <- reactiveVal("")
    # jwt <- callModule(authentication_server, "authentication", jwt)
    
    data <- callModule(settings_server, "settings")

    callModule(home_server, "home", data)
    callModule(table_server, "tables", data)
    callModule(vizzies_server, "vizzies", data)
    
})
