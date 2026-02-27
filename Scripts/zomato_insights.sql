CREATE DATABASE zomato_insights_db;
USE zomato_insights_db;
SET GLOBAL local_infile = 1;
CREATE TABLE zomato (
    restaurant_name VARCHAR(255),
    online_order ENUM('Yes', 'No'),
    book_table ENUM('Yes', 'No'),
    rate DECIMAL(3,1),  
    votes INT,
    approx_cost_for_two INT,
    listed_in_type VARCHAR(100)
);

ALTER TABLE zomato
RENAME COLUMN approx_cost_for_two TO approx_cost_for_two_person;
SELECT DISTINCT listed_in_type
FROM zomato
WHERE LOWER(TRIM(listed_in_type)) = 'others';

UPDATE zomato
SET listed_in_type = 'Others'
WHERE TRIM(listed_in_type) = 'other';
LOAD DATA LOCAL INFILE '/Users/rahulchaudhary/Downloads/Zomato_data.csv'
INTO TABLE zomato
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM zomato;
USE zomato_insights_db;

--🧱 Foundation KPIs (What leadership asks first)
/*QUERY 1. Marketplace Composition
    * How is the Zomato restaurant marketplace distributed by listed_in_type?
    * Which category dominates the platform?
*/
--Part 1
SELECT DISTINCT listed_in_type,
       COUNT(restaurant_name) AS Total_Restaurant
FROM zomato
GROUP BY listed_in_type
ORDER BY Total_Restaurant DESC;

--Part 2
SELECT DISTINCT listed_in_type,
       COUNT(restaurant_name) AS Total_Restaurant
FROM zomato
GROUP BY listed_in_type
ORDER BY Total_Restaurant DESC
LIMIT 1;

/*QUERY 2
Online Ordering Penetration
    * What % of restaurants support online ordering?
    * How does this split differ by listed_in_type?
*/
--Part 1
WITH online_hotels AS
(
SELECT COUNT(restaurant_name) AS Total_Restaurant ,
       COUNT(CASE 
       WHEN online_order='Yes' THEN 1 END
       ) AS Total_Online_Restaurant
FROM zomato
)
SELECT CONCAT(ROUND((Total_Online_Restaurant/Total_Restaurant)*100.0,2)," %") AS Online_Hotel_Percentage
FROM online_hotels;

/*
🔎 Insight:-
Approximately 39.19% of restaurants offer online ordering, 
indicating that digital adoption is present but not yet dominant across the platform.
*/

--Part 2
WITH online_hotels AS
(
SELECT listed_in_type,
       COUNT(restaurant_name) AS Total_Restaurant ,
       COUNT(CASE 
       WHEN online_order='Yes' THEN 1 END
       ) AS Total_Online_Restaurant
FROM zomato
GROUP BY listed_in_type
)
SELECT listed_in_type AS Category ,CONCAT(ROUND((Total_Online_Restaurant*100.0/Total_Restaurant),2)," %") AS Online_Hotel_Percentage
FROM online_hotels
ORDER BY Online_Hotel_Percentage DESC;

/*
🔎 Insight:-

Online ordering adoption is highest in Others 75% and Cafes 65.22%, 
moderate in Buffet 57.14%, and significantly lower in Dining (30%),
indicating uneven digital penetration across categories.
*/



/* Query 3. Table Booking Adoption
    * What proportion of restaurants offer table booking?
    * Is table booking more common in certain categories?
*/
--Part 1
WITH online_table_booking AS 
(
SELECT COUNT(restaurant_name) AS Total_Hotels,
       COUNT(CASE
                WHEN book_table='Yes' THEN 1 END) AS Online_Booking
FROM zomato
)
SELECT CONCAT(ROUND((Online_Booking/Total_Hotels)*100.0,2)," %") AS Provide_Booking_Hospitality
FROM online_table_booking;
/*
🔎 Insight:

Only 5.41% of restaurants offer table booking, 
indicating extremely low adoption of reservation-based dining across the platform.
*/

