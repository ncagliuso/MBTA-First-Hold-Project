#Dan Z Project, 03/11/2019
#Nick Cagliuso
#This project measures the time between requisition approval and those requisitions being put on hold by Buyer

library(dplyr)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(readxl)
library(kableExtra)
library(tidyr)
library(reshape2)
setwd("C:/Users/NCAGLIUSO/Desktop/Dan Z")
SLT_DANZ <- read_excel("SLT_DANZ.xlsx", col_types = c("text", "text", "date", 
                                                                        "text", "text", "text", "text", "text", 
                                                                        "numeric", "date"))
#Line = "1" indicates that each row is the first instance of a hold for that particular requisition

SLT_DANZ <- mutate(SLT_DANZ, New_Date = (SLT_DANZ$Req_Approval_Date) + days(1) + hours(8))
# 1 Day and 8 hours added to Req Approval Date as FMIS processes approvals at 8 AM the day after they occur

SLT_DANZ$Req_Approval_Date <- as_datetime(SLT_DANZ$Req_Approval_Date)
SLT_DANZ$DateTime <- as_datetime(SLT_DANZ$DateTime)
#DateTime column refers to the date/time the requisition was put on hold

SLT_DANZ <- mutate(SLT_DANZ, Approval_Time = difftime(SLT_DANZ$DateTime, SLT_DANZ$New_Date, units = c("days")))
SLT_DANZ <- filter(SLT_DANZ, Approval_Time >= 0)
#Some faulty data where Hold Date - Approval date = a negative number have been removed

SLT_DANZ <- SLT_DANZ %>% filter(.data$Buyer != "DMALONEY")
#Buyer left department

SLT_DANZ <- SLT_DANZ %>% filter(.data$Approval_Time <= 100)
#Anything more than 100 days between Approval and Hold is an outlier 

SLT_DANZ <- mutate(SLT_DANZ, Approval_Month = SLT_DANZ$New_Date %>% month())
SLT_DANZ$Approval_Month <- month.abb[SLT_DANZ$Approval_Month]
month_levels <- c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar")
#Fiscal Year runs July through June, and we're looking at the first three quarters of FY

x1 <- c(SLT_DANZ$Approval_Month)
y1 <- factor(x1, levels = month_levels)
SLT_DANZ <- with(SLT_DANZ, SLT_DANZ[order(y1),])
#SLT_DANZ <- SLT_DANZ[-c(51, 55, 56, 110, 128, 139, 190), ]

Mean_Info_Month <- SLT_DANZ %>% group_by(Approval_Month) %>% summarise(Mean_Duration = mean(.data$Approval_Time), 
cnt = n(), median = median(.data$Approval_Time))
#Table shows median Hold-Approval time, mean Hold-Approval time, and count of requisitions by Month

Mean_Info <- SLT_DANZ %>% group_by(Buyer) %>% summarise(Mean_Duration = mean(.data$Approval_Time), cnt = n(), 
median = median(.data$Approval_Time))
#Same info as Mean_Info_Month by by Buyer

Buyer_Info <- do.call("rbind", tapply(SLT_DANZ$Approval_Time, SLT_DANZ$Buyer, quantile))
Month_Info <- do.call("rbind", tapply(SLT_DANZ$Approval_Time, SLT_DANZ$Approval_Month, quantile))
#Data of 0, 25, 50, 75, and 100th percentiles of Hold-Approval time by Buyer and Month

df_Buyer <- melt(Buyer_Info)
Buyer_Stats <- df_Buyer %>% spread(Var2, value)
names(Buyer_Stats)[1]<-"Buyer"
df_Month <- melt(Month_Info)
Month_Stats <- df_Month %>% spread(Var2, value)
names(Month_Stats)[1]<-"Approval_Month"

Month_Stats$Approval_Month <- factor(Month_Stats$Approval_Month,levels = 
                                       c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar"))

Buyer_Stats <- left_join(Buyer_Stats, Mean_Info, by = "Buyer")
Month_Stats <- left_join(Month_Stats, Mean_Info_Month, by = "Approval_Month")
#These tables put each percentile, mean, median and requisition count by buyer and month

a1 <- c(Month_Stats$Approval_Month)
b1 <- factor(a1, levels = month_levels)
Month_Stats <- with(Month_Stats, Month_Stats[order(b1),])
Month_Stats$`0%` <- round(Month_Stats$`0%`, digits = 1)
Month_Stats$`25%` <- round(Month_Stats$`25%`, digits = 1)
Month_Stats$`50%` <- round(Month_Stats$`50%`, digits = 1)
Month_Stats$`75%` <- round(Month_Stats$`75%`, digits = 1)
Month_Stats$`100%` <- round(Month_Stats$`100%`, digits = 1)
Month_Stats$`Mean_Duration` <- round(Month_Stats$`Mean_Duration`, digits = 1)
Month_Stats$`median` <- round(Month_Stats$`median`, digits = 1)
Buyer_Stats$`0%` <- round(Buyer_Stats$`0%`, digits = 1)
Buyer_Stats$`25%` <- round(Buyer_Stats$`25%`, digits = 1)
Buyer_Stats$`50%` <- round(Buyer_Stats$`50%`, digits = 1)
Buyer_Stats$`75%` <- round(Buyer_Stats$`75%`, digits = 1)
Buyer_Stats$`100%` <- round(Buyer_Stats$`100%`, digits = 1)
#Function should be used above to input percentile rather than repeat code

Buyer_Stats$`Mean_Duration` <- round(Buyer_Stats$`Mean_Duration`, digits = 1)
Buyer_Stats$`median` <- round(Buyer_Stats$`median`, digits = 1)
Buyer_Stats <- Buyer_Stats %>% arrange(.data$median, desc(median))

SLT_DANZ$Approval_Month <- factor(SLT_DANZ$Approval_Month,levels = 
                                    c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar"))
ggplot(data = SLT_DANZ, mapping = aes(x = SLT_DANZ$Buyer, y = SLT_DANZ$Approval_Time)) + geom_boxplot() + 
  labs(x = "Buyer", y = "Approval Time")
ggplot(data = SLT_DANZ, mapping = aes(x = SLT_DANZ$Approval_Month, y = SLT_DANZ$Approval_Time)) + geom_boxplot() + 
  labs(x = "Approval Month", y = "Approval Time")
#Box plots by Month and by Buyer

By_Buyer_By_Month <- SLT_DANZ %>% group_by(.data$Approval_Month,.data$Buyer) %>% summarise(Mean_Duration = 
                                                                                             mean(.data$Approval_Time), cnt = n(), median = median(.data$Approval_Time))
#Table featuring median Hold-Approval Date, requisition count, and mean Hold-Approval Date for each buyer every month

Buyer_Stats %>% kable() %>% kable_styling(bootstrap_options = c("striped", "condensed", full_width = F)) %>% 
row_spec(9:10, bold = T, color = "white", background = "#D7261E")
#Most egregious means/medians highlighted

Month_Stats %>% kable() %>% kable_styling(bootstrap_options = c("striped", "condensed", full_width = F))
