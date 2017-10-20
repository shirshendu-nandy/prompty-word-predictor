suppressPackageStartupMessages(library(tm))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinythemes))
suppressPackageStartupMessages(library(markdown))

quadGram <- readRDS(file="./grams/quadGram.RData");
triGram <- readRDS(file="./grams/triGram.RData");
biGram <- readRDS(file="./grams/biGram.RData");


# next word predictor function
NextWord <- function(userInput) {
        
        inputClean <- removeNumbers(removePunctuation(tolower(userInput)))
        inputClean <- strsplit(inputClean, " ")[[1]]
        
        
        if (length(inputClean)>= 3) 
        {
                inputClean <- tail(inputClean,3)
                if (identical(as.character(head(quadGram[quadGram$first == inputClean[1] & quadGram$second == inputClean[2] & quadGram$third == inputClean[3], 6],1)), character(0)))
                {NextWord(paste(inputClean[2],inputClean[3],sep=" "))}
                else {Pred <<- as.character(head(quadGram[quadGram$first == inputClean[1] & quadGram$second == inputClean[2] & quadGram$third == inputClean[3], 6],4))
                      #Predx <<- as.character(tail(head(quadGram[quadGram$first == inputClean[1] & quadGram$second == inputClean[2] & quadGram$third == inputClean[3], 6],4),3))
                     }
        } 
        
        else if (length(inputClean) == 2)
        {
                if (identical(as.character(head(triGram[triGram$first == inputClean[1] & triGram$second == inputClean[2], 5],1)), character(0)))
                { NextWord( inputClean[2]) }
                else {Pred <<- as.character(head(triGram[triGram$first == inputClean[1] & triGram$second == inputClean[2], 5],4))
                      #Predx <<- as.character(tail(head(triGram[triGram$first == inputClean[1] & triGram$second == inputClean[2], 5],4),3))
                     }
        }
        
        else if (length(inputClean) <= 1)
        {
                if (identical(as.character(head(biGram[biGram$first == inputClean[1], 4],1)) , character(0))) 
                {Pred <<-c("the", "", "", "")
                 #Predx <<- c("please", "will", "can")
                }
                else {Pred <<- as.character(head(biGram[biGram$first == inputClean[1],4],4))
                      #Predx <<- as.character(tail(head(biGram[biGram$first == inputClean[1],4],4),3))
                      }
        }
        
}