--Part 2
WITH online_table_booking AS 
(
SELECT listed_in_type,COUNT(restaurant_name) AS Total_Hotels,
       COUNT(CASE
                WHEN book_table='Yes' THEN 1 END) AS Online_Booking
FROM zomato
GROUP BY listed_in_type
)
SELECT listed_in_type AS Category,
       CONCAT(ROUND((Online_Booking/Total_Hotels)*100.0,2)," %") 
       AS Provide_Booking_Hospitality
FROM online_table_booking
ORDER BY Provide_Booking_Hospitality DESC;

/*
🔎 Insight:-
Table booking adoption is highest in Others --> 25%, 
followed by Buffet --> 14.29% and Cafes -->13.04% , 
while Dining shows minimal penetration --> 1.82%,
suggesting reservation features are concentrated in select premium segments rather than mass-market categories.
*/


/* Query 4. Rating Health Check
    * What is the overall average rating on the platform?
    * Which listed_in_type categories perform above and below the platform average?
*/
--Part 1
SELECT
        CONCAT(ROUND(AVG(rate),2)," ⭐️") AS Overall_Average_Ratings
 FROM zomato;
/*
🔎 Insight:-
The platform maintains a moderate overall customer satisfaction level (3.53 ⭐️),
indicating acceptable performance but significant scope for quality enhancement across categories.
*/
 --Part 2
WITH overall_rating AS
(
    SELECT ROUND(AVG(rate), 2) AS overall_avg
    FROM zomato
),
rating_of_types AS
(
    SELECT 
        listed_in_type,
        ROUND(AVG(rate), 2) AS avg_rating
    FROM zomato
    GROUP BY listed_in_type
)
SELECT 
    r.listed_in_type AS Category,
    CONCAT(r.avg_rating, ' ⭐️') AS overall_ratings
FROM rating_of_types r
JOIN overall_rating o
ON r.avg_rating > o.overall_avg;

/*
🔎 Insight:
Others 3.91 ⭐️ leads in customer satisfaction, 
followed by Buffet 3.84 ⭐️ and Cafes 3.77 ⭐️, 
indicating stronger perceived quality in these categories compared to the platform average.

*/


/* Query 5. Customer Engagement Proxy
    * How are votes distributed across restaurants?
    * Do categories with higher votes also show higher average ratings?
*/
--Part 1
SELECT 
      CASE 
          WHEN votes < 50 THEN 'Low'
          WHEN votes BETWEEN 50 AND 200 THEN 'Medium'
          WHEN votes BETWEEN 201 AND 500 THEN 'High'
          ELSE 'Very High'
          END AS Vote_Band,
          COUNT(Restaurant_name) AS Total_Hotels
FROM zomato
GROUP BY Vote_Band
ORDER BY Total_Hotels DESC;

/*
🔎 Insight:
The majority of restaurants fall in the Low vote band 76, 
indicating limited customer engagement across the platform, 
while only a small segment achieves High 16 and Very High 23 engagement levels, 
reflecting a concentrated popularity among select restaurants.
*/

--Part 2
SELECT 
      CASE 
          WHEN votes < 50 THEN 'Low'
          WHEN votes BETWEEN 50 AND 200 THEN 'Medium'
          WHEN votes BETWEEN 201 AND 500 THEN 'High'
          ELSE 'Very High'
          END AS Vote_Band,
          COUNT(Restaurant_name) AS Total_Hotels,
          CONCAT(ROUND(AVG(Votes),2)," 🗳️") AS Average_Votes
FROM zomato
WHERE rate IS NOT NULL
GROUP BY Vote_Band
ORDER BY Total_Hotels DESC;

/*
🔎 Insight:

Customer engagement is heavily concentrated in the upper tiers, 
with the Very High vote band averaging 1304.87 votes,
while the majority of restaurants remain in the Low engagement segment (avg ~12 votes), 
indicating strong visibility imbalance across the platform.
*/

/* Which Category of Restaurants is High In Revenue
*/
SELECT * FROM zomato;
SELECT listed_in_type AS Category,
        COUNT(DISTINCT restaurant_name) AS Total_Hotels,
       CONCAT(SUM(approx_cost_for_two_person)," ₹") AS Total_Profit
FROM zomato
GROUP BY Category
ORDER BY Total_Hotels DESC;
/*
🔎 Insight:
Dining appears to dominate in total aggregated pricing due to its significantly larger number of restaurants, 
while Buffet contributes the least because of its smaller category size.
*/

