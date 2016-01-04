import json
import re

f = open("three-domain-bins.results", "r")
w = open("BasicAdjectiveModel-OtherAdjectives.tsv", "w")
w.write("\t".join(["subj", "condtion", "comments", "age", "duration", "cond", "language",
	               "qNum", "qType", "item", "maximum", "responses", "buyer", "lowers", "uppers"]))
w.close()
w = open("BasicAdjectiveModel-OtherAdjectives.tsv", "a")
header = []

sep = "\t"

subjNums = {}
def subjNum(elem):
	if not elem in subjNums.keys():
		subjNums[elem] = str(len(subjNums))
	return subjNums[elem]

def cutFirstAndLast(x, i=1, j=1):
	return x[i:(len(x)-j)]

def tameQuotes(x):
	return re.sub("\"\"\"?", "\"", x)

for line in f:
	row = line.split(sep)

	# data per subject:
	subj = ""
	comments = ""
	age = ""
	duration = ""
	cond = ""
	language = ""
	qNums = []
	qTypes = []
	items = []
	maxima = []
	buyers = []
	lowerLists = []
	upperLists = []
	responseLists = []

	# get subj data from csv:
	if len(header) == 0:
		header = map(cutFirstAndLast, row)
	else:
		for i in range(len(row)):
			heading = header[i]
			elem = row[i]
			if heading == "workerid":
				subj = subjNum(elem) #SUBJECT NUMBER
			elif heading == "Answer.comments":
				comments = elem #COMMENTS
			elif heading == "Answer.condition":
				condition = elem
			elif heading in map(lambda x: "Answer."+str(x), range(1,10)) and len(elem)>0:
				qNum = int(heading.split(".")[1])
				qNums.append("q" + str(qNum)) #QUESTION NUMBER (ORDERING)
				if qNum >= 5:
					qType = "max"
				else:
					qType = "prob"
				qTypes.append(qType) #QUESTION TYPE (MAX OR PROB)
				#print tameQuotes(elem)
				qData = json.loads(tameQuotes(cutFirstAndLast(elem)))
				item = qData["item"]
				items.append(item) #ITEM
				if qType == "max":
					maximum = qData["response"]
					buyer = ""
					stepLength = ""
					lowers = ""
					uppers = ""
				else:
					buyer = qData["buyer"]
					lowers = "[" + ",".join(map( str, qData["lowers"])) + "]"
					uppers = re.sub("infty", "-1", "[" + ",".join(map (str, qData["uppers"])) + "]")
					responses = "[" + ",".join(map (str, qData["responses"])) + "]"
					maximum = ""
				responseLists.append(responses)
				buyers.append(buyer)
				lowerLists.append(lowers)
				upperLists.append(uppers)
				maxima.append(maximum)
			elif heading == "Answer.age":
				age = cutFirstAndLast(elem, 2, 2)
			elif heading == "Answer.duration":
				duration = elem
			elif heading == "Answer.cond":
				cond = cutFirstAndLast(elem, 2, 2)
			elif heading == "language":
				language = elem

	# print long form for subj data:
	for i in range(len(qNums)):
		w.write("\n")
		new_row = "\t".join([subj, condition, comments, age, duration, cond, language] +
			                map(lambda x: x[i],
			                	[qNums, qTypes, items, maxima, responseLists, buyers, lowerLists, upperLists]))
		w.write(new_row)

f.close()
w.close()
