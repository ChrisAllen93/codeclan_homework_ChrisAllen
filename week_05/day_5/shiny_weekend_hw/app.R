

# load in libraries -------------------------------------------------------

library(shiny)
library(tidyverse)
library(scales)
library(shinyWidgets)
library(bslib)


# read in data ------------------------------------------------------------

game_sales <- CodeClanData::game_sales

# initialise unique list of platform choices
platform_choices <- game_sales %>% 
  distinct(platform) %>% 
  arrange(platform) %>% 
  pull()

# initialise uniqe list of rating "sort by" choices
sort_by_choices <- c("Critic Score", "User Score")


# ui ----------------------------------------------------------------------



# Define UI for application that draws a histogram
ui <- fluidPage(

  theme = bs_theme(bootswatch = "darkly"),
  
  
    # Application title
    titlePanel("Video Game Sales"),

    fluidRow(
      
      column(width = 12,
             plotOutput("annual_sales_output")
      )),
  
    fluidRow(
      
      column(width = 2,
             selectInput("platform_input",
                         "Select platform?",
                         choices = platform_choices,
                         selected = "Wii",
                         multiple = F),

             uiOutput("genre_input"),
             
            img(src = "video-games-image.jpeg", alight = "left",
                height = "50%", width = "100%")

      ),

      column(width = 3, offset = 0.5, 
             tags$b("Top 5 Highest Rated Games"),
             selectInput("sort_by_input",
                         "Sort by:",
                         choices = sort_by_choices),
                    tableOutput("top_ratings_output")
      ),

      column(width = 3, offset = 0.5,
             plotOutput("platform_sales_bar")),
      
      column(width = 3,
             plotOutput("genre_sales_bar"))
    )
      
)


# server ------------------------------------------------------------------


