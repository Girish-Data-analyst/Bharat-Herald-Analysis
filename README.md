# Bharat Herald Media Performance Analysis
The analysis focuses on identifying cities that display high digital readiness but relatively low engagement with Bharat Herald’s digital pilot initiatives. Digital readiness was measured using three key indicators: smartphone penetration, internet penetration, and literacy rate. 

---

## 📌 Background Overview  
Bharat Herald, one of India’s largest media publishers, has been experiencing **declining print circulation and ad revenue from 2019 to 2024**. Meanwhile, digital readiness indicators (internet & smartphone penetration, literacy rates) show promise, but pilot platform engagement remains low. This project analyzes **print, ad revenue, and digital adoption data** to help define a **sustainable digital transition strategy**.  

---

## 📊 Data Set Overview  
This project integrates multiple fact and dimension tables:  

- **Fact_Print_Sale** → Captures monthly print performance of Bharat Herald across cities. Tracks how many copies were printed, sold, and finally circulated—essential for evaluating print demand and operational efficiency.  
- **Fact_Ad_Revenue** → Tracks quarterly ad revenues by city and category. Useful for analyzing ad market trends, city-level engagement by advertisers, and category-level ad investments over time.
 - **Fact_City_Readiness** → Provides dynamic, time-based readiness scores for each city using three factors—literacy rate, smartphone penetration, and internet penetration. Important for modeling digital adoption potential across regions.
- **Fact_Digital_Pilot** → Details Bharat Herald’s short-lived digital pilot during 2021. Helps evaluate the feasibility, cost, and impact of digital transformation efforts.
- **Dim_city** → Lookup table for all cities in Bharat Herald’s operational scope. Used to link other fact tables, classify cities by tier, and perform location-based segmentation.
- **Dim_ad_Category** → Normalizes inconsistent ad category entries from fact_ad_revenue. Also maps categories to sector groups and brand examples to enrich ad analysis.

---

## 📈 Execution Summary  
- Designed **SQL queries** to solve **10+ business requests**  
- Conducted **trend analysis, efficiency checks, category performance evaluation, and readiness vs. engagement comparisons**  
- Delivered insights for **strategic decision-making in digital transformation**  

---

## 🔍 Insights Summary  
- 📉 Print circulation **declined steadily YoY** (2019–2024)  
- 💰 Ad revenue is concentrated in **a few resilient categories**, others show sharp declines  
- 🌐 Cities with **high digital readiness often underperform in pilot engagement**  
- ⚠️ Some cities face **consistent multi-year declines** in both circulation and ad revenue  
- 📊 Print efficiency gaps exist, showing operational improvement opportunities  

---

## 📝 Business Requests Solved  
✔️ **Sharpest Declines** → Top 3 months with largest MoM drop in circulation  
✔️ **Ad Revenue Analysis** → Categories contributing >50% yearly revenue  
✔️ **Print Efficiency** → Ranked cities by net circulation / copies printed  
✔️ **Digital Readiness Outlier** → High readiness but bottom 3 engagement cities  
✔️ **Consistent Decline** → Cities with 2019–2024 circulation & revenue drops  
✔️ **Revenue per Copy** → Cities with highest ad revenue per circulated copy  
✔️ **Print vs. Digital Balance** → Strategic recommendations for transition  

---

## 💡 Recommendations  
- **Phase 1 Digital Rollout** → Target high-readiness, low-engagement cities  
- **Advertiser Confidence** → Highlight high-performing categories & cities  
- **Content Delivery** → Improve WhatsApp bulletins, mobile-first e-papers  
- **Monetization Models** → Subscription bundles, loyalty programs, pay-per-article  
- **Regional Trust** → Leverage local influencers/journalists for credibility  

---

## 🛠 Tools Used  
- **SQL (MySQL/PostgreSQL)** → Data querying & business request solving  
- **GitHub** → Project hosting & portfolio presentation  

---

## 👨‍💻 Author  
**Girish K S**  
📧 Email: [girishhemanth823@gmail.com]  
🔗 GitHub: [https://github.com/Girish-Data-analyst]  

