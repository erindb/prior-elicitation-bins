# watch = read.table("webchurch_prices/watch-prices.txt")$V1
laptop = read.table("webchurch_prices/laptop-prices.txt")$V1
coffee = read.table("webchurch_prices/coffee-prices.txt")$V1
sweater = read.table("webchurch_prices/sweater-prices.txt")$V1
headphones = read.table("webchurch_prices/headphones-prices.txt")$V1

library(rjson)

conf <- function(v) {
  v <- v[is.na(v) == F]
  nsubj=20
  sample.means <- replicate(100, mean(sample(v, nsubj, replace=TRUE)))
  return(quantile(sample.means, c(0.025, 0.975)))
}
lower.conf <- function(v) {
  conf(v)[["2.5%"]]
}
higher.conf <- function(v) {
  conf(v)[["97.5%"]]
}

rrdata = read.table("~/CoCoLab/prior-elicitation-bins/clean-morebins.results", sep="\t", header=T)

nbins = 40 # at least
rresponseLists = lapply(as.character(rrdata$responses), fromJSON)
indices = unlist(sapply(1:length(rresponseLists), function(i) {
  if (length(rresponseLists[[i]]) > nbins) {
    return(i)
  }
}))
rdata = rrdata[indices,]

posterior.data = rdata[as.numeric(as.character(rdata$subj))>19,]
prior.data = rdata[as.numeric(as.character(rdata$subj))<20,]

items = unique(rdata$item)

posterior.responses = list()
posterior.lowerconf = list()
posterior.higherconf = list()
for (item in items) {
	data = posterior.data[posterior.data$item == item,]
	responseLists = lapply(as.character(data$responses), fromJSON)
	posterior.responses[[item]] = sapply(1:(length(responseLists[[1]])-1), function(i) {
		return(mean(unlist(sapply(responseLists, function(rlist) {
			return(rlist[[i]])
		}))))
	})
	posterior.lowerconf[[item]] = sapply(1:(length(responseLists[[1]])-1), function(i) {
		return(lower.conf(unlist(sapply(responseLists, function(rlist) {
			return(rlist[[i]])
		}))))
	})
	posterior.higherconf[[item]] = sapply(1:(length(responseLists[[1]])-1), function(i) {
		return(higher.conf(unlist(sapply(responseLists, function(rlist) {
			return(rlist[[i]])
		}))))
	})
}

prior.responses = list()
prior.lowerconf = list()
prior.higherconf = list()
for (item in items) {
	data = prior.data[prior.data$item == item,]
	responseLists = lapply(as.character(data$responses), fromJSON)
	prior.responses[[item]] = sapply(1:(length(responseLists[[1]])-1), function(i) {
		return(mean(unlist(sapply(responseLists, function(rlist) {
			return(rlist[[i]])
		}))))
	})
	prior.lowerconf[[item]] = sapply(1:(length(responseLists[[1]])-1), function(i) {
		return(lower.conf(unlist(sapply(responseLists, function(rlist) {
			return(rlist[[i]])
		}))))
	})
	prior.higherconf[[item]] = sapply(1:(length(responseLists[[1]])-1), function(i) {
		return(higher.conf(unlist(sapply(responseLists, function(rlist) {
			return(rlist[[i]])
		}))))
	})
}

prices = list()
for (item in items) {
	data = rdata[rdata$item == item,]
	lowerLists = lapply(as.character(data$lowers), fromJSON)
	upperLists = lapply(as.character(data$uppers), fromJSON)
	n = length(lowerLists[[1]]) - 1
	prices[[item]] = (lowerLists[[1]][1:n] + upperLists[[1]][1:n])/2
}

item="watch"
item.ymax=0.8
item.xmax=2925
model=watch
png(paste(c("graphs/",item,".png"),collapse=""), 500, 300)
# hist(watch, xlim=c(0,2925), yaxt="n")
# par(new=T)
plot(prices[[item]], posterior.responses[[item]], type="l", xlim=c(0,item.xmax), ylim=c(0,item.ymax), ylab="", xlab="", col="red", main=item)
par(new=T)
polygon(c(prices[[item]],rev(prices[[item]])), c(posterior.lowerconf[[item]], rev(posterior.higherconf[[item]])), col="pink", border=NA, density=50)
polygon(c(prices[[item]],rev(prices[[item]])), c(prior.lowerconf[[item]], rev(prior.higherconf[[item]])), col="lightblue", border=NA, density=50)
par(new=T)
plot(prices[[item]], posterior.responses[[item]], type="l", xlim=c(0,item.xmax), ylim=c(0,item.ymax), ylab="", xlab="", col="red", main="")
par(new=T)
plot(prices[[item]], prior.responses[[item]], type="l", xlim=c(0,item.xmax), ylim=c(0,item.ymax), ylab="", xlab="", col="blue")
legend(x="topright", legend=c("prior", "posterior"), fill=c("blue", "red"))
dev.off()

plot.stuff=function(item, item.ymax, item.xmax, model) {
	png(paste(c("graphs/",item,".png"),collapse=""), 500, 300)
	plot(prices[[item]], posterior.responses[[item]], type="l", xlim=c(0,item.xmax), ylim=c(0,item.ymax), ylab="", xlab="", yaxt="n", col="red", main=item)
	par(new=T)
	polygon(c(prices[[item]],rev(prices[[item]])), c(prior.lowerconf[[item]], rev(prior.higherconf[[item]])), col="lightblue", border=NA, density=50)
	polygon(c(prices[[item]],rev(prices[[item]])), c(posterior.lowerconf[[item]], rev(posterior.higherconf[[item]])), col="pink", border=NA, density=50)
	par(new=T)
	plot(prices[[item]], posterior.responses[[item]], type="l", xlim=c(0,item.xmax), ylim=c(0,item.ymax), ylab="", yaxt="n", xlab="", col="red", main="")
	par(new=T)
	plot(prices[[item]], prior.responses[[item]], type="l", xlim=c(0,item.xmax), ylim=c(0,item.ymax), ylab="", yaxt="n", xlab="", col="blue")
	par(new=T)
	hist(model, xlim=c(0,item.xmax), yaxt="n", main="", xlab="", breaks=300)
	legend(x="topright", legend=c("prior", "posterior"), fill=c("blue", "red"))
	dev.off()
}
plot.stuff("laptop", 0.9, 2425, laptop)
plot.stuff("coffee maker", 0.8, 266, coffee)
plot.stuff("sweater", 0.8, 235.5, sweater)
plot.stuff("headphones", 0.9, 321, headphones)