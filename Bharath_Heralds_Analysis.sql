-- > CREATING A DATABASE FOR THE PROJECT
CREATE DATABASE Practiceproject3;


-- > CREATING TABLES FOR THE PROJECT
CREATE TABLE Fact_Ad_Rev(Edition_ID VARCHAR(10),
	ad_category	VARCHAR(10),
    quarter	VARCHAR(10),
    ad_revenue FLOAT
    );
 
CREATE TABLE Dim_City(City_ID VARCHAR(10) PRIMARY KEY,
	city VARCHAR(10),
    tier VARCHAR(10),
    State VARCHAR(30)
    );
INSERT INTO Dim_City (city_id, city, tier, State)
VALUES
("C001", "Lucknow", "Tier 2", "Uttar Pradesh"),
("C002", "Delhi", "Tier 1", "Delhi"),
("C003", "Bhopal", "Tier 2", "Madhya Pradesh"),
("C004", "Patna", "Tier 2", "Bihar"),
("C005", "Jaipur", "Tier 2", "Rajasthan"),
("C006", "Mumbai", "Tier 1", "Maharashtra"),
("C007", "Ranchi", "Tier 3", "Jharkhand"),
("C008", "Kanpur", "Tier 2", "Uttar Pradesh"),
("C009", "Ahmedabad", "Tier 1", "Gujarat"),
("C010", "Varanasi", "Tier 2", "Uttar Pradesh");

CREATE TABLE Dim_Ad_Category(ad_category_id	VARCHAR(10) PRIMARY KEY,
standard_ad_category	VARCHAR(15),
category_group	VARCHAR(20),
example_brands VARCHAR(25)
);
INSERT INTO Dim_Ad_Category (ad_category_id, standard_ad_category, category_group, example_brands)
VALUES
("A001", "Government", "Public Sector", "LIC, SBI"),
("A002", "FMCG", "Commercial Brands", "HUL, Britannia"),
("A003", "Real Estate", "Private Sector", "DLF, Lodha"),
("A004", "Automobile", "Commercial Brands", "Tata Motors, Maruti");

CREATE TABLE Fact_City_Readiness(Si_No INT PRIMARY KEY,
City_ID	VARCHAR(10),
quarter	VARCHAR(10),
literacy_rate FLOAT,
smartphone_penetration FLOAT,	
internet_penetration FLOAT,
 FOREIGN KEY (City_ID) REFERENCES Dim_City(City_ID)
);

CREATE TABLE Fact_Digital_Pilot(Si_No INT,
             platform VARCHAR(50),
			 launch_month DATE,
             ad_category_id	VARCHAR(10),
             Development_cost INT,
             marketing_cost INT,
             users_reached	INT,
             downloads INT,
             avg_bounce_rate FLOAT,
             feedback VARCHAR(100),
             City_ID VARCHAR(10),
             FOREIGN KEY (City_ID) REFERENCES Dim_City(City_ID),
             FOREIGN KEY (ad_category_id) REFERENCES Dim_Ad_Category(ad_category_id)
             );
 
CREATE TABLE Fact_Print_Sale(Si_No INT PRIMARY KEY,
             Edition_ID  VARCHAR(10) ,
             City_ID	VARCHAR(10) ,
             Language	VARCHAR(10) ,
             State	VARCHAR(20) ,
             Copies_Sold	INT,
			 Copies_Returned	INT,
			 Net_Circulation	INT,
             Month DATE,
			 FOREIGN KEY (City_ID) REFERENCES Dim_City(City_ID)
);


-- > SOLVING THE BUSINESS REQUESTS 


-- > Business Request – 1: Monthly Circulation Drop Check 
-- > Generate a report showing the top 3 months (2019–2024) where any city recorded the sharpest month-over-month decline in net_circulation. 

WITH MonthlyChange AS (
    SELECT
        City_ID,
        Month,
        Net_Circulation,
        LAG(Net_Circulation) OVER (PARTITION BY City_ID ORDER BY Month) AS Prev_Month_Circulation
    FROM fact_print_sale
    WHERE YEAR(Month) BETWEEN 2019 AND 2024
)
SELECT
    City_ID,
    Month,
    (Prev_Month_Circulation - Net_Circulation) AS Decline
FROM MonthlyChange
WHERE Prev_Month_Circulation IS NOT NULL
ORDER BY Decline ASC
LIMIT 3;

-- > Business Request – 2: Yearly Revenue Concentration by Category 
-- > Identify ad categories that contributed > 50% of total yearly ad revenue. 

