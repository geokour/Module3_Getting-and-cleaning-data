# Load necessary libraries
library(data.table)
library(reshape2)

# Download and unzip the dataset
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "dataFiles.zip")
unzip("dataFiles.zip")

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, "featureNames"])
measurements <- features[featuresWanted, "featureNames"]
measurements <- gsub("[()]", "", measurements)

# Load train datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[, featuresWanted]
colnames(train) <- measurements
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt", col.names = "Activity")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "SubjectNum")
train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")[, featuresWanted]
colnames(test) <- measurements
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt", col.names = "Activity")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "SubjectNum")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets and add labels
combined <- rbind(train, test)

# Convert classLabels to activityName
combined$Activity <- factor(combined$Activity, levels = activityLabels$classLabels, labels = activityLabels$activityName)

combined$SubjectNum <- as.factor(combined$SubjectNum)
combined <- melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# Write the tidy dataset to a file
write.table(combined, "tidy_data.txt", row.names = FALSE, quote = FALSE)

