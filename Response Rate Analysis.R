#Affordable Housing Survey Response Rate Analysis.


#Prior to this code being run, the file 'Paper_survey_data.xlsx' was modified.
#Columns after BG were removed.
#Row 1 and Rows after the last response (row 1521) were removed.
#The resulting file was named 'Paper_survey_data_basic_cleaning.xlsx'.


rm(list = ls())
gc()
cat("\014")  



setwd("Affordable Housing Survey/")

#install.packages("openxlsx")
#install.packages("plyr")
#install.packages("dplyr")
#install.packages("anytime")
library("openxlsx")
library("plyr")
library("anytime")

postcards = read.xlsx("Original Data/POSTCARDS_ADDRESS_LIST.xlsx", "POSTCARDS")
letters = read.xlsx("Original Data/LETTERS_ADDRESS_LIST.xlsx", "LETTERS")
incen = read.xlsx("Original Data/INCENTIVE_ADDRESS_LIST.xlsx", "INCENTIVE")
noincen = read.xlsx("Original Data/NO_INCENTIVE_ADDRESS_LIST.xlsx", "POSTCARDS")
oversamp = read.xlsx("Original Data/IZ_Reg_Oversample_0to80_AMI_with_MAR_Data.xlsx", "Sheet1")

paperdata = read.xlsx("Paper_survey_data_basic_cleaning.xlsx", "Sheet1")
onlinedata.a = read.csv("Original Data/DC_Housing_Survey_Online_Data_Part_I.csv")
onlinedata.b = read.csv("Original Data/DC_Housing_Survey_Online_Data_Part_II.csv")

onlinedata.c = read.xlsx("Original Data/AHS_OnlineVersion_ForWeighting.xlsx", "Sheet1")

postcards[4] = NULL
postcards$grouppc = 1

letters[4] = NULL
letters$grouplt = 1

incen[4] = NULL
incen$groupin = 1

noincen[4] = NULL
noincen$groupni = 1

oversamp[c(4:ncol(oversamp))] = NULL
oversamp$groupos = 1

#Base file:

df = merge(postcards, letters, by = c("Unique.Code","Street.Address.Line.1","Street.Address.Line.2","zipcode"), all = TRUE)
df = merge(df, incen, by = c("Unique.Code","Street.Address.Line.1","Street.Address.Line.2","zipcode"), all = TRUE)
df = merge(df, noincen, by = c("Unique.Code","Street.Address.Line.1","Street.Address.Line.2","zipcode"), all = TRUE)
df = merge(df, oversamp, by = c("Unique.Code","Street.Address.Line.1","Street.Address.Line.2"), all = TRUE)

table(duplicated(df$Unique.Code))

df$Street.Address.Line.1 = toupper(df$Street.Address.Line.1)
df$Street.Address.Line.1 = gsub("STREET", "ST",df$Street.Address.Line.1)
df$Street.Address.Line.1 = gsub("ROAD", "RD",df$Street.Address.Line.1)
df$Street.Address.Line.1 = gsub("AVENUE", "AVE",df$Street.Address.Line.1)
df$Street.Address.Line.1 = gsub("DRIVE", "DR",df$Street.Address.Line.1)
df$Street.Address.Line.1 = gsub("PLACE", "PL",df$Street.Address.Line.1)
df$Street.Address.Line.1 = gsub("TERRACE", "TER",df$Street.Address.Line.1)

df$Street.Address.Line.2 = gsub("UNIT", "",df$Street.Address.Line.2)
df$Street.Address.Line.2 = gsub(" ", "",df$Street.Address.Line.2)

df$Unique.Code = as.character(df$Unique.Code)

write.csv(df, "Temp.csv", row.names = FALSE, na = "")

#First Online File: Those with Unique Codes.

ola = onlinedata.a
ola[,c(1:2,4:10,12:ncol(ola))] = NULL
names(ola)[1] = "Date.Submitted.a"
names(ola)[2] = "Unique.Code"

ola$Unique.Code = as.character(ola$Unique.Code)

ola = ola[!(ola$Unique.Code == ""),]
ola$onlinesubmit.a = 1

table(duplicated(ola$Unique.Code))

ola = ola[!duplicated(ola$Unique.Code),]

#onlinedata.b doesn't have Unique.Code
#Need to merge based on address.

olb = onlinedata.b
olb[,c(1,2,4:10,14:ncol(olb))] = NULL
names(olb) = c("Date.Submitted","Street.Address.Line.1","Street.Address.Line.2","zipcode")

olb = olb[!(olb$Street.Address.Line.1 == ""),]

