create database hotel_project;
use hotel_project;
--What is the trend in booking patterns over time, and are there specific seasons or months with increased booking activity

--booking overtime

SELECT DATEPART(QUARTER, booking_date) as Quaterly,  COUNT(*) AS total_booking
FROM [dbo.hotel]
GROUP BY DATEPART(QUARTER, booking_date)
ORDER BY 2 DESC;

SELECT DATEPART(MONTH, booking_date) as Monthly_Booking, DATEPART(YEAR, booking_date) Yearly_Booking,
		COUNT(booking_id) AS total_booking, SUM(revenue) as total_revenue
FROM [dbo.hotel]
GROUP BY DATEPART(MONTH, booking_date),DATEPART(YEAR, booking_date)
ORDER BY 4 DESC;

SELECT DATEPART(YEAR, booking_date) as Monthly_Booking, DATEPART(YEAR, booking_date) Yearly_Booking,
		COUNT(booking_id) AS total_booking, SUM(revenue) as total_revenue
FROM [dbo.hotel]
GROUP BY DATEPART(YEAR, booking_date),DATEPART(YEAR, booking_date)
ORDER BY 4 DESC;

--YEAR OVER YEAR
--YEAR OVER YEAR

WITH YearlySales AS
		  (SELECT DATEPART(YEAR, booking_date) sales_year, 
		  SUM(revenue) metrics, COUNT(booking_id) total_booking
FROM [dbo.hotel]
GROUP BY DATEPART(YEAR, booking_date))

SELECT	 a.sales_year,a.total_booking, 
		CAST((CASE  WHEN b.metrics IS NOT NULL AND b.metrics <> 0 
	    THEN ( a.metrics -b.metrics) / b.metrics ELSE 0 END)*100  AS INT) YoY_Growth
FROM YearlySales a
LEFT JOIN YearlySales b
ON  a.sales_year = b.sales_year +1;

--

--How does lead time vary across different booking channels, 
--and is there a correlation between lead time and customer tye
SELECT  AVG(lead_time) avg_customer_leadtime, distribution_channel
		FROM [dbo.hotel]
		GROUP BY  distribution_channel;

WITH total_avg AS 
		(SELECT AVG(lead_time) as all_avg_lead_time
		FROM [dbo.hotel]),

avg_customer_type AS 
		(SELECT customer_type, AVG(lead_time) avg_customer_leadtime,distribution_channel
		FROM [dbo.hotel]
		GROUP BY customer_type,distribution_channel)


SELECT c.customer_type, distribution_channel, c.avg_customer_leadtime, (c.avg_customer_leadtime - a.all_avg_lead_time)
AS average_diff
FROM total_avg a , avg_customer_type c 
ORDER BY 1;


--correlation btwn lead time and customer type
SELECT customer_type, AVG(lead_time) avg_customer_leadtime
		FROM [dbo.hotel]
		GROUP BY customer_type

--CUSTOMER ANALYSIS

--Which distribution channels contribute the most to bookings,
--and how does the average daily rate (ADR) differ across these channels?

SELECT    distribution_channel, COUNT(distribution_channel) as channel_count, ROUND(AVG(avg_daily_rate),3) adr
FROM [dbo.hotel]
GROUP BY distribution_channel
ORDER BY 3 DESC;

--Can we identify any patterns in the distribution of guests based on their country of origin,
--and how does this impact revenue?

SELECT country, COUNT(*) AS guests, SUM(revenue) AS total_revenue
FROM [dbo.hotel]
WHERE country IS NOT NULL
GROUP BY country
ORDER BY 3 DESC;

SELECT TOP 10 country, SUM(revenue_loss) Total_Revenue_Loss, COUNT(*) AS guests, SUM(revenue) AS total_revenue
FROM [dbo.hotel]
WHERE country IS NOT NULL
GROUP BY country
ORDER BY 3 DESC;


--CANCELLATION FACTORS

