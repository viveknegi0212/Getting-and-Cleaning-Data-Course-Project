#loading packages
packages<- c("data.table", "reshape2")
invisible(lapply(packages, library, character.only = TRUE))

#download and unzip files in new folder
download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = "./data_delme/project_course3.zip")
unzip(zipfile = "./data_delme/project_course3.zip", exdir = "./data_delme/project3data")

#Load labels and features dataset and subset required rows from features
activity_labels <- fread("./data_delme/project3data/UCI HAR Dataset/activity_labels.txt",
                         col.names = c("label", "activityname"))

features <- fread("./data_delme/project3data/UCI HAR Dataset/features.txt",
                  col.names = c("index", "featurenames"))

required_features <- grep("(mean|std)\\(\\)", features[,featurenames])
features_subset <- features[required_features, featurenames]

features_subset <- gsub('[()]', '', features_subset)

#Load train dataset
train <- fread("./data_delme/project3data/UCI HAR Dataset/train/X_train.txt")[,required_features,with=F]
data.table::setnames(train, colnames(train), features_subset)
trainActivities <- fread("./data_delme/project3data/UCI HAR Dataset/train/Y_train.txt",
                         col.names = c("Activity"))
trainSubjects <- fread("./data_delme/project3data/UCI HAR Dataset/train/subject_train.txt",
                       col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

#Load test dataset
test <- fread("./data_delme/project3data/UCI HAR Dataset/test/X_test.txt")[,required_features,with=F]
data.table::setnames(test, colnames(test), features_subset)
testActivities <- fread("./data_delme/project3data/UCI HAR Dataset/test/Y_test.txt",
                        col.names = c("Activity"))
testSubjects <- fread("./data_delme/project3data/UCI HAR Dataset/test/subject_test.txt",
                      col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

#merge train and test
merged_data <- rbind(train,test)

#labelling activities and subject
merged_data[["Activity"]] <- factor(merged_data[, Activity]
                                    , levels = activity_labels[["label"]]
                                    , labels = activity_labels[["activityname"]])

merged_data[["SubjectNum"]] <- as.factor(merged_data[, SubjectNum])

#independent tidy data set with the average of each variable for each activity and each subject
merged_to_tidy <- reshape2::melt(merged_data, id.vars= c("SubjectNum", "Activity"))
merged_to_tidy <- reshape2::dcast(merged_to_tidy, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = merged_to_tidy, file = "tidyData.csv", quote = FALSE)
