This report is developed for the Week 2 assignment of Coursera Data
Science Specialization's Capstone project. The project aims to create a
predictive text model using three large training text data sets with
Natural language processing(NLP) techniques. For this milestone report-
I've performed the following tasks:

1.  Download the data and have it loaded successfully.
2.  Generate a basic summary statistics about the data sets.
3.  Create a unified document corpus and perform data cleansing
4.  Exploratory analysis and report any interesting findings.
5.  Develop a plan and next steps for creating a prediction model and
    Shiny app.

1. Download and load the data in R
==================================

Data is available here :
<https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip>.

    ## download data

    fileURL <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
    download.file(fileURL,destfile="Coursera-SwiftKey.zip")
    unzip(zipfile="Coursera-SwiftKey.zip")

Looking into the downloaded files, the data sets are in four languages -
German (de\_DE), English (en\_EN), French (fi\_FI) and Russian (ru\_RU).
In my assigment, I'll be using the English datasets. There are text data
from three sources - blogs, news and twitter. Next step is to load these
data into R objects.

While the readLines function works for the blogs and twitter data, it
was throwing an error for the news file. For this file, I had to employ
an workaround using connections function.

    blogs <- readLines("./final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul=TRUE)
    twitter <- readLines("./final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul=TRUE)

    newsCon <- file("./final/en_US/en_US.news.txt", open = "rb")
    news <- readLines(newsCon, encoding = "UTF-8", skipNul=TRUE)
    close(newsCon)

2. Summary statistics about the data sets
=========================================

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

    # Summary 
    summary <- data.frame(
                         file = c("blogs", "news", "twitter")
                       , file_size_MB = Size_MB
                       , num_lines = Lines
                       , num_words = c(blogs_WC, news_WC, twitter_WC)
                       , words_per_line = c(blogs_WpL, news_WpL, twitter_WpL)
                         )

    library(knitr)
    kable(summary)

<table>
<thead>
<tr class="header">
<th align="left">file</th>
<th align="right">file_size_MB</th>
<th align="right">num_lines</th>
<th align="right">num_words</th>
<th align="right">words_per_line</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">blogs</td>
<td align="right">200</td>
<td align="right">899288</td>
<td align="right">37546246</td>
<td align="right">41.75108</td>
</tr>
<tr class="even">
<td align="left">news</td>
<td align="right">196</td>
<td align="right">1010242</td>
<td align="right">34762395</td>
<td align="right">34.40997</td>
</tr>
<tr class="odd">
<td align="left">twitter</td>
<td align="right">159</td>
<td align="right">2360148</td>
<td align="right">30093410</td>
<td align="right">12.75065</td>
</tr>
</tbody>
</table>

3. Data preparation
===================

As observed above, these files are quite large. For exploratory
analysis, i've decided to sample 10% of these datasets and then
concatenating them into one single data source for cleasing and
exploration.

    library(tm)

    ## Loading required package: NLP

    library(RWeka)

    set.seed(1710)
    ## 1% samples
    blogsS <- sample(blogs, Lines[1]*0.1, replace = F)
    newsS  <- sample(news, Lines[2]*0.1, replace = F)
    twitterS <- sample(twitter, Lines[3]*0.1, replace = F)
    sample1 <- c(blogsS, newsS, twitterS)
    ## sample length and number of words
    length(sample1); sum(stri_count_words(sample1))

    ## [1] 426966

    ## [1] 10221889

    ## write the sample out 
    writeLines(sample1, "./sample1.txt")

    # remove objects to free up memory
    rm(blogs);rm(news);rm(twitter)
    rm(blogsS);rm(newsS);rm(twitterS)

My sample data set has about 400K lines and contains nearly 10 million
words.

First step is to perform some data clensing activitiy to get rid of
english expletives; For removing the expletives, I've utilized a file
available here :
<https://www.freewebheaders.com/wordpress/wp-content/uploads/full-list-of-bad-words-banned-by-google-txt-file.zip>

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

Next, I've used the tm package to perform various data cleansing
activities such as removing special characters, punctuations, numbers,
excess whitespace, english stopwords, performing lower case conversion.

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

4. Exploratory analysis
=======================

Word Cloud
----------

    library(wordcloud)

    ## Loading required package: RColorBrewer

    suppressWarnings(wordcloud(sampleClean, max.words = 500, random.order = FALSE, colors=brewer.pal(9, "RdYlGn")))

![](Milestone_Report_files/figure-markdown_strict/wrd_cloud-1.png)

N-Grams
-------

Next, I will be calculating the n-grams, "a contiguous sequence of n
items from a given sequence of text or speech", to see the words that
occur together most frequently.

Initially, I've trived using the functions available within "tm"
pacakage, but was running into memory constrains. On the contrary, the
"quanteda" package was quite fast and I've chosen to use this package
for the n-gram generations.

Unigrams
--------

    suppressMessages(library(quanteda))

    ## Warning: package 'quanteda' was built under R version 3.4.2

    # function to create n-grams


    tokenizedDF <- function(obj, n) {
            nGramSparse <- dfm(obj, ngrams= n, concatenator = " ")
            nGramDF <- data.frame(Content = featnames(nGramSparse), Frequency = colSums(nGramSparse), 
                     row.names = NULL, stringsAsFactors = FALSE)
                    }

    # function to plot the top 10 n-grams
    library(ggplot2)

    ## 
    ## Attaching package: 'ggplot2'

    ## The following object is masked from 'package:NLP':
    ## 
    ##     annotate

    top10Plot <- function(df, title) {
              ggplot(df[1:10,], aes(reorder(Content, Frequency), Frequency)) +
              labs(x = "Word(s)", y = "Frequency") +
              theme(axis.text.x = element_text(angle = 90, size = 10, hjust = 1)) + 
              coord_flip() + 
              ggtitle(title) +
              geom_bar(stat = "identity", fill = I("purple4"))
              }


    # uni-gram
    uniGram <- tokenizedDF(sampleClean, 1)
    # sorted
    uniGram <- uniGram[order(uniGram$Frequency,decreasing = TRUE),] 
    #head(uniGram,10)

    #plot top 10
    top10Plot(uniGram, "Top 10 unigrams")

![](Milestone_Report_files/figure-markdown_strict/uniG-1.png)

Bigrams
-------

    biGram <- tokenizedDF(sampleClean, 2)
    #sorted
    biGram <- biGram[order(biGram$Frequency,decreasing = TRUE),] 
    #plot top 10
    top10Plot(biGram, "Top 10 bigrams")

![](Milestone_Report_files/figure-markdown_strict/biG-1.png)

Trigrams
--------

    triGram <- tokenizedDF(sampleClean, 3)
    #sorted
    triGram <- triGram[order(triGram$Frequency,decreasing = TRUE),] 
    #plot top 10
    top10Plot(triGram, "Top 10 trigrams")

![](Milestone_Report_files/figure-markdown_strict/triG-1.png)

Quadgrams
---------

    quadGram <- tokenizedDF(sampleClean, 4)
    #sorted
    quadGram <- quadGram[order(quadGram$Frequency,decreasing = TRUE),] 
    #plot top 10
    top10Plot(quadGram, "Top 10 quadgrams")

![](Milestone_Report_files/figure-markdown_strict/quadG-1.png)

5. Way forward
==============

In order to increase the efficincy of the shiny app, I think it will be
a good idea to have the n-grams generated and saved prior rather than
generating the n-grams in the run time which will results in bad user
experience. Based on my research, "stupid Backoff" strategy seems like a
good fit for developing the model i.e. to start with the quadgrams to
see if there is a match with the first three words, then use the fourth
word of the quadgram as the predicted word, if no match found then
falling back to bigrams and so on.

For exploratory reasons, though I've taken eglish stopwords out, in the
final n-grams that I plan to use for the word predictor, I won't be
filtering out the stopwords.

    sessionInfo()

    ## R version 3.4.1 (2017-06-30)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 10 x64 (build 14393)
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_Australia.1252  LC_CTYPE=English_Australia.1252   
    ## [3] LC_MONETARY=English_Australia.1252 LC_NUMERIC=C                      
    ## [5] LC_TIME=English_Australia.1252    
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] ggplot2_2.2.1      quanteda_0.99.12   wordcloud_2.5     
    ## [4] RColorBrewer_1.1-2 RWeka_0.4-34       tm_0.7-1          
    ## [7] NLP_0.1-11         knitr_1.17         stringi_1.1.5     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_0.12.12        compiler_3.4.1      highr_0.6          
    ##  [4] plyr_1.8.4          tools_3.4.1         RWekajars_3.9.1-3  
    ##  [7] digest_0.6.12       lubridate_1.6.0     evaluate_0.10.1    
    ## [10] tibble_1.3.3        gtable_0.2.0        lattice_0.20-35    
    ## [13] rlang_0.1.2         Matrix_1.2-10       fastmatch_1.1-0    
    ## [16] yaml_2.1.14         parallel_3.4.1      rJava_0.9-8        
    ## [19] stringr_1.2.0       rprojroot_1.2       grid_3.4.1         
    ## [22] data.table_1.10.4   rmarkdown_1.6       magrittr_1.5       
    ## [25] backports_1.1.0     scales_0.4.1        htmltools_0.3.6    
    ## [28] colorspace_1.3-2    labeling_0.3        RcppParallel_4.3.20
    ## [31] lazyeval_0.2.0      munsell_0.4.3       slam_0.1-40

References
==========

Expletives List
<https://www.freewebheaders.com/wordpress/wp-content/uploads/full-list-of-bad-words-banned-by-google-txt-file.zip>

Introduction to the tm Package Text Mining in R
<https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf>

quanteda: Quantitative Analysis of Textual Data
<http://pnulty.github.io/>

n-gram <https://en.wikipedia.org/wiki/N-gram>

smoothing+backoff-1
<https://www.cs.cornell.edu/courses/CS4740/2012sp/lectures/smoothing+backoff-1-4pp.pdf>
