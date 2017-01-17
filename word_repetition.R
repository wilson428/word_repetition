# install.packages("gutenbergr")
# install.packages("tokenizers")
# install.packages("ggplot2")

source("lib/text_utils.R")

# let's give it a try with a few titles
get_ids("Moby Dick")
tokens <- get_text("2489")
intervals <- get_intervals(tokens, 5)
plot_intervals(intervals, "Moby Dick", "moby_dick")

get_ids("King James")
tokens <- get_text("30")
intervals <- get_intervals(tokens, 25)
plot_intervals(intervals, "The King James Bible", "kjb")

get_ids("Ulysses")
tokens <- get_text("4300")
intervals <- get_intervals(tokens, 5)
plot_intervals(intervals, "Ulysses", "ulysses")

get_ids("Pride and Prejudice")
tokens <- get_text("1342")
intervals <- get_intervals(tokens, 5)
plot_intervals(intervals, "Pride and Prejudice", "pride_and_prejudice")

get_ids("Sherlock Holmes")
tokens <- get_text("1661")
intervals <- get_intervals(tokens, 2)
plot_intervals(intervals, "Sherlock Holmes", "sherlock_holmes")