--📊 Performance & Quality (Mid-level Product/Partner Insights)
/*
Query 1. Category Quality Benchmarking
    * Which listed_in_type categories consistently underperform on ratings?
    * Which categories have high variance in ratings (inconsistent quality)?
*/
--Part 1
SELECT listed_in_type AS Category, 
CONCAT(ROUND(AVG(rate),2)," ⭐️") AS Rating
FROM zomato
GROUP BY listed_in_type
ORDER BY Rating ASC LIMIT 1;

/*
🔎 Insight:-
Dining is the lowest-performing category in terms of average customer rating, 
indicating consistent underperformance relative to other segments.
*/

--Part 2
SELECT listed_in_type AS Category,
      CONCAT(ROUND(AVG(rate),2)," ⭐️" ) AS Rating,
      ROUND(STDDEV(rate),2) AS Std_Dev_Rating
FROM zomato
GROUP BY listed_in_type
ORDER BY Std_Dev_Rating DESC;
/*
🔎 Quality Consistency Insights:-
Others 0.64 shows the highest rating variability, 
indicating inconsistent quality — strong performers exist, 
but so do weak ones.
Buffet 0.18 demonstrates the most stable and consistent customer experience.
Dining, despite being lowest in rating, 
shows moderate variance — meaning it is consistently average/weak rather than volatile.
*/



/*
Query 2. Value-for-Money Identification
    * Which restaurants deliver high ratings at lower-than-average cost for two?
    * Which categories offer the best value-for-money on average?
*/
--Part 1
WITH Overall_AVG AS
(
SELECT
      AVG(approx_cost_for_two_person) AS Overall_Avg_Cost
FROM zomato
)
SELECT z.restaurant_name,
       z.rate,z.approx_cost_for_two_person
FROM zomato as z
JOIN Overall_AVG AS oa
ON 1=1
WHERE rate >= 4.0 AND z.approx_cost_for_two_person < Overall_Avg_Cost
ORDER BY rate DESC, approx_cost_for_two_person ASC; 

/*
🔎 Insight:-
Several restaurants deliver strong customer satisfaction (≥4.0 rating) while remaining priced below the platform’s average cost, 
indicating the presence of high-performing, affordable dining options that represent strong value propositions.
👉 These are your “hidden gems” — premium experience without premium pricing.
*/

--Part 2
SELECT 
    listed_in_type AS Hotel_Category,
    ROUND(AVG(rate), 2) AS Avg_Rating,
    ROUND(AVG(approx_cost_for_two_person), 0) AS Avg_Cost,
    ROUND(AVG(rate) / AVG(approx_cost_for_two_person)*1000.0, 1) AS Value_Score
FROM zomato
WHERE rate IS NOT NULL
GROUP BY listed_in_type
ORDER BY avg_rating DESC, Value_Score DESC, avg_cost ASC;

/*
🔎 Insight:-
Dining exhibits the highest value efficiency score due to lower average pricing, 
while Others leads in customer satisfaction but at higher cost levels. 
Cafes represent a balanced mid-tier value segment, 
whereas Buffet offers strong quality with moderate price efficiency.
*/

/*
Query 3. Pricing vs Experience Relationship
    * Is there a noticeable relationship between approx_cost_for_two and rate?
    * Are premium-priced restaurants actually delivering better customer experience?
*/
-- Part 1
WITH stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(rate) AS sum_x,
        SUM(approx_cost_for_two_person) AS sum_y,
        SUM(rate * rate) AS sum_x2,
        SUM(approx_cost_for_two_person * approx_cost_for_two_person) AS sum_y2,
        SUM(rate * approx_cost_for_two_person) AS sum_xy
    FROM zomato
    WHERE rate IS NOT NULL
)
SELECT
   
    ROUND((n * sum_x2 - POWER(sum_x, 2)) / (n * (n - 1)),2) AS var_x,

  
    ROUND((n * sum_y2 - POWER(sum_y, 2)) / (n * (n - 1)),2) AS var_y,

   
    ROUND((n * sum_xy - sum_x * sum_y) / (n * (n - 1)),2) AS cov_xy,

    ROUND((
        (n * sum_xy - sum_x * sum_y)
        /
        SQRT(
            (n * sum_x2 - POWER(sum_x, 2)) *
            (n * sum_y2 - POWER(sum_y, 2))
        )
    ),2) AS correlation_xy