--What factors are most strongly correlated with cancellations,
--and can we predict potential cancellations based on certain variables?
SELECT customer_type,  COUNT(*) as total_booking,
	   SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS total_cancellation_rate,
	   CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 AS cancellation_percentage
FROM [dbo.hotel]
GROUP BY customer_type;

--This is useful for identifying 'high-risk' groups 
--that might require more attention or different strategies to reduce cancellations AND we discoerd that the customer group 
--with the highest booking also have a high cancellation.


--cancellation with booking channel

--and can we predict potential cancellations based on certain variables?
SELECT distribution_channel,  COUNT(*) as total_booking,
	   SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS total_cancellation_rate,
	   CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 AS 
	   cancellation_percentage
FROM [dbo.hotel]
GROUP BY distribution_channel
ORDER BY 2 DESC;



--by monthly basis
SELECT DATEPART(MONTH, booking_date) AS booking_month,  COUNT(*) as total_booking, SUM(revenue_loss) as 
		Total_Revenue_loss,
	   SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS total_cancellation_rate,
	   CAST(CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 AS INT) 
	   AS cancellation_percentage
FROM [dbo.hotel]
GROUP BY DATEPART(MONTH, booking_date) 
ORDER BY 4 DESC;


SELECT deposit_type,  COUNT(*) as total_booking, SUM(revenue_loss) as Total_Revenue_loss,
	   SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS total_cancellation_rate,
	   CAST(CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 AS INT) AS 
	   cancellation_percentage
FROM [dbo.hotel]
GROUP BY deposit_type 
ORDER BY 4 DESC;