WITH ParsedData AS (
    SELECT
        ad_category,
        CASE
            WHEN quarter LIKE '____-Q%' THEN LEFT(quarter,4)       
            WHEN quarter LIKE 'Q%-____' THEN RIGHT(quarter,4)      
            WHEN LENGTH(quarter) = 4 THEN quarter                  
            ELSE NULL
        END AS Year,
        ad_revenue
    FROM Fact_Ad_Rev
),
YearlyRevenue AS (
    SELECT
        Year,
        ad_category,
        SUM(ad_revenue) AS Category_Revenue
    FROM ParsedData
    GROUP BY Year, ad_category
),
TotalRevenue AS (
    SELECT
        Year,
        SUM(Category_Revenue) AS Total_Revenue
    FROM YearlyRevenue
    GROUP BY Year
)
SELECT
    Y.Year,
    Y.ad_category,
    Y.Category_Revenue,
    T.Total_Revenue,
    ROUND((Y.Category_Revenue / T.Total_Revenue) * 100, 2) AS Contribution_Percent
FROM YearlyRevenue Y
JOIN TotalRevenue T
  ON Y.Year = T.Year
WHERE (Y.Category_Revenue / T.Total_Revenue) > 0.3
ORDER BY Y.Year, Contribution_Percent DESC;

-- > Business Request – 3: 2024 Print Efficiency Leaderboard 
-- > For 2024, rank cities by print efficiency (efficiency = net_circulation / copies_printed). Return top 5. 

WITH EfficiencyCalc AS (
    SELECT 
        f.City_ID,
        d.city AS city_name,
        SUM(f.Copies_Sold + f.Copies_Returned) AS copies_printed_2024,
        SUM(f.Net_Circulation) AS net_circulation_2024,
        ROUND(SUM(f.Net_Circulation)  / SUM(f.Copies_Sold + f.Copies_Returned), 2)* 100 AS efficiency_ratio
    FROM Fact_Print_Sale f
    JOIN Dim_City d ON f.City_ID = d.City_ID
    WHERE YEAR(f.Month) = 2024
    GROUP BY f.City_ID, d.city
)
SELECT 
    City_ID,
    city_name,
    copies_printed_2024,
    net_circulation_2024,
    efficiency_ratio,
    RANK() OVER (ORDER BY efficiency_ratio DESC) AS efficiency_rank_2024
FROM EfficiencyCalc
ORDER BY efficiency_rank_2024
LIMIT 5;

-- > Business Request – 4 : Internet Readiness Growth (2021) 
-- > For each city, compute the change in internet penetration from Q1-2021 to Q4-2021 and identify the city with the highest improvement.

 WITH InternetRates AS (
    SELECT 
        f.City_ID,
        d.city AS city_name,
        ROUND(MAX(CASE WHEN f.quarter = '2021-Q1' THEN f.internet_penetration END),2) AS internet_rate_q1_2021,
        ROUND(MAX(CASE WHEN f.quarter = '2021-Q4' THEN f.internet_penetration END),2) AS internet_rate_q4_2021
    FROM Fact_City_Readiness f
    JOIN Dim_City d ON f.City_ID = d.City_ID
    WHERE f.quarter IN ('2021-Q1', '2021-Q4')
    GROUP BY f.City_ID, d.city
)
SELECT 
    city_name,
    internet_rate_q1_2021,
    internet_rate_q4_2021,
    (internet_rate_q4_2021 - internet_rate_q1_2021) AS delta_internet_rate
FROM InternetRates
ORDER BY delta_internet_rate DESC
LIMIT 1;


-- > Business Request – 5: Consistent Multi-Year Decline (2019→2024) 
-- > Find cities where both net_circulation and ad_revenue decreased every year from 2019 through 2024 (strictly decreasing sequences). 

WITH YearlyAgg AS (
    SELECT 
        d.city AS city_name,
        YEAR(p.Month) AS year,
        SUM(p.Net_Circulation) AS yearly_net_circulation,
        SUM(a.ad_revenue) AS yearly_ad_revenue
    FROM Fact_Print_Sale p
    JOIN Dim_City d ON p.City_ID = d.City_ID
    JOIN Fact_Ad_Rev a ON p.Edition_ID = a.Edition_ID
    WHERE YEAR(p.Month) BETWEEN 2019 AND 2024
    GROUP BY d.city, YEAR(p.Month)
),

DeclineCheck AS (
    SELECT 
        city_name,
        MIN(yearly_net_circulation) < MAX(yearly_net_circulation) AS not_declining_print,
        MIN(yearly_ad_revenue) < MAX(yearly_ad_revenue) AS not_declining_ad
    FROM YearlyAgg
    GROUP BY city_name
)

