#--------------------------------------------
# SERVER
# The server side does the actual calculations etc.
function(input, output) {
    
    # Reactive values that store the plots
    plotheatmap <- reactiveVal()
    plotagebar <- reactiveVal()
    plottests <- reactiveVal()
    
    # Data selection for the plot
    agedata <- reactive({
        datelim <- input$daterange
        
        id <- cases[["REGION"]] == input$region & 
            cases[["AGEGROUP"]] %in% input$agecats &
            cases[["GENDER"]] %in% input$gender &
            between(cases[["DATE"]], datelim[1], datelim[2]) 
        cases[id,]
    })
    
    testdata <- reactive({
        datelim <- input$daterange
        
        allcases %>%
            filter(between(DATE, datelim[1], datelim[2]))
    })
    
    # Make title: dependent on input changes
    output$thetitle <- renderText({
        paste("Number of cases by age group for",
              switch(input$gender,
                     Male = "males",
                     Female = "females",
                     All = "all genders"),
              "in",
              input$region)
    })
    
    # Create the plot
    output$ageplot <- renderPlot({
        if(input$relativeage == "rel"){
            var <- sym("RELCASES") 
            lab <- "Counts\nper 100k"
            fillscale <- scale_fill_viridis_c(option = "B")
            titl <- "Average count per day over the previous week"
        } else if(input$relativeage == "abs") {
            var <- sym("CASES")
            lab <- "Counts"
            fillscale <- scale_fill_viridis_c(option = "B")
            titl <- "Average count per day over the previous week"
        } else if(input$relativeage == "perchange"){
            var <- sym("PERCHANGE")
            lab <- "% Change"
            fillscale <- scale_fill_gradient2(low = "darkblue",
                                              mid = "white",
                                              high = "darkred",
                                              midpoint = 0)
            titl <- "Relative change in average count per day from the previous week"
        } else if(input$relativeage == "change"){
            var <- sym("CHANGE")
            lab <- "Change"
            fillscale <- scale_fill_gradient2(low = "darkblue",
                                              mid = "white",
                                              high = "darkred",
                                              midpoint = 0)
            titl <- "Change in average count per day from the previous week"
        } else if(input$relativeage == "relchange"){
            var <- sym("RELCHANGE")
            lab <- "Change\nper 100k"
            fillscale <- scale_fill_gradient2(low = "darkblue",
                                              mid = "white",
                                              high = "darkred",
                                              midpoint = 0)
            titl <- "Change in average count per day from the previous week"
        } 
        
        plotheatmap <- 
            ggplot(agedata(), mapping = aes(x=DATE,y=AGEGROUP, fill = !!var)) +
            geom_raster() +
            theme_minimal() +
            labs(x = "Date", y ="Age group",
                 fill = lab) +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") +
            fillscale +
            ggtitle(titl)
        
        plotheatmap(plotheatmap)
        plotheatmap    
    })
    
    # create the other plot
    output$caseplot <- renderPlot({
        # if(input$relativeage == "rel"){
        #     var <- sym("RELCASES") 
        #     lab <- "Number of cases per 100k"
        # }  else {
        #     var <- sym("CASES")
        #     lab <- "Number of cases"
        # }
        plotagebar <- 
            ggplot(agedata(), aes(x = DATE, y = CASES, fill = AGEGROUP)) +
            geom_col(position = position_stack(reverse = TRUE),
                     width = 1) +
            labs(x = "Date", y = "Number of cases",
                 fill = "Age group") +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") 
        
        plotagebar(plotagebar)
        plotagebar
    })
    
    output$testplot <- renderPlot({
        req(testdata)
        slice <- testdata()
        pdata <- slice %>%
            mutate(CASES = CASES * 25) %>%
            pivot_longer(c(TESTS,CASES)) 
        mid <- with(slice, max(CASES/TESTS*50))
        
        p1 <- ggplot(pdata, aes(x = DATE, y = value, color = name)) +
            geom_line(size = 2) +
            scale_y_continuous("Tests", limits = c(0,NA),
                               sec.axis = sec_axis(~ ./25, name = "Cases")) +
            theme_minimal() +
            labs(color = "")
        p2 <- ggplot(slice, aes(x = DATE, y = 1, fill = CASES/TESTS*100)) +
            geom_raster() + theme_void() +
            scale_fill_gradient2(low = "white", high = "#200000",
                                 mid = "#d80000",
                                limits = c(0,NA),
                                midpoint = mid) +
            labs(fill = "% positive") 
        
        plottests <- 
            (p2 + ggtitle("Evolution of Belgian covid tests and cases")) / p1 +
            plot_layout(heights = c(1,8), guides = 'collect')
        
        plottests(plottests)
        plottests
    })
    
    # Downloadhandlers
    
    output$downloadheatmap <- downloadHandler(
        filename = "heatmap.png",
        content = function(x){
            req(plotheatmap())
            
            p <- plotheatmap()
            ggsave(x, p, width = 8, height = 5)
        }
    )
    
    output$downloadagebar <- downloadHandler(
        filename = "agebar.png",
        content = function(x){
            req(plotagebar())
            
            p <- plotagebar()
            ggsave(x, p, width = 8, height = 5)
        }
    )
    
    output$downloadtest <- downloadHandler(
        filename = "testevolution.png",
        content = function(x){
            req(plottests())
            
            p <- plottests()
            ggsave(x, p, width = 8, height = 5)
        }
    )
    
    observeEvent(input$closed,{
        stopApp()
    })
}

