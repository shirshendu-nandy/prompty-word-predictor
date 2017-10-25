# Courseera Data Science Capstone

suppressPackageStartupMessages(library(tm))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinythemes))
suppressPackageStartupMessages(library(markdown))

shinyUI(fluidPage( 
        #shinythemes::themeSelector(),
        theme = shinytheme("paper"),
        
        titlePanel(fluidRow(column(6, img(src="prompty_logo2.PNG", height = 300, width = 400, alt = "prompty logo"))
                           ),
                   windowTitle = "prompty"
                  ),

        tabsetPanel( 
                        
                tabPanel("Word predictor",
                        
                        
                     fluidRow(column(6,
                                   br(),
                                   helpText("Start typing below to begin the next word prediction"),
                                   textInput("userInput", "", value = ""),
                                   helpText("Suggested words (in order of most likely to least):"),
                                
                                   div(style="height: 110px;", selectInput("Pred", "", "", multiple= FALSE, selectize = FALSE, size = 3)),
                                   
                                   #uiOutput("static"),
                                   
                                   helpText("You can click on a prediction to use it"),
                                   #br(),
                                   br(),
                                   h6(helpText("c. Shirshendu Nandy (2017)")),
                                   h6(("Powered by"), 
                                           a(href="http://www.r-project.org/", target="_blank","R"),
                                           ("and"), 
                                           a(href="http://shiny.rstudio.com", target="_blank", "RS Shiny."),
                                           br(),
                                           ("Developed for Data Science Specialisation Capstone Project"),
                                           br(),
                                           ("as offered by"),
                                           a(href="http://www.jhsph.edu/", target="_blank","John Hopkins University"),
                                           #br(),
                                           ("on"),
                                           a(href="http://www.coursera.org/specializations/jhu-data-science", target="_blank","Coursera"),
                                           ("with"),
                                           a(href="http://swiftkey.com/en", target="_blank","SwiftKey")
                                       ),
                                   img(src = "logos.PNG", height = 80, width = 240),
                                   align= "left" #"center",
                                    )
                              )
                         ),
                                  
                 tabPanel("Instructions",
                          fluidRow(column(8,  
                                         mainPanel(includeHTML("./about/about.html"))
                                  ))
                         )
        )
        
        
             )
         )