SELECT 
    y.city_name,
    y.year,
    y.yearly_net_circulation,
    y.yearly_ad_revenue,
    CASE WHEN d.not_declining_print = 0 THEN 'Yes' ELSE 'No' END AS is_declining_print,
    CASE WHEN d.not_declining_ad = 0 THEN 'Yes' ELSE 'No' END AS is_declining_ad_revenue,
    CASE WHEN d.not_declining_print = 0 AND d.not_declining_ad = 0 THEN 'Yes' ELSE 'No' END AS is_declining_both
FROM YearlyAgg y
JOIN DeclineCheck d ON y.city_name = d.city_name
ORDER BY y.city_name, y.year;



-- > Business Request – 6 : 2021 Readiness vs Pilot Engagement Outlier 
-- > In 2021, identify the city with the highest digital readiness score but among the bottom 3 in digital pilot engagement. 
 
 WITH Readiness2021 AS (
    SELECT 
        d.city AS city_name,
        ROUND(AVG((c.smartphone_penetration + c.internet_penetration + c.literacy_rate) / 3),2) AS readiness_score_2021
    FROM Fact_City_Readiness c
    JOIN Dim_City d ON c.City_ID = d.City_ID
    WHERE c.quarter LIKE '2021%'
    GROUP BY d.city
),

Engagement2021 AS (
    SELECT 
        d.city AS city_name,
        ROUND(AVG(dp.downloads),2) AS engagement_metric_2021
        -- you can swap downloads with engagement_rate, active_users, sessions etc. if available
    FROM Fact_Digital_Pilot dp
    JOIN Dim_City d ON dp.City_ID = d.City_ID
    WHERE YEAR(dp.launch_month) = 2021
    GROUP BY d.city
),

Combined AS (
    SELECT 
        r.city_name,
        r.readiness_score_2021,
        e.engagement_metric_2021,
        RANK() OVER (ORDER BY r.readiness_score_2021 DESC) AS readiness_rank_desc,
        RANK() OVER (ORDER BY e.engagement_metric_2021 ASC) AS engagement_rank_asc
    FROM Readiness2021 r
    JOIN Engagement2021 e ON r.city_name = e.city_name
)

SELECT 
    city_name,
    readiness_score_2021,
    engagement_metric_2021,
    readiness_rank_desc,
    engagement_rank_asc,
    CASE 
        WHEN readiness_rank_desc = 1 AND engagement_rank_asc <= 3 THEN 'Yes'
        ELSE 'No'
    END AS is_outlier
FROM Combined
ORDER BY readiness_rank_desc, engagement_rank_asc;

-- > PRIMARY ANALYSIS

-- > 1) What is the trend in copies printed, copies sold, and net circulation across all cities from 2019 to 2024? How has this changed year-over-year?
SELECT 
    YEAR(ps.Month) AS year,
    SUM(ps.Copies_Sold + ps.Copies_Returned) AS total_copies_printed,
    SUM(ps.Copies_Sold) AS total_copies_sold,
    SUM(ps.Net_Circulation) AS total_net_circulation,
    LAG(SUM(ps.Copies_Sold + ps.Copies_Returned)) OVER (ORDER BY YEAR(ps.Month)) AS prev_copies_printed,
    ROUND(
        (SUM(ps.Copies_Sold + ps.Copies_Returned) - LAG(SUM(ps.Copies_Sold + ps.Copies_Returned)) 
         OVER (ORDER BY YEAR(ps.Month))) * 100.0 / 
        NULLIF(LAG(SUM(ps.Copies_Sold + ps.Copies_Returned)) OVER (ORDER BY YEAR(ps.Month)), 0), 2
    ) AS yoy_change_copies_printed,

    LAG(SUM(ps.Copies_Sold)) OVER (ORDER BY YEAR(ps.Month)) AS prev_copies_sold,
    ROUND(
        (SUM(ps.Copies_Sold) - LAG(SUM(ps.Copies_Sold)) OVER (ORDER BY YEAR(ps.Month))) * 100.0 / 
        NULLIF(LAG(SUM(ps.Copies_Sold)) OVER (ORDER BY YEAR(ps.Month)), 0), 2
    ) AS yoy_change_copies_sold,

    LAG(SUM(ps.Net_Circulation)) OVER (ORDER BY YEAR(ps.Month)) AS prev_net_circulation,
    ROUND(
        (SUM(ps.Net_Circulation) - LAG(SUM(ps.Net_Circulation)) OVER (ORDER BY YEAR(ps.Month))) * 100.0 / 
        NULLIF(LAG(SUM(ps.Net_Circulation)) OVER (ORDER BY YEAR(ps.Month)), 0), 2
    ) AS yoy_change_net_circulation
