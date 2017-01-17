library(tokenizers)
library(gutenbergr)
library(ggplot2)

books <- gutenberg_metadata
books <- subset(books, books$rights=="Public domain in the USA." & books$language=="en" & books$has_text == TRUE)

get_ids <- function(title) {
  volumes = books[grep(title, books$title, ignore.case = TRUE), ]
  if (NROW(volumes) == 0) {
    print(paste("Sorry, couldn't find any title matches for '", title, "'", sep=""))
  } else {
    print(paste("Found", NROW(volumes), "match(es) for", title));
    for (i in 1:NROW(volumes)) {
      print(paste("--'", volumes[i,]$title, "' by ", volumes[i,]$author, " (id #", volumes[i,]$gutenberg_id, ")", sep=""))
    }
    print("Please choose one and enter the id in get_text()");
  }  
}

get_text <- function(g_id) {
  volume = books[books$gutenberg_id==g_id, ]
  print(paste("Loading '", volume$title, "' by ", volume$author, sep=""))

  lines = gutenberg_download(as.numeric(volume$gutenberg_id))
  text  = paste(lines$text, collapse = ' ')
  tokens = tokenize_words(text, lowercase=TRUE, simplify = TRUE)
  print(paste("Found ", prettyNum(length(tokens), big.mark = ","), " words in '", volume$title, "'", sep=""))
  return(tokens)
}

get_intervals <- function(tokens, min_frequency=10) {
  indices = data.frame(word = tokens, index=seq(length(tokens)))
  
  frequencies = setNames(as.data.frame(table(tokens), stringsAsFactors = F), c("word", "frequency"))
  frequencies = subset(frequencies, frequencies$frequency >= min_frequency)
  
  words = frequencies$word
  
  progress_index <- 0
  pb <- txtProgressBar(min = 0, max = length(words), initial = progress_index, style=3)
  
  print(paste("Calculating intervals for ", prettyNum(length(words), big.mark = ","), " words, which might take a minute.", sep=""))
  
  get_word_interval <- function(indices, word) {
    index = indices$index[indices$word==word]
    intervals = diff(index)
    progress_index <<- progress_index + 1
    setTxtProgressBar(pb, progress_index)
    
    return(list(
      word = word,
      frequency = length(index),
      min = min(intervals),
      max = max(intervals),
      mean = mean(intervals),
      median = median(intervals),
      sd = sd(intervals)
    ))  
  }  
  
  data <- as.data.frame(do.call(rbind, sapply(words, get_word_interval, indices=indices, simplify=FALSE)))
  rownames(data) <- NULL
  
  return(data)
}

plot_intervals <- function(intervals, title, directory_name=NULL) {
  # median
  plot_median <- qplot(
    as.numeric(intervals$frequency),
    as.numeric(intervals$median),
    log = "xy",
    xlab = "frequency (log)",
    ylab = "interval median (log)",
    main = paste("Median Interval by Frequency in '", title, "'", sep=""),
    size = I(0.25)
  ) + theme(plot.title = element_text(hjust = 0.5))
  
  # mean
  plot_mean <- qplot(
    as.numeric(intervals$frequency),
    as.numeric(intervals$mean),
    log = "xy",
    xlab = "frequency (log)",
    ylab = "interval average (log)",
    main = paste("Mean Interval by Frequency in '", title, "'", sep=""),
    size = I(0.25)
  ) + theme(plot.title = element_text(hjust = 0.5))

  # min
  plot_min <- qplot(
    as.numeric(intervals$frequency),
    as.numeric(intervals$min),
    log = "xy",
    xlab = "frequency (log)",
    ylab = "interval minimum (log)",
    main = paste("Minimum Interval by Frequency in '", title, "'", sep=""),
    size = I(0.25)
  ) + theme(plot.title = element_text(hjust = 0.5))

  # max
  plot_max <- qplot(
    as.numeric(intervals$frequency),
    as.numeric(intervals$max),
    log = "xy",
    xlab = "frequency (log)",
    ylab = "interval maximum (log)",
    main = paste("Max Interval by Frequency in '", title, "'", sep=""),
    size = I(0.25)
  ) + theme(plot.title = element_text(hjust = 0.5))
  
  # sd
  sds <- subset(intervals, !is.na(intervals$sd))
  plot_sd <- qplot(
    as.numeric(sds$frequency),
    as.numeric(sds$sd),
    log = "xy",
    xlab = "frequency (log)",
    ylab = "interval sd (log)",
    main = paste("Interval Standard Deviation by Frequency in '", title, "'", sep=""),
    size = I(0.25)
  ) + theme(plot.title = element_text(hjust = 0.5))
  
  print(plot_sd)
  print(plot_min)
  print(plot_max)
  print(plot_mean)
  print(plot_median)

  if (!is.null(directory_name)) {
    dir.create(file.path(paste(getwd(), "/data", sep=""), directory_name), showWarnings = FALSE)

    png(paste("data/", directory_name, "/median.png", sep=""))
    print(plot_median)
    dev.off()

    png(paste("data/", directory_name, "/mean.png", sep=""))
    print(plot_mean)
    dev.off()

    png(paste("data/", directory_name, "/min.png", sep=""))
    print(plot_min)
    dev.off()
    
    png(paste("data/", directory_name, "/max.png", sep=""))
    print(plot_max)
    dev.off()
    
    png(paste("data/", directory_name, "/sd.png", sep=""))
    print(plot_sd)
    dev.off()
  }
}
