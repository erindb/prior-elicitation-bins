df = read.table("clean-morebins.results", sep="\t", header=T)
library(rjson)
library(ggplot2)
r = data.frame(x=c(fromJSON(as.character(df$responses))))
ggplot(r, aes(x = x)) + geom_line(stat="density")

df = read.table("clean-bins.results", sep="\t", header=T)
library(rjson)
library(ggplot2)
r = data.frame(x=c(fromJSON(as.character(df$responses))))
ggplot(r, aes(x = x)) + geom_line(stat="density")