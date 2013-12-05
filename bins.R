library(rjson)

nbins = 40

rdata = read.table("~/CoCoLab/prior-elicitation-bins/clean-morebins.results", sep="\t", header=T)

print("hi")

rresponseLists = lapply(as.character(rdata$responses), fromJSON)
indices = unlist(sapply(1:length(rresponseLists), function(i) {
  if (length(rresponseLists[[i]]) > nbins) {
    return(i)
  }
}))
data = rdata[indices,]
responseLists = lapply(as.character(data$responses), fromJSON)
nsubj = length(unique(data$subj))
lowerLists = lapply(as.character(data$lowers), function(x) {
  if (x == "") {
    return("")
  } else {
    return(fromJSON(x))
  }
})
#-1 instead of infty here:
upperLists = lapply(as.character(data$uppers), function(x) {
  if (x == "") {
    return("")
  } else {
    return(fromJSON(x))
  }
})

conf <- function(v) {
  v <- v[is.na(v) == F]
  sample.means <- replicate(1000, mean(sample(v, nsubj, replace=TRUE)))
  return(quantile(sample.means, c(0.025, 0.975)))
}
lower.conf <- function(v) {
  conf(v)[["2.5%"]]
}
higher.conf <- function(v) {
  conf(v)[["97.5%"]]
}
error.bar <- function(x, y, upper, lower=upper, lw=2, col="black", length=0.1,...){
  if(length(x) != length(y) | length(y) !=length(lower) | length(lower) != length(upper))
    stop("vectors must be same length")
  #arrows(x, upper, x, lower, angle=90, code=3, lwd=2, col=col, length=length, ...)
  segments(x, upper, x, lower, col=col, lw=lw, ...)
}

getBins = function(item) {
  indices = data$item == item & data$qType == "prob"
  responses = sapply(1:nbins, function(i) {
    mean(sapply(responseLists[indices], function(responseList) {
      return(responseList[i])
    }))
  })
  higher = sapply(1:nbins, function(i) {
    higher.conf(sapply(responseLists[indices], function(responseList) {
      return(responseList[i])
    }))
  })
  lower = sapply(1:nbins, function(i) {
    lower.conf(sapply(responseLists[indices], function(responseList) {
      return(responseList[i])
    }))
  })
  lowers = lowerLists[indices][[1]]
  uppers = upperLists[indices][[1]]
  uppers[length(uppers)] = NaN
  mids = (lowers + uppers) / 2
  mids[length(uppers)] = uppers[length(uppers)-1] + (mids[1]-lowers[1])
  plot(mids, responses, main=item, ylim=c(0,1))
  par(new=T)
  plot(mids, responses, ylim=c(0,1), type="l", ylab="", xlab="", yaxt="n", xaxt="n")
  error.bar(mids, responses, higher, lower)
  par(new=F)
  bin = list(mids=mids, probs=responses)
}

items = unique(as.character(data$item))
bins = lapply(items, getBins)
names(bins) = items

for (item in items) {
  print(item)
  print(bins[[item]])
}