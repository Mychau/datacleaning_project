# datacleaning_project
Final project - Getting and cleaning data - JHU

#Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

    Merges the training and the test sets to create one data set.
    Extracts only the measurements on the mean and standard deviation for each measurement.
    Uses descriptive activity names to name the activities in the data set
    Appropriately labels the data set with descriptive variable names.
    From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Code and steps
###Set up directory and download usefull libraries
```{r}
setwd("~/MOOC/Data_Science_Specialization/3- Importing_and_cleaning_data")
library(data.table)
library(dplyr)
```

###Download and unzip data
```{r}
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
```

###Read data (Train and Test)
```{r}
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
yTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
xTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
```

##1 Merges the training and the test sets to create one data set.
### Create 3 data sets: subject, activity, features
```{r}
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(yTrain, yTest)
colnames(subject)<-"subject"
colnames(activity)<-"activity"
features <- rbind(xTrain, xTest)
colnames(features)<-t(read.table("UCI HAR Dataset/features.txt")[2])
```

###Merge subject, activity, features in one dataset named all
```{r}
all<-cbind(subject,activity,features)
```

##2 Extracts only the measurements on the mean and standard deviation for each measurement.
```{r}
columnsMeanSTD <- grep(".*Mean.*|.*Std.*", names(all), ignore.case=TRUE)
addactivitysubject<-c(1,2,columnsMeanSTD)#1 and 2 to include subject and activity (in column 1 and 2)
allMeanSTD<-subset(all[,addactivitysubject])
```

##3 Uses descriptive activity names to name the activities in the data set
```{r}
actdesc<- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
namesactdesc<-c("number","nameactivity")
colnames(actdesc)<-namesactdesc
allMeanSTD$activity<-as.character(allMeanSTD$activity)
for (i in 1:6) {
  allMeanSTD$activity[allMeanSTD$activity == i] <- as.character(actdesc[i,2])  
}
```

##4 Appropriately labels the data set with descriptive variable names.
####From features_info.txt
t=time
f=frequency
We can replace "BodyBody" by Body
We can replace the functions with () by the name with majuscule
```{r}
names(allMeanSTD)<-gsub("^t", "time", names(allMeanSTD))
names(allMeanSTD)<-gsub("^f", "frequency", names(allMeanSTD))
names(allMeanSTD)<-gsub("BodyBody", "Body", names(allMeanSTD))
names(allMeanSTD)<-gsub("mean()", "Mean", names(allMeanSTD))
names(allMeanSTD)<-gsub("std()", "STD", names(allMeanSTD))
names(allMeanSTD)<-gsub("meanFreq()", "MeanFreq", names(allMeanSTD))
```

##5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```{r}
allMeanSTD$subject<-factor(allMeanSTD$subject)
allMeanSTD$activity<-factor(allMeanSTD$activity)
allaverage <- aggregate(. ~subject + activity, allMeanSTD, mean)
write.table(allaverage, file = "Tidydata.txt", row.names = FALSE)
write.table(allMeanSTD, file = "AllMeanSTD.txt", row.names = FALSE)
```