FROM stats;

--Insight

/*

📊 Statistical Result

Correlation = 0.28

That means:

There is a weak positive relationship between price and rating.

As cost increases, rating tends to increase slightly.

But the relationship is not strong.

🎯 So… Are Premium Restaurants Delivering Better Experience?

Short Answer:
➡️ Slightly, but not significantly.
*/



/*
Query 4. Feature Impact Analysis
    * Do restaurants offering online ordering and Online Booking receive higher ratings on average?
    * Does table booking correlate with higher votes or ratings?
*/

WITH overall_avg AS (
    SELECT ROUND(AVG(rate), 2) AS overall_rating
    FROM zomato
    WHERE rate IS NOT NULL
),
online_impact AS (
    SELECT 
        online_order,
        ROUND(AVG(rate), 2) AS avg_rating,
        COUNT(*) AS total_restaurants
    FROM zomato
    WHERE rate IS NOT NULL
    GROUP BY online_order
),
table_booking_impact AS (
    SELECT 
        book_table,
        ROUND(AVG(rate), 2) AS avg_rating,
        ROUND(AVG(votes), 0) AS avg_votes,
        COUNT(*) AS total_restaurants
    FROM zomato
    WHERE rate IS NOT NULL
    GROUP BY book_table
)
-- Online Order Impact
SELECT 
    'Online Order' AS 'Feature Type',
    o.online_order AS 'Feature Value',
    o.avg_rating AS 'Average Rating',
    overall.overall_rating AS 'Overall Rating',
    ROUND(o.avg_rating - overall.overall_rating, 2) AS 'Difference From Overall',
    o.total_restaurants AS 'Total Restaurants'
FROM online_impact AS  o
CROSS JOIN overall_avg AS overall

UNION ALL
-- Table Booking Impact
SELECT 
    'Table Booking' AS 'Feature Type',
    t.book_table AS 'Feature Value',
    t.avg_rating AS 'Average Rating',
    overall.overall_rating AS 'Overall Rating',
    ROUND(t.avg_rating - overall.overall_rating, 2) AS 'Difference From Overall',
    t.total_restaurants AS 'Total Restaurants'
FROM table_booking_impact AS t
CROSS JOIN overall_avg AS overall;

/*
Insight:-
Restaurants offering online ordering show a modest uplift in ratings (+0.23). 
Table booking restaurants demonstrate significantly higher ratings (+0.56),
though the small sample size limits strong causal conclusions.
*/


/*
5. Long Tail Quality Risk
* What proportion of restaurants have low ratings and low votes?
*/
SELECT * FROM zomato;
DESCRIBE zomato;
WITH vote_bucketed AS (
    SELECT 
        restaurant_name,
        rate,
        votes,
        NTILE(4) OVER (ORDER BY votes) AS vote_quartile
    FROM zomato
),
overall_rating AS (
    SELECT AVG(rate) AS avg_rating
    FROM zomato
    WHERE rate IS NOT NULL
)
SELECT 
    CONCAT(ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM zomato),
        2
    )," %") AS Proportion

FROM vote_bucketed vb
CROSS JOIN overall_rating orr
WHERE vb.vote_quartile = 1
AND vb.rate < orr.avg_rating;

/*
Insight:-
Approximately 21% of restaurants fall into the low-performance quadrant, 
characterized by both low customer ratings and low engagement levels. 
This segment may require targeted operational improvements or visibility enhancement strategies.
*/


--🚀 Growth & Strategy (Senior Analyst / Product Strategy Level)

