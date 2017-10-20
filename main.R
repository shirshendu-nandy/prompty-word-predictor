## download data

fileURL <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
download.file(fileURL,destfile="Coursera-SwiftKey.zip")
unzip(zipfile="Coursera-SwiftKey.zip")

## load into R
blogs <- readLines("./final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul=TRUE)
twitter <- readLines("./final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul=TRUE)

newsCon <- file("./final/en_US/en_US.news.txt", open = "rb")
news <- readLines(newsCon, encoding = "UTF-8", skipNul=TRUE)
close(newsCon)

#q1q1
file.info("./final/en_US/en_US.blogs.txt")$size/1000000
#q1q2
leangth(twitter)
#q1q3
max(sapply(blogs,nchar))
max(sapply(news,nchar))
max(sapply(twitter,nchar))
#q1q4
length(grep("love",twitter)) / length(grep("hate",twitter))
#q1Q5
read.table("./final/en_US/en_US.twitter.txt",skip= (grep("biostats",twitter) - 1) ,nrow=1)
#q1q6
length(grep("A computer once beat me at chess, but it was no match for me at kickboxing",twitter))

library(stringi)

## File Sizes
Size_MB <- round(file.info(c("./final/en_US/en_US.blogs.txt","./final/en_US/en_US.news.txt","./final/en_US/en_US.twitter.txt"))$size/1024^2) 

## Number of lines per file
Lines <- sapply(list(blogs,news,twitter), length)

## Words per file
blogs_WC <- sum(stri_count_words(blogs))
news_WC <- sum(stri_count_words(news))
twitter_WC <- sum(stri_count_words(twitter))

## Words per line
blogs_WpL <- mean(stri_count_words(blogs))
news_WpL <- mean(stri_count_words(news))
twitter_WpL <- mean(stri_count_words(twitter))

# Data Summary 
summary <- data.frame(
        file = c("blogs", "news", "twitter")
        , file_size_MB = Size_MB
        , num_lines = Lines
        , num_words = c(blogs_WC, news_WC, twitter_WC)
        , words_per_line = c(blogs_WpL, news_WpL, twitter_WpL)
)

# data sampling

library(tm)
library(RWeka)

set.seed(1710)
## 1% samples
blogsS <- sample(blogs, Lines[1]*0.01, replace = F)
newsS  <- sample(news, Lines[2]*0.01, replace = F)
twitterS <- sample(twitter, Lines[3]*0.01, replace = F)
sample1 <- c(blogsS, newsS, twitterS)
## sample length and number of words
length(sample1); sum(stri_count_words(sample1))
## write the sample out 
writeLines(sample1, "./sample1.txt")

# remove objects to free up memory
rm(blogs);rm(news);rm(twitter)
rm(blogsS);rm(newsS);rm(twitterS)

# cleansed sample
# expleted removal

fileURL <- "https://www.freewebheaders.com/wordpress/wp-content/uploads/full-list-of-bad-words-banned-by-google-txt-file.zip"
download.file(fileURL,destfile="full-list-of-bad-words-banned-by-google-txt-file.zip")
unzip(zipfile="full-list-of-bad-words-banned-by-google-txt-file.zip")

## load the expletives
badCon <- file("full-list-of-bad-words-banned-by-google-txt-file_2013_11_26_04_53_31_867.txt", open = "rb")
expletives <- suppressWarnings(readLines(badCon, encoding = "UTF-8", skipNul=TRUE))
close(badCon)

# removing non-ascii characters
expletives <-  iconv(expletives, "latin1", "ASCII", sub="")
sample1 <-  iconv(sample1, "latin1", "ASCII", sub="")

## filter out expletives from the sample
sample1 <- removeWords(sample1,expletives)

# data cleansing

corpus <- Corpus(VectorSource(sample1))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)

toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
#corpus <- tm_map(corpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
corpus <- tm_map(corpus, toSpace, "[^[:graph:]]")
#corpus <- tm_map(corpus, toSpace, "@[^\\s]+")

corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, tolower)

#corpus <- tm_map(corpus, stemDocument)
#corpus <- tm_map(corpus, PlainTextDocument)

# take out the content from the corpus
sampleClean <- get("content", corpus)
# save the clean sample
save("sampleClean",file="sampleClean.Rdata")

rm(sample1); rm(corpus)

# load("sampleClean.Rdata")

suppressMessages(library(quanteda))

# function to create n-grams


tokenizedDF <- function(obj, n) {
        nGramSparse <- dfm(obj, ngrams= n, concatenator = " ")
        nGramDF <- data.frame(Content = featnames(nGramSparse), Frequency = colSums(nGramSparse), 
                              row.names = NULL, stringsAsFactors = FALSE)
}



uniGram <- tokenizedDF(sampleClean, 1)
# sorted
uniGram <- uniGram[order(uniGram$Frequency,decreasing = TRUE),] 
#head(uniGram,10)

biGram <- tokenizedDF(sampleClean, 2)
#sorted
biGram <- biGram[order(biGram$Frequency,decreasing = TRUE),] 


triGram <- tokenizedDF(sampleClean, 3)
#sorted
triGram <- triGram[order(triGram$Frequency,decreasing = TRUE),] 


quadGram <- tokenizedDF(sampleClean, 4)
#sorted
quadGram <- quadGram[order(quadGram$Frequency,decreasing = TRUE),] 


biGram_split <- strsplit(as.character(biGram$Content),split=" ")
biGram <- transform(biGram,first = sapply(biGram_split,"[[",1),second = sapply(biGram_split,"[[",2))
# remove strings that have a frequency of 1
biGram99 <- biGram[biGram$Frequency != 1,]
saveRDS(biGram99,"biGram.RData")
#write_feather(biGram, 'biGram.feather')

triGram_split <- strsplit(as.character(triGram$Content),split=" ")
triGram <- transform(triGram,first = sapply(triGram_split,"[[",1),second = sapply(triGram_split,"[[",2), third = sapply(triGram_split,"[[",3))
# remove strings that have a frequency of 1
triGram99 <- triGram[triGram$Frequency != 1,]
saveRDS(triGram99,"triGram.RData")
#write_feather(triGram, 'triGram.feather')

quadGram_split <- strsplit(as.character(quadGram$Content),split=" ")
quadGram <- transform(quadGram,first = sapply(quadGram_split,"[[",1),second = sapply(quadGram_split,"[[",2), third = sapply(quadGram_split,"[[",3), fourth = sapply(quadGram_split,"[[",4))
# remove strings that have a frequency of 1
quadGram99 <- quadGram[quadGram$Frequency != 1,]
saveRDS(quadGram99,"quadGram.RData") 
#write_feather(quadGram, 'quadGram.feather')