FROM Fact_Print_Sale ps
WHERE YEAR(ps.Month) BETWEEN 2019 AND 2024
GROUP BY YEAR(ps.Month)
ORDER BY year;


 -- > 2) Which cities contributed the highest to net circulation and copies sold in 2024? Are these cities still profitable to operate in? 
SELECT 
    c.City AS city_name,
    SUM(ps.Copies_Sold) AS total_copies_sold_2024,
    SUM(ps.Net_Circulation) AS total_net_circulation_2024,
    ROUND(
        SUM(ps.Net_Circulation) * 100.0 / 
        NULLIF(SUM(ps.Copies_Sold + ps.Copies_Returned), 0), 2
    ) AS circulation_efficiency_pct,
    CASE 
        WHEN SUM(ps.Net_Circulation) * 1.0 / NULLIF(SUM(ps.Copies_Sold + ps.Copies_Returned),0) >= 0.7 
        THEN 'Yes'
        ELSE 'No'
    END AS is_profitable_city
FROM Fact_Print_Sale ps
JOIN Dim_City c ON ps.City_ID = c.City_ID
WHERE YEAR(ps.Month) = 2024
GROUP BY c.City
ORDER BY total_net_circulation_2024 DESC
LIMIT 5;

-- > 3) Which cities have the largest gap between copies printed and net circulation, and how has that gap changed over time? 
SELECT 
    c.City AS city_name,
    YEAR(ps.Month) AS year,
    SUM(ps.Copies_Sold + ps.Copies_Returned) AS total_copies_printed,
    SUM(ps.Net_Circulation) AS total_net_circulation,
    (SUM(ps.Copies_Sold + ps.Copies_Returned) - SUM(ps.Net_Circulation)) AS circulation_gap,
    ROUND(
        (SUM(ps.Copies_Sold + ps.Copies_Returned) - SUM(ps.Net_Circulation)) * 100.0 / 
        NULLIF(SUM(ps.Copies_Sold + ps.Copies_Returned), 0), 2
    ) AS gap_pct
FROM Fact_Print_Sale ps
JOIN Dim_City c ON ps.City_ID = c.City_ID
GROUP BY c.City, YEAR(ps.Month)
ORDER BY circulation_gap DESC;

-- > 4) How has ad revenue evolved across different ad categories between 2019 and 2024? Which categories have remained strong, and which have declined?
 
 SELECT 
    dac.standard_ad_category AS ad_category,
    CAST(LEFT(far.quarter, 4) AS UNSIGNED) AS year,
    SUM(far.ad_revenue) AS total_ad_revenue
FROM Fact_Ad_Rev far
JOIN Dim_Ad_Category dac 
      ON far.ad_category = dac.ad_category_id
GROUP BY dac.standard_ad_category, CAST(LEFT(far.quarter, 4) AS UNSIGNED)
ORDER BY ad_category, year;

-- > 5) Which cities generated the most ad revenue, and how does that correlate with their print circulation?
SELECT 
    dc.city AS city_name,
    SUM(far.ad_revenue) AS total_ad_revenue,
    SUM(fps.net_circulation) AS total_net_circulation
FROM Fact_Ad_Rev far
JOIN Fact_Print_Sale fps 
    ON far.Edition_ID = fps.Edition_ID
JOIN Dim_City dc 
    ON fps.City_ID = dc.City_ID
GROUP BY dc.city
ORDER BY total_ad_revenue DESC;

-- > 6) Which cities show high digital readiness (based on smartphone, internet, and literacy rates) but had low digital pilot engagement?
WITH readiness AS (
    SELECT 
        dc.city AS city_name,
        AVG(fcr.smartphone_penetration + fcr.internet_penetration + fcr.literacy_rate)/3 AS readiness_score
    FROM Fact_City_Readiness fcr
    JOIN Dim_City dc ON fcr.City_ID = dc.City_ID
    WHERE fcr.quarter LIKE '2021%'   -- filter for 2021
    GROUP BY dc.city
),
engagement AS (
    SELECT 
        dc.city AS city_name,
        AVG(fdp.downloads) AS avg_engagement
    FROM Fact_Digital_Pilot fdp
    JOIN Dim_City dc ON fdp.City_ID = dc.City_ID
    WHERE fdp.launch_month LIKE '2021%'   -- filter for 2021
    GROUP BY dc.city
)
SELECT 
    r.city_name,
    r.readiness_score,
    e.avg_engagement,
    RANK() OVER (ORDER BY r.readiness_score DESC) AS readiness_rank,
    RANK() OVER (ORDER BY e.avg_engagement ASC) AS engagement_rank,
    CASE 
        WHEN RANK() OVER (ORDER BY r.readiness_score DESC) <= 5
             AND RANK() OVER (ORDER BY e.avg_engagement ASC) <= 5
        THEN 'Yes'
        ELSE 'No'
    END AS high_ready_low_engagement
