title: "Mutli-Touch Attribution Modelv1"
setwd("/Users/tiffanyblakeney/Documents_local/R Data")
library(splitstackshape)
library(drat)
library(tidyverse)
library(ggplot2)
library(reshape2)
library(ggthemes)
library(ggrepel)
library(RColorBrewer)
library(ChannelAttribution)
library(markovchain)
library(visNetwork)
library(expm)
library(stringr)
library(purrrlyr)
library(ggsn)
library(lubridate)


#Read the data into R

MyData <- read.csv("channels_june_path.csv", header = T)


#Data Prep
##rename columns
#names(MyData) <- c("user_id","from_time","to_time","conversion", "null", "path")
MyData$path <- as.character(factor(MyData$path))

MyData$null <- as.numeric(MyData$null)
MyData$conversions <- as.numeric(MyData$conversions)
MyData$from_time <-as.Date(MyData$from_time, format = "%m/%d/%y")
MyData$to_time <-as.Date(MyData$to_time, format = "%m/%d/%y")


##Heuristic Model
H <- heuristic_models(MyData, 'path', 'conversions',  sep=">")
H
H2<- concat.split(H, "channel_name", sep = "|", drop = TRUE, fixed= TRUE)
names(H2) <- c("first_touch_conversions","last_touch_conversions","linear_touch_conversions"," Paid Channel","Traffic Type")
write.csv(H2, file = "h1.csv", row.names = FALSE) 
H2

##Plot Results
H1 <- melt(H, id='channel_name')


ggplot(H1, aes(x=channel_name, y=value, fill=variable ))+ geom_bar(stat='identity') +  theme(axis.text.x = element_text(angle=90, hjust=1))+
  ggtitle('Heuristic Model') +
  theme(axis.title.x = element_text(vjust = 0)) +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  theme(axis.title.y = element_text(vjust = +2)) +
  theme(title = element_text(size = 16)) +
  theme(plot.title=element_text(size = 20)) +
  ylab("")

##Markov model

M <- markov_model(MyData, 'path', 'conversions',  var_null='null', order =1)

M
##Model wih output
Ma <- markov_model(MyData, 'path', 'conversions',  var_null='null', order =1, out_more = TRUE)

##Output results
M2<- concat.split(M, "channel_name", sep = "|", drop = TRUE, fixed= TRUE)
names(M2) <- c("Total Conversion", "Paid Channel","Traffic Type")
write.csv(M2, file = "m1.csv", row.names = FALSE) 

##Plot Results
M1 <- melt(M, id='channel_name')

##Output the removal effects
df_res1 <- Ma$removal_effects
removal_effects<- concat.split(df_res1, "channel_name", sep = "|", drop = TRUE, fixed= TRUE)
names(removal_effects) <- c("Removal Effects Conversion","Paid Channel","Traffic Type")

write.csv(removal_effects, file = "removal_effects.csv", row.names = FALSE) 

##Output of transition probabilities
df_res2 <- Ma$transition_matrix
df_res2
write.csv(df_res2, file = "transition_matrix.csv", row.names = FALSE) 

 
#Visualize Multi-Touch Model
ggplot(M1, aes(x=channel_name, y=value, fill=variable ))+ geom_bar(stat='identity') +  theme(axis.text.x = element_text(angle=90, hjust=1))+
ggtitle('Multi-Touch Model') +
  theme(axis.title.x = element_text(vjust = 0)) +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  theme(axis.text.y = element_text(size=8)) +
  theme(axis.title.y = element_text(vjust = +2)) +
  theme(title = element_text(size = 16)) +
  theme(plot.title=element_text(size = 20)) +
  ylab("Value and Conversion Totals")

 

#Merges the two data frames on the "channel_name" column.
R <- merge(H, M, by='channel_name')
R
# Select only relevant columns
R1 <- R[, (colnames(R) %in% c('channel_name', 'first_touch_conversions', 'last_touch_conversions', 'linear_touch_conversions', 'total_conversion'))]

# Transforms the dataset into a data frame that ggplot2 can use to plot the outcomes
R1 <- melt(R, id='channel_name')


# Plot the total conversions
ggplot(R1, aes(channel_name, value, fill = variable)) +
  geom_bar(stat='identity', position='dodge') +
  ggtitle('TOTAL CONVERSIONS') +
  theme(axis.title.x = element_text(vjust = 0)) +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  theme(axis.title.y = element_text(vjust = +2)) +
  theme(title = element_text(size = 16)) +
  theme(plot.title=element_text(size = 20)) +
  ylab("")

final_output <- concat.split(R1, "channel_name", sep = "|", drop = TRUE, fixed= TRUE)
final_output
names(final_output) <- c("channel","value", "paid_channel","traffic_type")
write.csv(final_output, file = "r1.csv", row.names = FALSE) 