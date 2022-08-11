
library(tidyverse)
library(shiny)


library(tidyverse)
library(ggplot2)
library(shiny)
library(bslib)

scottish_exports <- read_csv("scottish_exports.csv")

ui <- fluidPage(

  titlePanel(tags$h1("Scottish Exports: 2002 to 2015")),

  fluidRow(
    
    column(width = 4, offset = 1,
           checkboxGroupInput(inputId = 'sector_input',
                        label = 'Select sectors',
                        choices = unique(scottish_exports$sector)
           )),
    
    column(width = 4, offset = 3, 
           selectInput(inputId = 'year_input',
                       label = 'Select year',
                       choices = unique(scottish_exports$year)
           )
    )
  ),
  
  fluidRow(
    
    column(width = 6, offset = 1,
      plotOutput("export_plot")
    ),
    
    column(width = 3, offset = 1,
      plotOutput("fraction_plot")   
    )
  )

)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$export_plot <- renderPlot({
    
    scottish_exports %>%
      filter(sector %in% input$sector_input) %>% 
      ggplot(aes(x = year, y = exports, colour = sector)) +
      geom_line() +
      geom_point() +
      scale_y_continuous(expand = c(0,0),
                         limits = c(0, max(scottish_exports$exports)*1.1),
                         labels = label_number(big.mark = ",")) +
      scale_x_continuous(breaks = seq(min(scottish_exports$year),
                                      max(scottish_exports$year),
                                      by = 1)) +
      theme(panel.background = element_rect(fill = "white", colour = "gray90"),
            panel.grid = element_line(colour = "gray90"),
            legend.key = element_rect(fill = "white"),
            axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Year",
           y = "Exports",
           colour = "Sector")
  })
  
  output$fraction_plot <- renderPlot({
    
    scottish_exports %>% 
      filter(year == input$year_input) %>%
      mutate(frac = exports/sum(exports)) %>% 
      ggplot(aes(x = year,
                 y = frac,
                 fill = sector)) +
      geom_col(position = "fill") +
      scale_x_continuous(breaks = as.numeric(input$year_input)) +
      # geom_text(aes(label = frac), vjust = 0.5) +
      labs(x = "Year",
           y = "Fraction of Exports",
           fill = "Sector")
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
