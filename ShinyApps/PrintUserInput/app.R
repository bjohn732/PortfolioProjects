####################################
# Data Professor                   #
# http://youtube.com/dataprofessor #
# http://github.com/dataprofessor  #
####################################

# Modified from Winston Chang, 
# https://shiny.rstudio.com/gallery/shiny-theme-selector.html

# Concepts about Reactive programming used by Shiny, 
# https://shiny.rstudio.com/articles/reactivity-overview.html

# Load R packages
library(shiny)
library(bslib)
library(shinythemes)


  # Define UI
  ui <- fluidPage(theme = bslib::bs_theme(version = 4, bootswatch = "yeti"),
    navbarPage(
      # theme = "cerulean",  # <--- To use a theme, uncomment this
      "Print User Input App",
      tabPanel("Navbar 1",
               sidebarPanel(
                 tags$h1("Input:"),
                 textInput("txt1", "Given Name:", ""), # txt1 will be sent to the server
                 textInput("txt2", "Surname:", ""),    # txt2 will be sent to the server
                 
               ), # sidebarPanel
               mainPanel(
                            h1("Header 1"),
                            
                            h3("Output 1"),
                            verbatimTextOutput("txtout"), # txtout is generated from the server

               ) # mainPanel
               
      ), # Navbar 1, tabPanel
      tabPanel("Navbar 2", "This panel is intentionally left blank"),
      tabPanel("Navbar 3", "This panel is intentionally left blank")
  
    ) # navbarPage
  ) # fluidPage

  
  # Define server function  
  server <- function(input, output) {
    
    output$txtout <- renderText({
      paste( input$txt1, input$txt2, sep = " " )
    })
  } # server
  

  # Create Shiny object
  shinyApp(ui = ui, server = server)