/*
1. Partner Segmentation
* Segment restaurants into performance buckets based on rating and cost.
* What % of partners fall into each bucket?
*/
SELECT * FROM zomato;
WITH overall_metrics AS (
    SELECT 
        AVG(rate) AS overall_avg_rating,
        AVG(approx_cost_for_two_person) AS overall_avg_cost
    FROM zomato
),
segment_partner AS (
    SELECT 
        z.restaurant_name,
        z.rate,
        z.approx_cost_for_two_person,
        CASE 
            WHEN z.rate >= om.overall_avg_rating 
                 AND z.approx_cost_for_two_person >= om.overall_avg_cost 
                 THEN 'Premium Performers'

            WHEN z.rate >= om.overall_avg_rating 
                 AND z.approx_cost_for_two_person < om.overall_avg_cost 
                 THEN 'Value Leaders'

            WHEN z.rate < om.overall_avg_rating 
                 AND z.approx_cost_for_two_person >= om.overall_avg_cost 
                 THEN 'Overpriced / Risky'

            ELSE 'Underperformers'
        END AS segment
    FROM zomato AS z
    CROSS JOIN overall_metrics AS om
)
SELECT 
    segment,
    COUNT(*) AS total_restaurants,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato), 2)," %") AS Ratio
FROM segment_partner
GROUP BY segment
ORDER BY total_restaurants DESC;

/*
🔎 Partner Segmentation Insights:-
🟥 Underperformers — 34.46%
Over one-third of restaurants fall into the low-rating, 
low-cost segment, indicating a substantial portion of partners operate at below-average experience levels, 
even if priced affordably.

🟩 Premium Performers — 30.41%
Nearly one-third of restaurants successfully justify higher pricing with strong customer ratings, 
representing a solid premium-performing segment on the platform.

🟦 Value Leaders — 22.97%
About 23% of restaurants deliver above-average ratings at lower-than-average pricing, 
forming a strong value-for-money segment and potential growth drivers.

🟨 Overpriced / Risky — 12.16%
A smaller but important segment is priced above average while delivering below-average ratings, 
indicating potential pricing misalignment or experience gaps.

*/

/*
2. Category Saturation Risk
* Which categories are highly saturated but have declining average ratings?
* Which categories show room for differentiation based on quality?
*/
--Part 1
SELECT 
    listed_in_type AS Category,
    COUNT(*) AS Total_Restaurants,
    ROUND(AVG(rate), 2) AS Avg_Rating,
    ROUND(STDDEV(rate), 2) AS Rating_Variability
FROM zomato
WHERE rate IS NOT NULL
GROUP BY listed_in_type
ORDER BY Total_Restaurants DESC;

/*
🔎 Insight:-
🔴 Dining (110 restaurants | 3.57 ⭐️)
Dining is heavily saturated (74% of total partners) yet records the lowest average rating, 
indicating overcrowding combined with weaker perceived quality.

This suggests:
1.Intense competition
2.Quality dilution
3.Potential commoditization

👉 Dining is the most saturated but underperforming segment.

*/

--Part 2
SELECT 
       listed_in_type AS Category,
       ROUND(AVG(rate), 2) AS Avg_Rating,
       ROUND(STDDEV(rate), 2) AS Rating_Variability
FROM zomato
GROUP BY Category;

/*
🔎 Insight:- 
Part 2 – Room for Differentiation (Quality-Based)
🔥 Others (Highest Variability – 0.64)

Others shows the highest rating variability, 
indicating inconsistent quality across restaurants. 
This category offers strong room for differentiation, as improving consistency could create competitive advantage.

🟡 Cafes & Dining (Moderate Variability ~ 0.37–0.38)

Cafes and Dining display moderate variability, suggesting some quality gaps but relatively stable performance. 
Differentiation is possible but competitive pressure may limit margin.

🟢 Buffet (Lowest Variability – 0.18)

Buffet is highly consistent in customer ratings, indicating a mature and stable segment with limited room for differentiation based on quality alone.

*/


/*
3. Monetization Potential
* Which categories combine high customer engagement (votes) with premium pricing?
* Where could Zomato push premium partnerships or ads?

*/
WITH overall_metrics AS (
    SELECT 
        AVG(votes) AS overall_avg_votes,
        AVG(approx_cost_for_two_person) AS overall_avg_cost
    FROM zomato
),
category_metrics AS (
    SELECT 
        listed_in_type AS Category,
        AVG(votes) AS avg_votes,
        AVG(approx_cost_for_two_person) AS avg_cost
    FROM zomato
    WHERE votes IS NOT NULL
    GROUP BY listed_in_type
)
SELECT 
    cm.Category,
    ROUND(cm.avg_votes, 2) AS Avg_Votes,
    ROUND(cm.avg_cost, 2) AS Avg_Cost,
    CASE 
        WHEN cm.avg_votes > om.overall_avg_votes 
             AND cm.avg_cost > om.overall_avg_cost
        THEN 'High Monetization Potential'
        ELSE 'Standard Segment'
    END AS Segment
