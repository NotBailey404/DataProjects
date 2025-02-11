install.packages("tidyverse")
library("tidyverse")


#Begin the installing of data into RStudio
walmart_data <- read.csv("C:\\Users\\B_KIM\\OneDrive\\Desktop\\Walmart Data Project\\Walmart_Sales_Data.csv")

#Data Cleaning and Reformatting


# Preliminary look at the data
str(walmart_data) # 6435 rows, 8 columns, stored as a dataframe
summary(walmart_data)

#There is a formatting error with the DATE column. Let's change it to the DATE data type

class(walmart_data$Date) #Check formatting first
walmart_data$Date <- as.Date(walmart_data$Date, format = "%d-%m-%Y") #Update formatting for consistency

#BASIC OUTLIER CLEANING: Weekly Sales####################################################

#Outlier Cleaning: Weekly Sales

#Calculate First and Third quartiles
Q1 <- quantile(walmart_data$Weekly_Sales, 0.25)
Q3 <- quantile(walmart_data$Weekly_Sales, 0.75)

#Determine Inter-Quartile Range to help define what an outlier is
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR

#Use the quantile values to clean Weekly_Sales outliers and save it as a test dataframe
walmart_data<- walmart_data %>%
  filter(Weekly_Sales >= lower_bound & Weekly_Sales <= upper_bound)


#Use the quantile values to clean Weekly_Sales outliers and save it as a test dataframe
walmart_data_cleaned <- walmart_data %>%
  filter(Weekly_Sales >= lower_bound & Weekly_Sales <= upper_bound)


# Now, we examine the cleaned data with outliers removed to ensure maximum accuracy
summary(walmart_data_cleaned)

#ANALYSIS STEPS:
# * Find Highest Sales
# * Determine most profitable holiday
# * Find correlation between temperature and Consumer Price Index (CPI)
# * Find correlation between temperature and Weekly Sales
# * Determine highest and lowest sales by store, out of all 42 stores

############FIND OVERALL SALES TRENDS#############################################################################

ggplot(walmart_data,aes(x=Date, y=Weekly_Sales, color = factor(Holiday_Flag)))+geom_line(size = 0.7)+ #initializes line chart
  labs(title = "Weekly Sales Over Time", x = "Date", y = "Weekly Sales Amount", color = "Holiday Flag")+ #applies labels
  scale_color_manual(values = c("#1260cc", "#00ffff"), labels = c("Non-holiday", "Holiday")) #sets manual colors


# Overall strong sales trends, but the presence of non-holiday outliers increases towards 2013. 
# Holiday weeks usually outperform the average weekly sales, all other outliers excluded.


### FIND HIGHEST SALES ###################################################################################################

#Create new dataframe, grouping by Store and then summarizing each store's sales using the summarize function
#We group the original data by store, and then make a new column called Cumulative Sales, which is the sum of
# each store's weekly sales

totalstoresales<- walmart_data %>% group_by(Store) %>% summarise(Cumulative_Sales = sum(Weekly_Sales))


#Next, we graph each store's performance across all 40 stores as a bar chart
ggplot(walmartstoresales,aes(x=Store,y=Cumulative_Sales))+geom_col()


#Summary
summary(walmartstoresales)


#Store 20 has the highest cumulative sales out of all 40 stores
#Store 33 has the least cumulative sales out of all 40 stores
#The average cumulative sales for a store is 138.24 Million per store based on historical data


#########Find most profitable holiday from the data ##############################################################################

#First, we take the walmart data and group it by Holiday Flag (1=True, 0=False)
holidaysales<- walmart_data %>% group_by(Holiday_Flag)

#Now, we rename it something else and filter by holiday flag to get a subset of our data
holidaysales <- filter(holidaysales,Holiday_Flag == TRUE)

#For later comparison, we will make a dataframe of Non-Holiday days, keeping only entries where Holiday = FALSE
nonholidaysales<- walmart_data %>% group_by(Holiday_Flag)
nonholidaysales <- filter(holidaysales,Holiday_Flag == FALSE)

############ Create a new column and assign a HolidayLabel based on the date of each entry #####################################

# Choices being: 
# Super Bowl(2/11 or 2/10)
# Christmas(12/30 or 12/31)
# Labor Day(9/7 or 9/9)
# Thanksgiving (11/25 or 11/26)

# Remember: Each date entry represents the start of a week CONTAINING a holiday

#Create new column called HolidayType in the holidaysales dataframe, setting value to NULL
holidaysales[ , 'HolidayType'] = NA

#Create a backup of the data in case things go wrong as a fallback point
holidaysalesbackup<-holidaysales

#Then, using the non-backup copy, we will make values in the DATE column,
# assign a label to each row and it will tells us what holiday each entry falls under

### APPLYING THE LABELS ##########################################################################################

# This function makes a vector of 3 dates and tries each row for the matching week of that year's super bowl
# It tries each row for the matching conditions and uses %in% to specify values in the DATE column
# and the c (concatenate) function to create a vector of 3 dates that are used as search criteria

#First we do the Super Bowl. The %in% operator checks to see if the values contained in c() are there, and if they are, it applies SuperBowl to that entry
holidaysales$HolidayType[holidaysales$Date %in% c('2010-02-12', '2011-02-11', '2012-02-10')] <- 'SuperBowl'

#Next, we do Christmas
holidaysales$HolidayType[holidaysales$Date %in% c('2010-12-31', '2011-12-30')] <- 'Christmas'

#Then, Labor Day
holidaysales$HolidayType[holidaysales$Date %in% c('2010-09-10', '2011-09-09','2012-09-07')] <- 'LaborDay'

#And finally, Thanksgiving
holidaysales$HolidayType[holidaysales$Date %in% c('2010-11-26', '2011-11-25')] <- 'Thanksgiving'

#Remove the previous backup and make another one
rm(holidaysalesbackup)
holidaysalesbackup<-holidaysales

# Now, we group the HolidaySales data by HolidayFlag, and determine which holiday has the greatest total sales
holiday_cumulative_sales <- holidaysales %>% group_by(HolidayType) %>% summarise(Cumulative_Sales = sum(Weekly_Sales))