-- cancellation by customer type
SELECT customer_type,  COUNT(*) as total_booking, 
	   SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS total_cancellation_count,
	  CAST(CAST(SUM(CASE WHEN cancelled_0_1 = 1 
	   THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 AS VARCHAR(10)) + '%'  AS cancellation_percentage
FROM [dbo.hotel]
GROUP BY customer_type
ORDER BY 1 DESC;

--AVG LEAD TIME OF BOTH CANCELLEDAND UNCANCELLED ORDER
SELECT 'Cancelled ' AS cancelled_booking, AVG(lead_time) AS avg_lead_time
FROM [dbo.hotel]
WHERE cancelled_0_1= 1

UNION ALL

SELECT 'Not Cancelled' AS non_cancelled_booking, AVG(lead_time) AS  avg_lead_time
FROM [dbo.hotel]
WHERE cancelled_0_1= 0


--since we have found the rates for the customer types, let us now check, where these customer types are booking from
--and also the cancellation information.

SELECT customer_type, distribution_channel,  COUNT(*) as total_booking, AVG(lead_time) AS avg_lead_time,
	   SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS total_cancellation_count,
	   CAST(CAST(SUM(CASE WHEN cancelled_0_1 = 1 
	   THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 AS VARCHAR(10)) + '%'  AS cancellation_percentage
FROM [dbo.hotel]
GROUP BY customer_type, distribution_channel
ORDER BY 1 DESC;


--REVENUE LOSS

--How does the revenue loss from cancellations compare across different customer segments and distribution channels?

SELECT customer_type , SUM(revenue_loss) total_revenue_loss
FROM [dbo.hotel]
WHERE cancelled_0_1 = 1
GROUP BY customer_type
ORDER BY total_revenue_loss ;

--REVENUE LOSS FOR DISTRIBUTION CHANNEL
SELECT distribution_channel, SUM(revenue_loss) total_revenue_loss
FROM [dbo.hotel]
WHERE cancelled_0_1 = 1
GROUP BY distribution_channel
ORDER BY 2 ;

--there is a massive revenue loss in the online agent and this goes with the fact that alot of transient customer type
-- are using the online travel agent, so there is a relationship which causes this



--REVENUE

--What is the overall revenue trend, 
--and are there specific customer segments or countries contributing significantly to revenue?
SELECT  SUM(revenue)Total_Revenue
FROM [dbo.hotel];

--the quaterly  trend

SELECT DATEPART(QUARTER, booking_date) AS booking_month, SUM(revenue_loss) as total_revenue_loss,
		SUM(revenue) as total_revenue
FROM dbo.hotel_datebase
GROUP BY  DATEPART(QUARTER	, booking_date)
ORDER BY 3 DESC;


--, with a monthly analysis we will see more details on the specific months 


--MONTHLY REVENUE
SELECT DATEPART(MONTH, booking_date) AS booking_month,SUM(revenue) as total_revenue,
	SUM(revenue_loss) as total_revenue_loss	
FROM dbo.hotel_datebase
GROUP BY  DATEPART(MONTH	, booking_date)
ORDER BY 2 DESC;



--customer type + reveneue
WITH All_Revenue AS 
	  (SELECT SUM(revenue) AS Overall_revenue
	  FROM [dbo.hotel])


SELECT customer_type, SUM(revenue) as total_revenue,
CAST((SUM(h.revenue) / t.Overall_revenue) * 100.0 AS VARCHAR(10)) + '%' AS revenue_percentage
FROM [dbo.hotel] h,
 All_Revenue t
GROUP BY customer_type, t.Overall_revenue
ORDER BY 2 DESC;

--THE transient customer brought in the highest revenue , with a revenue avg of 76, this is because it also is made up of 
-- more than half of the guests

--the 


--country + revenue
SELECT country, SUM(revenue) as total_revenue
FROM [dbo.hotel]
GROUP BY country
ORDER BY 2 DESC;

--FROM THIS WE CAN SEE THE  the top five countries with the highest revenue are mainly european countries
-- with portugal being the first followed by united kingdom


--yearly revenue

SELECT DATEPART(YEAR, booking_date) as Booking_Year, SUM(revenue) AS Total_Revenue
FROM [dbo.hotel]
WHERE revenue IS NOT NULL
GROUP BY DATEPART(YEAR, booking_date)
ORDER BY 2 DESC;


--ADR ANALYSIS

--Can we identify optimal pricing strategies based on 
--the Average Daily Rate (ADR) for different customer types and distribution channels?
--customer type
SELECT customer_type, distribution_channel, AVG(avg_daily_rate) AS  avg_adr
FROM [dbo.hotel]
GROUP BY customer_type, distribution_channel
ORDER BY  1 DESC;


--distribution
SELECT distribution_channel, AVG(avg_daily_rate) AS  avg_adr
FROM [dbo.hotel]
GROUP BY distribution_channel

--Geographical Analysis:

--How does the distribution of guests vary across different countries,
--and are there specific countries that should be targeted for marketing efforts?
SELECT country, COUNT(*) as country_count, SUM(revenue) AS total_revenue
FROM [dbo.hotel]
WHERE country IS NOT NULL
GROUP BY country
ORDER BY 3 DESC;


--and are there specific countries that should be targeted for marketing efforts?
SELECT country, COUNT(*) as country_count, 	AVG(revenue) AS avg_revenue	
FROM [dbo.hotel]
WHERE country IS NOT NULL 
GROUP BY country
HAVING AVG(revenue) < (SELECT AVG(revenue) FROM [dbo.hotel])
ORDER BY 3 DESC;

--Is there a correlation between the country of origin and the likelihood of cancellations or extended stays?

SELECT country,  SUM(CASE WHEN cancelled_0_1 =1 THEN 1 ELSE 0 END) AS total_cancellation
FROM [dbo.hotel]
GROUP BY country
ORDER BY 2 DESC;

--exteended stays
SELECT country, COUNT (nights) night_count
FROM [dbo.hotel]
WHERE country IS NOT NULL and nights < 2
GROUP BY country
ORDER BY 2 DESC;

--OPERATIONAL ANALYIS

--What is the average length of stay for guests, and 
--how does it differ based on booking channels or customer types?

--average stay lenght
SELECT AVG(nights) avg_stay
FROM [dbo.hotel];


--
--lenght of stay distribution channel

SELECT distribution_channel, AVG(nights) AS avg_night
FROM [dbo.hotel]
GROUP BY distribution_channel;


--lenght of stay customer types
SELECT customer_type, AVG(nights) AS avg_night
FROM [dbo.hotel]
GROUP BY customer_type;


--Are there patterns in check-out dates that can inform staffing and resource allocation strategies?

--checking the days of the week that has more checkouts, this will help to understand how to allocate budject for 
--operations like cleaning services and more hotel checkout representatives. 

--CHECKOUT DAYS ANALYSIS
SET DATEFIRST 1;

WITH ss AS 
		   (SELECT DATEADD(day, nights, arrival_date) AS checkout_date, COUNT(*) AS total_checkout, SUM(guests) as
		   total_guest
			FROM [dbo.hotel]
			WHERE cancelled_0_1 = 0
			GROUP BY DATEADD(day, nights, arrival_date)
			)

SELECT DATEPART(dw, checkout_date) as DayoftheWeek, SUM(total_checkout) Total_Checkouts, SUM(total_guest) Total_Guest
FROM ss
GROUP BY DATEPART(dw, checkout_date)
ORDER BY 2 DESC;



WITH ss AS 
		   (SELECT DATEADD(day, nights, arrival_date) AS checkout_date, COUNT(*) AS total_checkout, SUM(guests) as
		   total_guest
			FROM [dbo.hotel]
			WHERE cancelled_0_1 = 0
			GROUP BY DATEADD(day, nights, arrival_date)
			)

SELECT DATEPART(MONTH, checkout_date) as DayoftheWeek, SUM(total_checkout) Total_Checkouts, SUM(total_guest) Total_Guest
FROM ss
GROUP BY DATEPART(MONTH, checkout_date)
ORDER BY 2 DESC;


--Impact of Deposit Types:

--How does the presence or absence of a deposit impact the likelihood of cancellations and revenue generation?

SELECT Deposit_type , COUNT(*) AS Total_Bookings, 
					 SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) cancellation_total,
					CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 
					AS cancellaton_percent,
					 SUM(revenue) as Total_Revenue, 
					 SUM(CASE WHEN cancelled_0_1 =1 THEN revenue_loss ELSE 0 END) total_revenue_loss
FROM [dbo.hotel]
GROUP BY deposit_type
ORDER BY 3 DESC;


--Can we identify any patterns in the use of deposit types across different customer segments?

--customer type and deposit type
SELECT  customer_type, deposit_type , COUNT(deposit_type)
FROM [dbo.hotel]
GROUP BY customer_type, deposit_type 
ORDER BY 1;


--the pattern we can derive frrom here is that the different customer types prefers the No deposit policy 
--marketing strategiees needs to be targeted on the non refundable policy since it helps to prevent revenue loss


--What is the proportion of corporate bookings, and how does their Average Daily Rate (ADR) compare to other customer types?

SELECT (SELECT COUNT(*) FROM [dbo.hotel] WHERE distribution_channel= 'corporate') *100.0 / 
		(SELECT	   COUNT(*) FROM [dbo.hotel])  corporate_percentage

--the corporate  bookings has only 5percent of all the distrubtion channels.



WITH t1 AS (SELECT customer_type, AVG(avg_daily_rate)  corporate_avg_adr
FROM [dbo.hotel]
WHERE distribution_channel = 'corporate'
GROUP BY customer_type),


t2 AS (SELECT customer_type, AVG(avg_daily_rate) total_avg_adr
FROM [dbo.hotel]
GROUP BY customer_type)

SELECT a.customer_type, corporate_avg_adr, total_avg_adr, (corporate_avg_adr - total_avg_adr) as  ADR_diff
FROM t1 a
LEFT JOIN t2 b
ON a.customer_type = b.customer_type



--Are there specific trends or patterns related to corporate bookings that can inform business strategies?

SELECT TOP 10 country, COUNT(distribution_channel) AS coporate_distribution_count
FROM [dbo.hotel]
WHERE country IS NOT NULL AND  distribution_channel= 'corporate'
GROUP BY country
ORDER BY 2 DESC;


SELECT DATEPART(QUARTER, booking_date) Booking_Quarter, COUNT(*) as corporate_distribution_count
FROM [dbo.hotel]
WHERE  distribution_channel = 'corporate'
GROUP BY DATEPART(QUARTER, booking_date)
ORDER BY 2 DESC;

--there is a high trend during the first quarter of the year, this might go with the fact that most of the bookings
-- occurs during the first quarter of the year


SELECT DATEPART(YEAR, booking_date) Booking_Year, COUNT(*) as corporate_distribution_count
FROM [dbo.hotel]
WHERE  distribution_channel = 'corporate'
GROUP BY DATEPART(YEAR, booking_date)
ORDER BY 2 DESC;



---Time-to-Event Analysis


--How does the time between booking and arrival date (lead time) affect revenue and the likelihood of cancellations?

SELECT   CASE WHEN DATEDIFF(day, booking_date, arrival_date) BETWEEN 0 AND 7 THEN '0-7 DAYS'
		      WHEN DATEDIFF(day, booking_date, arrival_date) BETWEEN 8 AND 30 THEN '8 - 30 DAYS'
			  WHEN DATEDIFF(day, booking_date, arrival_date) BETWEEN 31 AND 60 THEN '31 - 60 DAYS'
			  ELSE '60+' END AS leadtimedays,    COUNT(*) Overallbookings, 
	   SUM(CASE WHEN cancelled_0_1=1 THEN 1 ELSE 0 END) AS cancellation_rate,
	  ROUND(CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0, 2) 
					AS cancellaton_percent, AVG(revenue) as avg_revenue, AVG(revenue_loss) avg_revenue_loss
FROM [dbo.hotel]
GROUP BY CASE WHEN DATEDIFF(day, booking_date, arrival_date) BETWEEN 0 AND 7 THEN '0-7 DAYS'
		      WHEN DATEDIFF(day, booking_date, arrival_date) BETWEEN 8 AND 30 THEN '8 - 30 DAYS'
			  WHEN DATEDIFF(day, booking_date, arrival_date) BETWEEN 31 AND 60 THEN '31 - 60 DAYS'
			   ELSE '60+' END
ORDER BY 5 DESC ;



--Are there specific lead time ranges that are associated with higher customer satisfaction or revenue?

--Comparison of Online and Offline Travel Agents:


--What is the revenue contribution of online travel agents compared to offline travel agents?
SELECT  SUM(revenue) total_revenue,
	   SUM (CASE WHEN distribution_channel = 'Online Travel Agent' THEN revenue  END) AS online_channel_revenue,
		SUM(CASE WHEN distribution_channel = 'Offline Travel Agent' THEN revenue
				 END ) offline_channel_revenue,
      ROUND( SUM(CASE WHEN distribution_channel = 'Online Travel Agent' THEN revenue  END) / SUM(revenue) *100.00 , 2) online_channel_percent,
	   ROUND(SUM(CASE WHEN distribution_channel = 'Offline Travel Agent' THEN revenue
				 END ) / SUM(revenue) * 100.00, 2) offline_channel_percent
FROM [dbo.hotel]


--How do cancellation rates and revenue vary between bookings made through online and offline travel agents?
SELECT  distribution_channel, COUNT(*) total_bookings,
        SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) cancellation_total,
		ROUND(CAST(SUM(CASE WHEN cancelled_0_1 = 1 THEN 1 ELSE 0 END) AS FLOAT)/ NULLIF(COUNT(*),0) * 100.0 ,2)
					AS cancellaton_percent,
		SUM(revenue) as Total_Revenue
FROM [dbo.hotel]
WHERE distribution_channel IN ('Online Travel Agent', 'Offline Travel Agent')
GROUP BY  distribution_channel;


