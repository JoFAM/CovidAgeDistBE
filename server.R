#--------------------------------------------
# SERVER
# The server side does the actual calculations etc.
function(input, output) {
    
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
        
        ggplot(agedata(), mapping = aes(x=DATE,y=AGEGROUP, fill = CASES)) +
            geom_raster() +
            theme_minimal() +
            labs(x = "Date", y ="Age group",
                 fill = "Counts") +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") +
            scale_fill_viridis_c(option = "B") +
            ggtitle("Average count per day over the previous week")
            
    })
    
    # create the other plot
    output$caseplot <- renderPlot({
        ggplot(agedata(), aes(x = DATE, y = CASES, fill = AGEGROUP)) +
            geom_col(position = position_stack(reverse = TRUE),
                     width = 1) +
            labs(x = "Date", y = "Number of cases",
                 fill = "Age group") +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") 
    })
    
    output$testplot <- renderPlot({
        req(testdata)
        slice <- testdata()
        pdata <- slice %>%
            mutate(CASES = CASES * 25) %>%
            pivot_longer(c(TESTS,CASES)) 
        
        p1 <- ggplot(pdata, aes(x = DATE, y = value, color = name)) +
            geom_line(size = 2) +
            scale_y_continuous("Tests", limits = c(0,NA),
                               sec.axis = sec_axis(~ ./25, name = "Cases")) +
            theme_minimal() +
            labs(color = "")
        p2 <- ggplot(slice, aes(x = DATE, y = 1, fill = CASES/TESTS*100)) +
            geom_raster() + theme_void() +
            scale_fill_gradient(low = "white", high = "darkred", 
                                limits = c(0,NA)) +
            labs(fill = "% positive") 
        
        (p2 + ggtitle("Evolution of Belgian covid tests and cases")) / p1 +
            plot_layout(heights = c(1,8), guides = 'collect')
    })
    
    observeEvent(input$closed,{
        stopApp()
    })
}

