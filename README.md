# Zomato Marketplace Insights & Performance Analysis

## 📌 Project Overview

This project presents a comprehensive SQL-driven analysis of the Zomato restaurant marketplace. The objective was to evaluate marketplace composition, digital adoption, pricing strategy, partner risk exposure, and overall ecosystem health.

Using advanced MySQL techniques, I developed a structured performance framework, including a custom Marketplace Health Scorecard to identify high-performing partners and strategic improvement areas.

---

## 🎯 Business Objectives

* Analyze marketplace distribution and category saturation.
* Measure digital feature adoption (Online Ordering & Table Booking).
* Identify value-for-money restaurants (High Rating + Low Cost).
* Detect overpriced risk segments.
* Build a composite health score to rank marketplace categories.
* Recommend strategic focus areas for platform optimization.

---

## 🛠️ Tools & Technologies

* **Database:** MySQL
* **Techniques Used:**

  * Common Table Expressions (CTEs)
  * Window Functions (DENSE_RANK, NTILE)
  * Aggregate & Conditional Logic
  * Correlation Analysis
  * Composite Scoring Model
* **Dataset:** Kaggle Zomato Dataset
* **Visualization:** Tableau (Dashboard Integration)

---

## 📊 Data Schema

The analysis is based on the `zomato` table with the following structure:

* `restaurant_name`
* `online_order` (Yes/No)
* `book_table` (Yes/No)
* `rate` (1–5 scale)
* `votes` (Total reviews)
* `approx_cost_for_two_person`
* `listed_in_type` (Dining, Cafe, Buffet, Others)

---

## 🔎 Key Insights

### 1. Dining Saturation Risk

* Dining represents ~74% of total restaurants.
* Lowest average rating (3.57).
* Lowest online adoption (30%).

**Insight:** High competition with quality dilution. This is the highest-impact improvement segment.

---

### 2. Digital Adoption Gap

* Online Ordering penetration: 39.19%
* Table Booking adoption: 5.41%

**Insight:** Significant opportunity to expand reservation services and digital enablement.

---

### 3. Price vs Experience

* Correlation between price and rating: 0.28 (weak positive)

**Insight:** Premium pricing does not consistently guarantee superior customer experience.

---

### 4. Portfolio Risk Exposure

* 12.16% of restaurants classified as "Overpriced/Risky"
* These partners charge above-average prices but deliver below-average ratings.

**Insight:** Moderate structural risk affecting customer satisfaction.

---

### 5. Marketplace Health Scorecard

A composite scoring model was developed:

Score =
0.4 × Rating +
0.3 × Votes +
0.2 × Cost +
0.1 × Online Availability

This framework evaluates:

* Customer satisfaction
* Engagement strength
* Monetization positioning
* Digital readiness

**Top Performing Restaurants:**

* Meghana Foods
* Empire Restaurant

---

## 📈 Strategic Recommendations

**Priority 1: Dining**

* Improve digital adoption
* Implement quality benchmarking
* Reduce overpriced risk ratio

**Priority 2: Cafes**

* Enhance online ordering penetration
* Leverage engagement potential

---

## 📂 Project Structure

```
├── Data/
│   └── Zomato_data.csv
├── Scripts/
│   └── zomato_analysis.sql
└── README.md
```

---

## 🧠 Skills Demonstrated

* Advanced SQL Query Design
* Performance Segmentation Modeling
* Composite Index Development
* Risk Analysis
* Strategic Prioritization Framework
* Business-Oriented Data Interpretation

---

## 👤 Author

Rahul Choudhary
M.Sc. Mathematics  – IIT Jodhpur
Aspiring Data Analyst

GitHub: https://github.com/irahulbhankhad

---

## 📌 Conclusion

This project demonstrates the ability to translate structured SQL analysis into strategic business insights. The framework developed can support decision-making in marketplace optimization, partner management, and monetization strategy.
