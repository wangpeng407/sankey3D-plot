library(networkD3)
library(htmlwidgets)

links <- read.table("output/link.sankey.txt", header = TRUE, sep = "\t")
nodes <- read.table("output/node.sankey.txt", header = F, sep = "\t")

# names(links) = c("source", "target", "value")
# links <- data.frame(links$target, links$source, links$value)
names(links) = c("source", "target", "value")
links$source <- as.numeric(links$source)
links$target <- as.numeric(links$target)

names(nodes) <- 'name'

p <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "source", Target = "target",
                   Value = "value", NodeID = "name",
                   fontSize= 12, nodeWidth = 30)
p
saveWidget(p, file='sankey-top15-species.html')