FROM readiness r
JOIN engagement e ON r.city_name = e.city_name
ORDER BY r.readiness_score DESC;

-- > 7) Which cities had the highest ad revenue per net circulated copy? Is this ratio improving or worsening over time?
WITH yearly_data AS (
    SELECT 
        dc.city AS city_name,
        YEAR(fps.Month) AS year,
        SUM(far.ad_revenue) AS total_ad_revenue,
        SUM(fps.Net_Circulation) AS total_net_circulation,
        SUM(far.ad_revenue) / NULLIF(SUM(fps.Net_Circulation),0) AS revenue_per_copy
    FROM Fact_Print_Sale fps
    JOIN Dim_City dc ON fps.City_ID = dc.City_ID
    JOIN Fact_Ad_Rev far ON fps.Edition_ID = far.Edition_ID
    GROUP BY dc.city, YEAR(fps.Month)
)
SELECT 
    city_name,
    year,
    total_ad_revenue,
    total_net_circulation,
    revenue_per_copy,
    LAG(revenue_per_copy) OVER (PARTITION BY city_name ORDER BY year) AS prev_revenue_per_copy,
    CASE 
        WHEN LAG(revenue_per_copy) OVER (PARTITION BY city_name ORDER BY year) IS NULL 
            THEN 'No prior data'
        WHEN revenue_per_copy > LAG(revenue_per_copy) OVER (PARTITION BY city_name ORDER BY year) 
            THEN 'Improving'
        WHEN revenue_per_copy < LAG(revenue_per_copy) OVER (PARTITION BY city_name ORDER BY year) 
            THEN 'Worsening'
        ELSE 'Stable'
    END AS trend_status
FROM yearly_data
ORDER BY city_name, year;

-- > 8) Based on digital readiness, pilot engagement, and print decline, which 3 cities should be  prioritized for Phase 1 of the digital relaunch?
WITH readiness AS (
    SELECT 
        dc.city AS city_name,
        AVG(fcr.literacy_rate + fcr.smartphone_penetration + fcr.internet_penetration)/3 AS readiness_score_2021
    FROM Fact_City_Readiness fcr
    JOIN Dim_City dc ON fcr.City_ID = dc.City_ID
    WHERE fcr.quarter LIKE '2021%'
    GROUP BY dc.city
),
engagement AS (
    SELECT 
        dc.city AS city_name,
        SUM(fdp.downloads) AS engagement_metric_2021
    FROM Fact_Digital_Pilot fdp
    JOIN Dim_City dc ON fdp.City_ID = dc.City_ID
    WHERE fdp.launch_month BETWEEN '2021-01-01' AND '2021-12-31'
    GROUP BY dc.city
),
print_decline AS (
    SELECT 
        dc.city AS city_name,
        SUM(CASE WHEN YEAR(fps.Month)=2019 THEN fps.Net_Circulation END) AS circulation_2019,
        SUM(CASE WHEN YEAR(fps.Month)=2024 THEN fps.Net_Circulation END) AS circulation_2024,
        ( (SUM(CASE WHEN YEAR(fps.Month)=2019 THEN fps.Net_Circulation END) - 
            SUM(CASE WHEN YEAR(fps.Month)=2024 THEN fps.Net_Circulation END)) * 1.0 /
            NULLIF(SUM(CASE WHEN YEAR(fps.Month)=2019 THEN fps.Net_Circulation END),0)
        ) * 100 AS decline_pct
    FROM Fact_Print_Sale fps
    JOIN Dim_City dc ON fps.City_ID = dc.City_ID
    GROUP BY dc.city
)
SELECT 
    r.city_name,
    r.readiness_score_2021,
    e.engagement_metric_2021,
    p.decline_pct,
    (r.readiness_score_2021*0.4 + 
     e.engagement_metric_2021*0.3 + 
     p.decline_pct*0.3) AS priority_score
FROM readiness r
JOIN engagement e ON r.city_name = e.city_name
JOIN print_decline p ON r.city_name = p.city_name
ORDER BY priority_score DESC
LIMIT 3;