FROM category_metrics cm
CROSS JOIN overall_metrics om
ORDER BY Avg_Votes DESC;

/*
🔎 Insight:- 
Categories that combine high customer engagement with above-average pricing represent strong candidates for premium ad placements and partnership monetization strategies.
*/


/*
4. Operational Leverage
* In which categories is online ordering adoption low despite high ratings?

*/      
WITH category_metrics AS (
    SELECT 
        listed_in_type AS Category,
        COUNT(*) AS total_restaurants,
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) AS Available_Online,
        AVG(rate) AS avg_rating
    FROM zomato
    WHERE rate IS NOT NULL
    GROUP BY listed_in_type
)
SELECT 
    Category,
    Total_Restaurants,
    Available_Online,
    CONCAT(ROUND(Available_Online * 100.0 / total_restaurants, 2)," %") AS Online_Adoption_Ratio,
    ROUND(avg_rating, 2) AS Avg_Rating
FROM category_metrics
ORDER BY avg_rating DESC;

/*
🔎 Insight:-
Dining exhibits low online ordering adoption (30%) despite representing the largest category, 
indicating significant operational leverage opportunity through digital enablement and delivery expansion.
*/


/*
5. Portfolio Risk Exposure
* What % of restaurants are low-rated but high-cost?
* How risky is the current partner mix for user satisfaction?
*/
WITH overall_metrics AS (
    SELECT
        AVG(rate) AS avg_rating,
        AVG(approx_cost_for_two_person) AS avg_cost
    FROM zomato
)
SELECT
    COUNT(*) AS Total_Restaurants,

    SUM(CASE 
        WHEN z.rate < om.avg_rating 
             AND z.approx_cost_for_two_person > om.avg_cost
        THEN 1 ELSE 0 END) AS Overpriced_Segment,

    CONCAT(ROUND(
        SUM(CASE 
            WHEN z.rate < om.avg_rating 
                 AND z.approx_cost_for_two_person > om.avg_cost
            THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    )," %") AS Risk_Ratio

FROM zomato z
CROSS JOIN overall_metrics om;

/*
🔎 Key Insights
🔴 Portfolio Risk Exposure = 12.16%
Approximately 12% of restaurants are overpriced relative to their quality, 
meaning they charge above-average prices while delivering below-average ratings.
This represents a moderate risk zone within the partner portfolio.
*/


--🧠 Executive / Portfolio-Grade Questions
/*
1. Marketplace Health Scorecard
* Design a scorecard combining: rating, votes, cost, and online availability.
Do it based On Assigned Formula
Score=0.4×Rating_Score+0.3×Vote_Score+0.2×Cost_Score+0.1×Online_Score

* Which categories rank best and worst on overall marketplace health?
Health=0.4×Rating+0.3×Votes+0.2×Cost+0.1×Online
*/
--Pat 1
WITH global_metrics AS (
    SELECT 
        NULLIF(MAX(votes), 0) AS max_votes,
        NULLIF(MAX(approx_cost_for_two_person), 0) AS max_cost
    FROM zomato
),
score_metrics AS (
    SELECT 
        DISTINCT z.restaurant_name,
        CAST(SUBSTRING_INDEX(z.rate, '/', 1) AS DECIMAL(3,1)) / 5.0 AS Rating_Score,
        z.votes / gm.max_votes AS Vote_Score,
        1 - (z.approx_cost_for_two_person / gm.max_cost) AS Cost_Score,
        CASE 
            WHEN z.online_order = 'Yes' THEN 1 
            ELSE 0 
        END AS Online_Score
    FROM zomato z
    CROSS JOIN global_metrics gm
    WHERE z.rate IS NOT NULL
)
SELECT 
    DISTINCT restaurant_name AS Restaurant,
    ROUND(
        (0.4 * Rating_Score) +
        (0.3 * Vote_Score) +
        (0.2 * Cost_Score) +
        (0.1 * Online_Score),
        2
    ) AS Performance_Score,
    DENSE_RANK() OVER(ORDER BY 
        (0.4 * Rating_Score + 0.3 * Vote_Score + 0.2 * Cost_Score + 0.1 * Online_Score) DESC
    ) AS Final_Rank
FROM score_metrics
ORDER BY Performance_Score DESC
LIMIT 5;

/*
🔎 Insight:-
The composite scorecard highlights "Meghana Foods" and "Empire Restaurant" as top-performing partners, 
demonstrating strong multi-dimensional performance across quality, engagement, affordability, and digital readiness.
*/

--Part 2
WITH category_metrics AS (
    SELECT 
        listed_in_type AS Category,
        AVG(rate) AS avg_rating,
        AVG(votes) AS avg_votes,
        AVG(approx_cost_for_two_person) AS avg_cost,
        SUM(CASE WHEN online_order='Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS online_adoption
    FROM zomato
    WHERE rate IS NOT NULL
    GROUP BY listed_in_type
),global_metrics AS (
    SELECT 
        --To Normalize
        MAX(avg_votes) AS max_votes,
        MAX(avg_cost) AS max_cost
    FROM category_metrics
)
SELECT 
    cm.Category,
    ROUND(
        0.4 * (cm.avg_rating / 5.0) +
        0.3 * (cm.avg_votes / gm.max_votes) +
        0.2 * (1 - cm.avg_cost / gm.max_cost) +
        0.1 * cm.online_adoption,
        3
    ) AS Health_Score,
    DENSE_RANK() OVER(
        ORDER BY
        0.4 * (cm.avg_rating / 5.0) +
        0.3 * (cm.avg_votes / gm.max_votes) +
        0.2 * (1 - cm.avg_cost / gm.max_cost) +
        0.1 * cm.online_adoption DESC
    ) AS Final_Rank
FROM category_metrics cm
CROSS JOIN global_metrics gm
ORDER BY Health_Score DESC;

/* 🔎 Insight:-
The “Others” category demonstrates the strongest overall marketplace health, while Dining underperforms due to high saturation, weaker ratings, and limited digital adoption. 
Cafes and Buffet represent stable mid-tier segments with moderate growth potential.
*/

USE zomato_insights_db;
SELECT * FROM zomato;

/*
1. Strategic Focus Areas
* If Zomato could improve only 2 categories next quarter, which should they be and why?
Based On Strategic Pripority:
Priority=(1−Health_Score)*Category_Size
*/
WITH category_metrics AS (
    SELECT 
        listed_in_type AS Category,
        COUNT(*) AS Total_Restaurants,
        AVG(rate) AS avg_rating,
        AVG(votes) AS avg_votes,
        AVG(approx_cost_for_two_person) AS avg_cost,
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS online_adoption
    FROM zomato
    WHERE rate IS NOT NULL
    GROUP BY listed_in_type
),
global_metrics AS (
    SELECT 
        MAX(avg_votes) AS max_votes,
        MAX(avg_cost) AS max_cost
    FROM category_metrics
),
health_scores AS (
    SELECT 
        cm.Category,
        cm.Total_Restaurants,
        ROUND(
            0.4 * (cm.avg_rating / 5.0) +
            0.3 * (cm.avg_votes / gm.max_votes) +
            0.2 * (1 - cm.avg_cost / gm.max_cost) +
            0.1 * cm.online_adoption,
            3
        ) AS Health_Score
    FROM category_metrics cm
    CROSS JOIN global_metrics gm
)
SELECT 
    Category,
    Total_Restaurants,
    Health_Score,
    ROUND((1 - Health_Score) * Total_Restaurants, 2) AS Strategic_Priority_Score
FROM health_scores
ORDER BY Strategic_Priority_Score DESC
LIMIT 2; 
/*
🔎 Insight:-
Dining represents the most critical strategic focus due to its scale and weak marketplace health, 
while Cafes emerge as a secondary improvement opportunity with moderate size and optimization potential.
*/

SELECT * FROM zomato;