olb$Street.Address.Line.1 = toupper(olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("[[:punct:]]","",olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("STREET", "ST",olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("ROAD", "RD",olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("AVENUE", "AVE",olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("DRIVE", "DR",olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("PLACE", "PL",olb$Street.Address.Line.1)
olb$Street.Address.Line.1 = gsub("TERRACE", "TER",olb$Street.Address.Line.1)

olb$Street.Address.Line.2 = toupper(olb$Street.Address.Line.2)
olb$Street.Address.Line.2 = gsub("[[:punct:]]","",olb$Street.Address.Line.2)
olb$Street.Address.Line.2 = gsub("UNIT","",olb$Street.Address.Line.2)
olb$Street.Address.Line.2 = gsub("APARTMENT","",olb$Street.Address.Line.2)
olb$Street.Address.Line.2 = gsub("APT","",olb$Street.Address.Line.2)
olb$Street.Address.Line.2 = gsub("AP","",olb$Street.Address.Line.2)
olb$Street.Address.Line.2 = gsub(" ","",olb$Street.Address.Line.2)

table(duplicated(olb[,2:3]))
olb = olb[!duplicated(olb[c(2,3)]),]

olb$zipcode = NULL
olb$onlinesubmit.b = 1
names(olb)[1] = "Date.Submitted.b"

write.csv(olb, "Temp.csv", row.names = FALSE, na = "")

#paperdata doesn't have Data.Submitted

pd = paperdata
pd[2:ncol(pd)] = NULL
names(pd)[1] = "Unique.Code"
pd$papersubmit = 1

pd$Unique.Code = as.character(pd$Unique.Code)

table(duplicated(pd$Unique.Code))

pd = pd[!duplicated(pd$Unique.Code),]

#Merge.


library(dplyr)

df1 = left_join(df,ola, by = "Unique.Code")
df1 = left_join(df1,olb, by = c("Street.Address.Line.1", "Street.Address.Line.2"))
df1 = left_join(df1,pd, by = "Unique.Code")

#df1 = merge(df,ola, by = "Unique.Code", all.x = TRUE)
#df1 = merge(df1,olb, by = c("Street.Address.Line.1", "Street.Address.Line.2"), all.x = TRUE)
#df1 = merge(df1,pd, by = "Unique.Code", all.x = TRUE)



#Determining Group.

df1$Exp1.Postcard = NA
df1$Exp1.Letter = NA
df1$Exp2.Incen = NA
df1$Exp2.NoIncen = NA

df1$Exp1.Postcard[df1$grouppc == 1] = 1
df1$Exp1.Letter[df1$grouplt == 1] = 1
df1$Exp2.Incen[df1$groupin == 1] = 1
df1$Exp2.NoIncen[df1$groupni == 1 & df1$groupos == 1] = 1
#df1[,5:9] = NULL

df1$Group[df1$Exp1.Letter == 1] = "Exp1: Letter"
df1$Group[df1$Exp1.Postcard == 1] = "Exp1: Postcard"
df1$Group[df1$Exp2.Incen == 1] = "Exp2: Incen"
df1$Group[df1$Exp2.NoIncen == 1] = "Exp2: NoIncen"

#Determining Response Status.

df1$submissions = rowSums(df1[,c(11,13,14)], na.rm = TRUE)
df1$submitted = df1$submissions
df1$submitted[df1$submitted > 1] = 1

#Determining Early Response Status.

table(df1$submissions)
table(df1$submitted)

df1$Date.Submitted.a = anytime(as.character(df1$Date.Submitted.a))
df1$Date.Submitted.b = anytime(as.character(df1$Date.Submitted.b))

df1$Early.Submission = NA
df1$Early.Submission[df1$submitted == 1] = 0
df1$Early.Submission[df1$papersubmit == 1 &
                       is.na(df1$Date.Submitted.a) & 
                       is.na(df1$Date.Submitted.b)] = NA
df1$Early.Submission[df1$Date.Submitted.a < anytime('2018-08-6') |
                       df1$Date.Submitted.b < anytime('2018-08-6')] = 1

table(df1$Early.Submission)

#Flagging out of time submissions.
df1$OutOfTime = NA
df1$OutOfTime[df1$Date.Submitted.a < anytime('2018-07-25') |
                       df1$Date.Submitted.b < anytime('2018-07-25')] = 1

df1$OutOfTime[df1$Date.Submitted.a > anytime('2018-08-31') |
                       df1$Date.Submitted.b > anytime('2018-08-31')] = 1

table(df1$OutOfTime)



write.csv(df1, "Temp.csv", row.names = FALSE, na = "")

#Preliminary Analysis.

table(df1$Group)

table(df1$submitted[df1$Exp1.Postcard ==1])
table(df1$submitted[df1$Exp1.Letter ==1])

table(df1$Early.Submission[df1$Exp1.Postcard ==1])
table(df1$Early.Submission[df1$Exp1.Letter ==1])

table(df1$submitted[df1$Exp2.Incen ==1])
table(df1$submitted[df1$Exp2.NoIncen ==1])
