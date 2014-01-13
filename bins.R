library(rjson)

nbins = 40 # at least

rdata = read.table("~/CoCoLab/prior-elicitation-bins/clean-morebins.results", sep="\t", header=T)

rresponseLists = lapply(as.character(rdata$responses), fromJSON)
indices = unlist(sapply(1:length(rresponseLists), function(i) {
  if (length(rresponseLists[[i]]) > nbins) {
    return(i)
  }
}))
data = rdata[indices,]
responseLists = lapply(as.character(data$responses), function(str) {
  lst = fromJSON(str)
  return(lst/sum(lst)) #could normalize here
  #return(lst)
})
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

items = unique(as.character(data$item))
maxima = sapply(items, function(item) {
  item.data = data[data$item == item,]
  itemResponses = lapply(as.character(item.data$responses), function(str) {
    lst = fromJSON(str)
    return(lst/sum(lst)) #could normalize here
    #return(lst)
  })
  itemLowers = lapply(as.character(item.data$lowers), function(x) {
    if (x == "") {
      return("")
    } else {
      return(fromJSON(x))
    }
  })
  #-1 instead of infty here:
  itemUppers = lapply(as.character(item.data$uppers), function(x) {
    if (x == "") {
      return("")
    } else {
      return(fromJSON(x))
    }
  })
  lowers = itemLowers[[1]]
  uppers = itemUppers[[1]]
  mids = (lowers + uppers) / 2
  nzero = sapply(1:length(lowers), function(i) {
    responses = unlist(sapply(itemResponses, function(itemResponse) {
      return(itemResponse[i])
    }))
    return(sum(responses == 0))
  })
  at.least.2 = which(nzero>=1)
  maximum = at.least.2[at.least.2 > 13][1]
  print(nzero)
  return(maximum)
})
maxima[["laptop"]] = -1

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
  m = maxima[[item]]
  n = length(lowerLists[indices][[1]])
  if (m == -1) {
    m=n
  } else {
    n=m
  }
  responses = sapply(1:n, function(i) {
    mean(sapply(responseLists[indices], function(responseList) {
      return(responseList[i])
    }))
  })[1:m]
  higher = sapply(1:n, function(i) {
    higher.conf(sapply(responseLists[indices], function(responseList) {
      return(responseList[i])
    }))
  })[1:m]
  lower = sapply(1:n, function(i) {
    lower.conf(sapply(responseLists[indices], function(responseList) {
      return(responseList[i])
    }))
  })[1:m]
  lowers = lowerLists[indices][[1]][1:m]
  uppers = upperLists[indices][[1]][1:m]
  if (item == "watch") {
    lowers = lowers[lowers<2000]
    uppers = uppers[lowers<2000]
    responses = responses[lowers<2000]
    watchbounds = c(sapply(1:(length(lowers)-1), function(i) {
      low = lowers[i]
      high = uppers[i]
      newlst = seq(low, high, length.out=26)
      return(newlst[1:(length(newlst)-1)])
    }))
    r = c(sapply(1:(length(lowers)-1), function(i) {
      return(rep(responses[i], 25))
    }))
    responses = r[1:(length(r)-1)]
    h = c(sapply(1:(length(lowers)-1), function(i) {
      return(rep(higher[i], 25))
    }))
    higher = h[1:(length(h)-1)]
    l = c(sapply(1:(length(lowers)-1), function(i) {
      return(rep(lower[i], 25))
    }))
    lower = l[1:(length(l)-1)]
    lowers = watchbounds[1:(length(watchbounds)-1)]
    uppers = watchbounds[2:(length(watchbounds))]
  }
  uppers[length(uppers)] = NaN
  mids = (lowers + uppers) / 2
  mids[length(uppers)] = uppers[length(uppers)-1] + (mids[1]-lowers[1])
  plot(mids, responses, main=item, ylim=c(0,max(higher)))
  par(new=T)
  plot(mids, responses, type="l", ylab="", xlab="", yaxt="n", xaxt="n", ylim=c(0,max(higher)))
  error.bar(mids, responses, higher, lower)
  par(new=F)
  bin = list(mids=mids, probs=responses)
}


bins = lapply(items, getBins)
names(bins) = items

for (item in items) {
  print(item)
  print(bins[[item]]$mids)
  print(bins[[item]]$probs)
}