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


shinyServer(function(input, output) {
        output$nxtWrd <- renderText({
                nw <- NextWord(input$userInput)
                nw1 <- if((is.na(nw[1])) | (identical(as.character(nw[1]), character(0)))){"the"} else {nw[1]}
                #output$nxtWrdx <- renderText({nw[2:4]})   
                output$nxtWrdx <- renderText({paste(if(is.na(nw[2])){"please"} else {nw[2]}
                                                    ,if(is.na(nw[3])){"will"} else {nw[3]}
                                                    ,if(is.na(nw[4])){"can"} else {nw[4]}
                                                    , sep=" ")
                                              })   
                nw1
        });
        
})