server <- function(input, output) {

# creation of top 5 rated games based on user inputs for genre and platform
  output$top_ratings_output <- renderTable({
  
# on startup genre input is Null therefore if statements ensures that game list is only filtered on user-selected inputs, i.e. doesn't throw an error
  if(!is.null(input$genre_input)) {
    
    filtered_games <- game_sales %>% 
      filter(platform %in% input$platform_input &
               genre %in% input$genre_input) 
  } else {
    
    filtered_games <- game_sales %>% 
      filter(platform %in% input$platform_input)
  }

# if statement to account for the user changing between user or critic score
    if(input$sort_by_input == "User Score") {
      
      filtered_games %>%  
        select(name, platform, user_score) %>%
        slice_max(user_score, n = 5, with_ties = FALSE) %>% 
        mutate(Rank = row_number(), .before = name) %>% 
        rename("Name" = "name",
               "Platform" = "platform",
               "User Score" = "user_score")
      
    } else {
      
      filtered_games %>% 
        select(name, platform, critic_score) %>%
        slice_max(critic_score, n = 5, with_ties = FALSE) %>% 
        mutate(Rank = row_number(), .before = name) %>% 
        rename("Name" = "name",
               "Platform" = "platform",
               "Critic Score" = "critic_score")
    }
  })
  
  
# creation of sales against year plot showing total game sales, sales for selected platform and sales for selected genre.
  output$annual_sales_output <- renderPlot({
    
    combined_data() %>% 
      ggplot(aes(x = year_of_release,
                 y = annual_sales,
                 colour = type_of_sale)) +
      geom_point(size = 4) +
      geom_line() +
      scale_x_continuous(breaks = seq(from = 1985, to = 2020, by = 5)) +
      scale_y_continuous(breaks = seq(from = 0, to = 250, by = 50,
                                      expand = c(0,0))) +
      
      coord_cartesian(clip = "off") +
      scale_colour_manual(values = c("Total" = "red",
                                     "Platform" = "green",
                                     "Genre" = "blue")) +
      labs(x = "Year of Release",
           y = "Annual Sales (£m)\n",
           title = "Annual Game Sales vs Year of Release",
           subtitle = paste("Platform: \t", input$platform_input,
                            "\nGenre: ", input$genre_input),
           colour = "Sale Category") +
      theme_classic() +
      theme(plot.background = element_rect(fill = "#222222",
                                           colour = "#222222"),
            panel.background = element_rect(fill = "#222222"),
            legend.background = element_rect(fill = "#222222",
                                             colour = "white"),
            axis.line = element_line(colour = "white"),
            axis.ticks = element_line(colour = "white"),
            legend.position = c(0.95,0.95),
            text = element_text(colour = "white", face = "bold", size = 16),
            axis.text = element_text(colour = "white", size = 12))
  })
  
## creation of platform sales bar chart, the user selected platform will be highlighted
  output$platform_sales_bar <- renderPlot({
    
    game_sales %>% 
      group_by(platform) %>% 
      summarise(total_sales = sum(sales)) %>% 
      arrange(total_sales) %>% 
      mutate(highlighted = ifelse(platform %in% input$platform_input, T, F)) %>% 
      ggplot(aes(x = total_sales,
                 y = reorder(platform, total_sales),
                 fill = highlighted)) +
      geom_col(show.legend = F) +
      scale_fill_manual(name = "platform", values = c("white","green")) +
      labs(x = "Total Sales (£m)",
           y = "Platform",
           title = "Sales by Platform") +
      theme_classic() +
      theme(plot.background = element_rect(fill = "#222222",
                                           colour = "#222222"),
            panel.background = element_rect(fill = "#222222"),
            legend.background = element_rect(fill = "#222222"),
            axis.line = element_line(colour = "white"),
            axis.ticks = element_line(colour = "white"),
            text = element_text(colour = "white", face = "bold", size = 16),
            axis.text = element_text(colour = "white", size = 12))
  })
  
# creation of genre sales bar chart, the user selected genre will be highlighted
  output$genre_sales_bar <- renderPlot({

    game_sales %>% 
      group_by(genre) %>% 
      summarise(total_sales = sum(sales)) %>% 
      arrange(total_sales) %>% 
      mutate(highlighted = ifelse(genre %in% input$genre_input, T, F)) %>% 
      ggplot(aes(x = total_sales,
                 y = reorder(genre, total_sales),
                 fill = highlighted)) +
      geom_col(show.legend = F) +
      labs(x = "Total Sales (£m)",
           y = "Genre",
           title = "Sales by Genre") +
      scale_fill_manual(name = "genre", values = c("white","blue")) +
      scale_colour_manual(name = "genre", values = c("black", "red")) +
      theme_classic() +
      theme(plot.background = element_rect(fill = "#222222",
                                           colour = "#222222"),
            panel.background = element_rect(fill = "#222222"),
            legend.background = element_rect(fill = "#222222"),
            axis.line = element_line(colour = "white"),
            axis.ticks = element_line(colour = "white"),
            text = element_text(colour = "white", face = "bold", size = 16),
            axis.text = element_text(colour = "white", size = 12))
  })
  

# create a table with total sales, genre sales and platform sales per year
  combined_data <- reactive({
    
    # total sales
    total_sales <- game_sales %>% 
      group_by(year_of_release) %>% 
      summarise(annual_sales = sum(sales)) %>% 
      mutate(type_of_sale = "Total")
    
    # total sales for platform
    platform_sales <- game_sales %>% 
      filter(platform %in% input$platform_input) %>% 
      group_by(year_of_release) %>% 
      summarise(annual_sales = sum(sales)) %>% 
      mutate(type_of_sale = "Platform")
    
    # total sales for genre
    genre_sales <- game_sales %>% 
      filter(genre %in% input$genre_input) %>% 
      group_by(year_of_release) %>% 
      summarise(annual_sales = sum(sales)) %>% 
      mutate(type_of_sale = "Genre")
    
    combined_data <- total_sales %>% 
      bind_rows(platform_sales, genre_sales)
    
  })
  
# determine distinct list of genres used for the user-selected platform input
  genre_choices <- reactive({
    
    game_sales %>%
      filter(platform %in% input$platform_input) %>%
      arrange(genre) %>%
      distinct(genre) %>%
      pull()
    
  })
  
# filter genre input dropdown menu based on selection of platforms
  output$genre_input <- renderUI({
    
    selectInput("genre_input",
                "Select genre?",
                choices = genre_choices(),
                selected = genre_choices() [1],
                # options = list(`actions-box` = TRUE),
                multiple = FALSE)
    
  })

}


# Run the app -------------------------------------------------------------

# Run the application 
shinyApp(ui = ui, server = server)
