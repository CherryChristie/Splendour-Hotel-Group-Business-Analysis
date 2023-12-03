# Hotel Booking Data Analysis

## Table of Content
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#findings)
- [Dashboard](#dashboard)
- [Recommendations](#recommendations)
- [Limitation](#limitation)
- [Reference](#reference)
- 

### Project Overview

This data analysis project aims to provide insights into the booking performance of a hotel over the past years. By analyzing various aspects  of the hotel booking dataset, we seek to identify trends, make data-driven recommendation, and gain a deeper understanding of the company's performance.

### Data Source

Booking Data: The primary dataset used for this analysis is the "SHG_Booking_Data.xlsx"  file which contains detailed information about each booking maade by the company.

### Tools

- Excel (This is used for data cleaning)
- Microsoft SQL server  (This is used for data analysis)
- Power Bi (This is used for creating a visualisation / report)

### Data Cleaning and Preparation

In the initial preparation phase, I performed the following tasks: 
- Data loading and inspection
- Handling missing values.
- Data cleaning and formatting.

### Exploratory Data Analysis

--EDA involves exploring the datasets to find out and answer key questions such as :

- Finding out information relating to Booking Patterns:
What is the trend in booking patterns over time, and are there specific seasons or months with increased booking activity?

- Customer Behavior Analysis:
Which distribution channels contribute the most to bookings, and how does the average daily rate (ADR) differ across these channels?
Can we identify any patterns in the distribution of guests based on their country of origin, and how does this impact revenue?

- Cancellation Analysis:
What factors are most strongly correlated with cancellations, and can we predict potential cancellations based on certain variables?
How does the revenue loss from cancellations compare across different customer segments and distribution channels?

- Revenue Optimization:
What is the overall revenue trend, and are there specific customer segments or countries contributing significantly to revenue?
Can we identify optimal pricing strategies based on the Average Daily Rate (ADR) for different customer types and distribution channels?

- Geographical Analysis:
How does the distribution of guests vary across different countries, and are there specific countries that should be targeted for marketing efforts?
Is there a correlation between the country of origin and the likelihood of cancellations or extended stays?

- Operational Efficiency:
What is the average length of stay for guests, and how does it differ based on booking channels or customer types?
Are there patterns in check-out dates that can inform staffing and resource allocation strategies?

- Impact of Deposit Types:
How does the presence or absence of a deposit impact the likelihood of cancellations and revenue generation?
Can we identify any patterns in the use of deposit types across different customer segments?

- Time-to-Event Analysis:
How does the time between booking and arrival date (lead time) affect revenue and the likelihood of cancellations?
Are there specific lead time ranges that are associated with higher customer satisfaction or revenue?

### Data Analysis 

###### SELECT STATEMENT
###### AGGREGATE FUNCTION
###### CASE FUNCTION
###### SUBQUERY
###### CTE

```sql
SELECT country, COUNT(*) AS guests, SUM(revenue) AS total_revenue
FROM [dbo.hotel]
WHERE country IS NOT NULL
GROUP BY country
ORDER BY 3 DESC;
```
AGGREGATE FOR DEMOGRAPHIC ANALYSIS
```sql
SELECT country, COUNT(*) as country_count, 	AVG(revenue) AS avg_revenue	
FROM [dbo.hotel]
WHERE country IS NOT NULL 
GROUP BY country
HAVING AVG(revenue) < (SELECT AVG(revenue) FROM [dbo.hotel])
ORDER BY 3 DESC;
```
CTE FOR CHECKOUT ANALYSIS
```sql
WITH ss AS 
		   (SELECT DATEADD(day, nights, arrival_date) AS checkout_date, COUNT(*) AS total_checkout, SUM(guests) as total_guest
			FROM [dbo.hotel]
			WHERE cancelled_0_1 = 0
			GROUP BY DATEADD(day, nights, arrival_date)
			)

SELECT DATEPART(dw, checkout_date) as DayoftheWeek, SUM(total_checkout) Total_Checkouts, SUM(total_guest) Total_Guest
FROM ss
GROUP BY DATEPART(dw, checkout_date)
ORDER BY 2 DESC;
```
CASE FUNCTION FOR DEPOSIT ANALYSIS
```sql
SELECT Deposit_type , COUNT(*) AS Total_Bookings, 
					 SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) cancellation_total,
					CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 
					AS cancellaton_percent,
					 SUM(revenue) as Total_Revenue, 
					 SUM(CASE WHEN cancelled_0_1 =1 THEN revenue_loss ELSE 0 END) total_revenue_loss
FROM [dbo.hotel]
GROUP BY deposit_type
ORDER BY 3 DESC;
```
### Findings

The analysis results are summarized as follows:

- Finding out information relating to Booking Patterns:
During the first quarter of the year January, February March ,  and there is a lower booking rate during the second quarter of the year. And the highest booking year was 2016.

- Customer Behavior Analysis:
The distribution channel  that contributes the most bookings is the  'Online Travel Agent'. The average daily rate is closely tied between the 'Online Trave Agent' and 'Direct'. and mouch lower in the coporate and undefined channel. The countries of origin with the highest number of bookingas are mostly European countries ranging from Portugal, United Kingdom , France, Spain and  Germany and these countries contributes alot to the revenue.

- Cancellation Analysis:
There is a high cancellation rate in January, October and Febuary, and there are higher bookings during these period, and the customer's that paid with the non- refundable deposit type have a high rate of cancelling the booking. There is also a high cancellation rate among the Transient Customer type who booked through the Online Booking Agent. We also notice  a huge revenue loss within the transient customer type and the transient- type, also in the online travel agent booking channel.We can also predict that the higher  the lead time the higher tha chances of the booking being cancelled  will be.

- Revenue Optimization:
The first and fourth quarter of the year had a high revenue flow and checking  monthly we noticed high revenue flow in January, Febuary, March and then July. With yearly analysis we discovered the hotel had a high revenue inflow in 2016 and the revenue in 2017 was lower than 2016 with a loss of $6,359,445.93. For the ADR the transient customer type that booked through the online travel agent has the highest ADR, also  other customer types that booked through the online booking channel  have a high ADR, but the coporate booking channel has much lower ADR in every customer type bookings.
![da34ad23ab8c1473238d92d4e304bb5](https://github.com/CherryChristie/Splendour-Hotel-Group-Business-Analysis/assets/148567375/0f73935c-9788-41c1-b753-1b4e1eb7ed8b)

- Geographical Analysis:
Distribution of guest is higher in most european countries compared to non- european countries as the first ten countries with high revenue are european countries with Portugal, United Kingdom,France, Spain and Germany as top five. The extended stay are common among the countries with higher bookings, but the top then included two non european countries which are brazil, china and united states.

- Operational Efficiency:
The average lenght of stay is 3days and apart from the corporate booking channe, the rest all met the threshold of the average lenght of stay which is 3 days. Within the customer type, it is quite interesting to see that the contract customer type has average stay of 5 and the transient customer type (with the highest booking record) has an average lenght of stay of 3. For the checkout analysis , we discovered that there are more checkouts on sundays and fridays, there is a trend of high checkouts in the 3rd quarter of the year, specifically during august and july respectively.
![a5f43cd6f263e058e4c311b23844167](https://github.com/CherryChristie/Splendour-Hotel-Group-Business-Analysis/assets/148567375/d15367af-a70f-4415-bba2-fdb002b513a4)

- Impact of Deposit Types:
we discover that even though the 'No deposit'has high cancellatiom rate, but comparing it with the non refundable and the number of people that booked with
this deposit type, the presence of the non refundable increases the likelihood of cancellation but it does not have any revenue loss impact. But we also discovered that all the customer types prefers the no deposit deposit type followed by non refundable, therefore the high rate of choosing the no deposit policy will always result to high cancellation rate.
![306b80b0d747b639b1e1fcd2037c9cb](https://github.com/CherryChristie/Splendour-Hotel-Group-Business-Analysis/assets/148567375/1eeab393-c809-4932-b83a-98de6bad57b4)

- Time-to-Event Analysis:
we can see that bookings made in advance of 60+ days tend to generate more  revenue  but we also noticed that the cancellation rate in this advanced bookings are very high, whereas last minute bookings have lower cancellation rate. however for the customer satisfaction we discovered that bookings made closerto the date or with closer lead time might have higher customer satisfaction as it  has lower revenue loss and lower cancellation and moderate revenue.
![08ecbd1fd2c9484ac8fe8ebcb8989af](https://github.com/CherryChristie/Splendour-Hotel-Group-Business-Analysis/assets/148567375/b4d186d0-2d35-4282-8ce0-2884b677642b)

### Dashboard
![10382792753f948cd4a0ba256adfd7f](https://github.com/CherryChristie/Splendour-Hotel-Group-Business-Analysis/assets/148567375/6b637e4a-a3e2-4726-a815-7c2481fa7106)


### RECOMMENDATION

- Booking Patterns: We need to develop marketing campaigns to increase bookings during the lower second quarter. In depth analysis need to be done to analyze the factors contributing to the peak booking year of 2016 and consider replicating successful strategies.
- Customer Behavior Analysis : We need to invest in digital marketing strategies to strengthen the performance of 'Online Travel Agent' channels. We need to form partnerships with travel agents and tour operators in key European countries to capitalize on the high number of bookings from these regions.
- Cancellation Analysis:  We need to assess and potentially revise the cancellation policy for non-refundable deposits to lower the cancellation rate. We need to develop a more predictive model to forecast potential cancellations and strategize interventions.
- Revenue Optimization : We need to implement dynamic pricing strategies to optimize revenue throughout the year, focusing on high-revenue months. it is essential to tailor special offers to the 'Transient' customer segment, which shows a high ADR through the 'Online Travel Agent' channel.
- Geographical Analysis :  We need to consider directing marketing efforts towards European countries with high booking rates and explore opportunities in non-European markets with growth potential. We can explore creating attractive packages for guests from countries with a trend toward longer stays.
- Operational Efficiency : For effective and faster checkout services we need to aadjust staffing levels to align with the check-out trends, especially on high-volume days.
- Time-to-Event Analysis : We need to explore offering incentives for early bookings to reduce cancellations and maintain revenue.

### Limitation

I had to remove all zero values from revenue loss, average daily rate and revenue columns because they would have affected the accuracy of my conclusions from the analysis.

### Reference

1: Stack Overflow











 














