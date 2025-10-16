# 🛒 Target E-Commerce SQL Analytics Project

### 📊 End-to-End Data Analysis using SQL Views, CTEs & Window Functions  
**Author:** Kaushik Parasu  
**Tech Stack:** MySQL 8.0, CTEs, Views, Joins, Window Functions  

---

## 🎯 Project Objective

To analyze Target’s e-commerce performance across **customers, products, regions, and delivery efficiency** using advanced SQL techniques.  
The goal is to build a reusable SQL data model (via views) and extract key business insights that help leadership understand:
- Growth trends over time  
- Customer retention & churn  
- Product category performance  
- Regional delivery efficiency  

---

## 🧩 Datasets Used

| File | Description |
|------|--------------|
| `orders.csv` | Order-level data including timestamps & status |
| `order_items.csv` | Item-level data including price & seller |
| `products.csv` | Product catalog with category information |
| `payments.csv` | Transaction details (payment type & value) |
| `customers.csv` | Customer demographics (city/state) |
| `sellers.csv` | Seller-level identifiers |

---

## 🏗️ Data Model (Analytical Views)

A modular set of **SQL Views** was created to organize the pipeline:

| View | Description |
|------|--------------|
| **`v_order_payments`** | Aggregates payment values per order |
| **`v_customer_orders`** | Links customer details to orders |
| **`v_city_revenue`** | Calculates total revenue & contribution by city |
| **`v_customer_frequency`** | Counts total orders per customer |
| **`v_qoq_growth`** | Computes quarter-over-quarter order & revenue growth |
| **`v_customer_churn`** | Identifies customers who didn’t reorder in the next quarter |
| **`customer_order_dates_city`** | Combines delivery timestamps with region info |
| **`v_average_delivery_times`** | Measures delivery efficiency across regions |
| *(CTE)* **`prod_cate_price`** | Calculates Average Order Value (AOV) per category |

---

## 📈 Business Questions Solved (15 KPIs)

| # | Question | Theme |
|---|-----------|--------|
| 1 | How have total orders & revenue grown quarter-over-quarter? | Growth |
| 2 | Which city/state contributed the most to revenue? | Regional Revenue |
| 3 | Who are the top 10 customers by lifetime spending? | Customer Value |
| 4 | How many unique customers are repeat vs one-time buyers? | Retention |
| 5 | What’s the average time gap between consecutive orders? | Engagement |
| 6 | Which customer segments (city/state) show highest order frequency? | Segmentation |
| 7 | What’s the churn rate % per quarter? | Retention / Churn |
| 8 | Which categories have the widest customer reach? | Product Reach |
| 9 | Which categories are growing fastest QoQ? | Product Growth |
| 10 | What is the Average Order Value (AOV) per category? | Profitability |
| 11 | How stable is AOV over time? | Pricing Behavior |
| 12 | During what time of day do customers place orders? | Customer Behavior |
| 13 | How does delivery time vary by region? | Logistics |
| 14 | How does delivery time vary by seller? | Logistics |
| 15 | Total orders & revenue per quarter/year | Financial Trend |

---

## ⚙️ SQL Concepts Demonstrated

- **Joins:** INNER JOIN, LEFT JOIN across 5+ tables  
- **Window Functions:** `LAG()`, `AVG() OVER()`, `COUNT() OVER()`  
- **Aggregations:** `SUM()`, `ROUND()`, `DATEDIFF()`  
- **CTEs & Views:** Modular query design for reusability  
- **Conditional Logic:** `CASE WHEN`, `HAVING` filters  
- **Performance Filters:** Excluded canceled / unavailable orders  
- **Business-Driven Filters:** Included only meaningful data points (> 50 orders per city)

---

## 🧠 Key Insights

1. **Quarter-over-Quarter Growth:** Orders grew steadily year-over-year with consistent revenue expansion.  
2. **Top Revenue Cities:** São Paulo and Rio de Janeiro contribute > 20% of total revenue.  
3. **Customer Retention:** ~95% of customers are one-time buyers → acquisition heavy model.  
4. **Average Order Value (AOV):** Pc's has the highest AOV (~₹1,200), House-Comfort lowest (~₹31).  
5. **Churn Rate:** Around 95-98% customers fail to reorder in the next quarter.  
6. **Delivery Insights:**  
   - Nationwide average delivery time ≈ 12 days  
   - Northern regions (AM, RR) take 4–5 days longer than average  
   - Southern regions (SP, PR) deliver 2 days faster on average  

---

## 🧰 Tools & Skills Used

| Category | Details |
|-----------|----------|
| **Database** | MySQL 8.0 |
| **Language** | SQL (CTEs, Views, Window Functions) |
| **Techniques** | Data Modeling, KPI Analysis, Performance Optimization |
| **Visualization (optional)** | Power BI / Excel Pivot Charts for city & quarter trends |


---

## 🏁 Project Outcome

- Built **9 modular SQL views** creating a scalable analytical layer  
- Answered **15 key business questions** covering sales, retention, and logistics  
- Delivered **actionable insights** on customer behavior and regional performance  
- Demonstrated end-to-end analytical workflow purely in SQL  

---

## 🧩 Future Enhancements

- Integrate with **Power BI** for interactive dashboards  
- Add stored procedures for **automated KPI refresh**  
- Include delay vs estimated delivery metrics  
- Extend analysis to **seller-wise performance monitoring**

---

## 🏷️ Tags

`#SQL`  `#DataAnalytics`  `#BusinessIntelligence`  `#EcommerceAnalytics`  `#CTE`  `#WindowFunctions`  `#Views`  `#KaushikParasu`


