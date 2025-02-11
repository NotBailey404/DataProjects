import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import scipy.stats as stats

# Load the dataset
file_path = 'C:\\Users\\B_KIM\\OneDrive\\Desktop\\Amazon Top 50 Bestsellers (2009-2019).csv'
db = pd.read_csv(file_path)

# Inspect the dataset
print(db.info())
print(db.head())
print(db.shape)

# PHASE 2: Data Cleaning

# Check for duplicates
duplicated_rows = db.duplicated().sum()
print(f"Total duplicated rows: {duplicated_rows}")

# Remove duplicates based on Name, Author, and Year
db_unique = db.drop_duplicates(subset=['Name', 'Author', 'Year'])

# Ensure each row is distinct
db_unique = db_unique.drop_duplicates()

# Handle missing values (if any) by dropping rows with missing values
db_cleaned = db_unique.dropna()


# Verify the cleaned dataset
print(db_cleaned.describe(include='all'))
print(f"Final dataset shape: {db_cleaned.shape}")

# PHASE 3: Data Analysis

# 1. Correlation Between Reviews and Price
correlation_reviews_price = db_cleaned['Reviews'].corr(db_cleaned['Price'])
print(f"Correlation coefficient between Reviews and Price: {correlation_reviews_price}")

# Conclusion: The correlation coefficient between the number of reviews and the price of books is {correlation_reviews_price}.
# This suggests a weak} negative relationship, indicating that books with more reviews tend to have lower prices.

# 2. Perform a hypothesis test to determine if there is a significant difference in the User Rating between Fiction and Non-Fiction books

# Separate the User Rating for Fiction and Non-Fiction books
fiction_books = db_cleaned[db_cleaned['Genre'] == 'Fiction']['User Rating']
non_fiction_books = db_cleaned[db_cleaned['Genre'] == 'Non Fiction']['User Rating']

# Perform a two-sample t-test
t_statistic, p_value = stats.ttest_ind(fiction_books, non_fiction_books)
print(f"T-statistic: {t_statistic}")
print(f"P-value: {p_value}")

# Conclusion: The t-test results show a p-value of 0.0067, which is less than 0.05.
# We reject the null hypothesis and conclude that there is a significant difference in user ratings between Fiction and Non-Fiction books.

# 3. Visualize the distribution of User Rating by Genre
plt.figure(figsize=(10, 6))
sns.boxplot(x='Genre', y='User Rating', data=db_cleaned)
plt.title('User Rating by Genre')
plt.show()

# Conclusion: The box plot shows the distribution of user ratings for Fiction and Non-Fiction books.
# If the median user rating for one genre is significantly higher or lower than the other, it indicates a difference in user satisfaction between the genres.


# Determine which genre has higher prices
average_price_by_genre = db_cleaned.groupby('Genre')['Price'].mean()
print("Average Price by Genre:")
print(average_price_by_genre)

# 4. Visualize the distribution of Price by Genre
plt.figure(figsize=(10, 6))
sns.boxplot(x='Genre', y='Price', data=db_cleaned)
plt.title('Price by Genre')
plt.show()

# Conclusion: The box plot shows the distribution of prices for Fiction and Non-Fiction books.
# Non-Fiction books have a higher average price compared to Fiction books.

# 5. Visualize the distribution of Reviews by Genre
plt.figure(figsize=(10, 6))
sns.barplot(x='Genre', y='Reviews', data=db_cleaned)
plt.title('Reviews by Genre')
plt.show()

# 5A. Analyze the mean satisfaction level (User Rating) of each genre of book
mean_satisfaction_by_genre = db_cleaned.groupby('Genre')['User Rating'].mean()
print("Mean Satisfaction Level by Genre:")
print(mean_satisfaction_by_genre)

# 5B. Visualize the mean satisfaction level by genre
plt.figure(figsize=(10, 6))
sns.barplot(x=mean_satisfaction_by_genre.index, y=mean_satisfaction_by_genre.values)
plt.title('Mean Satisfaction Level by Genre')
plt.xlabel('Genre')
plt.ylabel('Mean User Rating')
plt.show()

#Mean Satisfaction Level by Genre:
# Genre
# Fiction       4.648077
# Non Fiction   4.595161

# Conclusion: The bar plot shows the mean user rating for Fiction and Non-Fiction books.
# This indicates there is a slightly higher satisfaction level for Fiction books compared to Non-Fiction books,
# hinting at higher performing titles and a greater user demand for Fiction books.

# 6. Visualize the distribution of User Rating by Year
plt.figure(figsize=(10, 6))
sns.lineplot(x='Year', y='User Rating', data=db_cleaned)
plt.title('User Rating by Year')
plt.show()

# This line plot indicates a positive change in reader satisfaction or the quality of books 
# published during those years.

### Final Conclusions: ###################################################################################################

# 1. There is a weak negative correlation between the number of reviews and the price of books.

# 2. There is a statistically significant difference in user ratings between Fiction and Non-Fiction books.

# 3. Fiction books have a lower average price compared to Non-Fiction books but receive more reviews on average.

# 4. Fiction books have a higher satisfaction rating compared to Non-Fiction books.

# 4. Rising trends in user ratings over the years can indicate positive overall changes in reader satisfaction.