setwd("~/MOOC/Data_Science_Specialization/3- Importing_and_cleaning_data")
library(data.table)
library(dplyr)

#Download and unzip data
if(file.exists("./data")) {
  setwd("./data")
} else {
  dir.create("./data")
  fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./data/zipfile.zip",method="curl")
  setwd("./data")
  unzip("zipfile.zip", files = NULL, list = FALSE, overwrite = TRUE,
        junkpaths = FALSE, exdir = ".", unzip = "internal",
        setTimes = FALSE)
}

#Read data (Train and Test)
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
yTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
xTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)

#1 Merges the training and the test sets to create one data set.
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(yTrain, yTest)
colnames(subject)<-"subject"
colnames(activity)<-"activity"
features <- rbind(xTrain, xTest)
colnames(features)<-t(read.table("UCI HAR Dataset/features.txt")[2])
all<-cbind(subject,activity,features)

#2 Extracts only the measurements on the mean and standard deviation for each measurement. 

columnsMeanSTD <- grep(".*Mean.*|.*Std.*", names(all), ignore.case=TRUE)
addactivitysubject<-c(1,2,columnsMeanSTD)#1 and 2 to include subject and activity (in column 1 and 2)
allMeanSTD<-subset(all[,addactivitysubject])

#3 Uses descriptive activity names to name the activities in the data set
actdesc<- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
namesactdesc<-c("number","nameactivity")
colnames(actdesc)<-namesactdesc
allMeanSTD$activity<-as.character(allMeanSTD$activity)#because we want to replace with character, and activity was an integer
for (i in 1:6) {
  allMeanSTD$activity[allMeanSTD$activity == i] <- as.character(actdesc[i,2])  
}

#4 Appropriately labels the data set with descriptive variable names. 
#From features_info.txt
#  - t=time
#  - f=frequency
#  We can replace "BodyBody" by Body
#  We can replace the functions with () by the name without parenthesis
names(allMeanSTD)<-gsub("^t", "time", names(allMeanSTD))
names(allMeanSTD)<-gsub("^f", "frequency", names(allMeanSTD))
names(allMeanSTD)<-gsub("BodyBody", "Body", names(allMeanSTD))
names(allMeanSTD)<-gsub("mean()", "Mean", names(allMeanSTD))
names(allMeanSTD)<-gsub("std()", "STD", names(allMeanSTD))
names(allMeanSTD)<-gsub("meanFreq()", "MeanFreq", names(allMeanSTD))

#5 From the data set in step 4, creates a second, independent tidy data set with the average of 
#each variable for each activity and each subject.
allMeanSTD$subject<-factor(allMeanSTD$subject)
allMeanSTD$activity<-factor(allMeanSTD$activity)
allaverage <- aggregate(. ~subject + activity, allMeanSTD, mean)
write.table(allaverage, file = "Tidydata.txt", row.names = FALSE)
write.table(allMeanSTD, file = "AllMeanSTD.txt", row.names = FALSE)



