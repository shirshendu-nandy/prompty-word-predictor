# Courseera Data Science Capstone

suppressPackageStartupMessages(library(tm))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinythemes))
suppressPackageStartupMessages(library(markdown))


#source("util/NextWord.R")
source("util/NextWordx.R")

# Load Quadgram,Trigram & Bigram objects
#quadGram <- readRDS(file="./grams/quadGram.RData");
#triGram <- readRDS(file="./grams/triGram.RData");
#biGram <- readRDS(file="./grams/biGram.RData");

Pred <<- ""



# shinyServer(function(input, output) {
#         output$nxtWrd <- renderText({
#                 nw <- NextWord(input$userInput)
#                 nw
#         });
# 
# })


shinyServer(function(input, output, session) {
        observe({
                
                phrase <- input$userInput
                choices <- input$Pred
                
                if (!is.null(choices) && choices != "") {
                        # Can also set the label and select items
                        updateTextInput(session, "userInput", value = paste(trimws(phrase), choices))
                }
                
                if (!is.null(phrase)) {
                        # Can also set the label and select items
                        nw <- NextWord(phrase)
                        nw <- if((is.na(nw[1])) | (identical(as.character(nw[1]), character(0)))){input$userInput} else {nw}
                        updateSelectInput(session, "Pred",
                                           choices = nw)
                        
                        # output$static = renderText({paste(if(is.na(nw[1])){""} else {nw[1]}
                        #                                 ,if(is.na(nw[2])){""} else {nw[2]}
                        #                                 ,if(is.na(nw[3])){""} else {nw[3]}
                        #                                 ,if(is.na(nw[4])){""} else {nw[4]}
                        #                                 , sep=" ")
                        #                                 })
                }
                
               
        });
        
})
