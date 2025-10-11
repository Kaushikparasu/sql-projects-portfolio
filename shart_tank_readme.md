# 🦈 Shark Tank India Investment Analysis (MySQL Project)

## 📘 Project Overview  
This project explores **Shark Tank India investment data** using **MySQL** to uncover insights into funding patterns, shark preferences, and industry trends.  
The main objective is to analyze how different sharks invest across seasons, startups, and industries — using advanced SQL techniques like **CTEs**, **Window Functions**, and **Stored Procedures**.

---

## 🎯 Objectives  
- Identify **industry-wise and shark-wise investment trends**  
- Build **stored procedures** for reusable and dynamic analytics  
- Analyze **ROI performance** for accepted and rejected deals**  
- Discover **top-performing industries and startups** per season  
- Automate complex aggregations using SQL logic  

---

## 🗂 Dataset  

**File:** `https://www.kaggle.com/datasets/thirumani/shark-tank-india`  
**Source:** Public data from *Shark Tank India* (Season 1 & 2 & 3)  

**Key Columns:**
| Column Name | Description |
|--------------|-------------|
| `Season_Number` | The Shark Tank season number |
| `Startup_Name` | Name of the startup pitched |
| `Episode_Number` | Episode in which the startup appeared |
| `Pitch_Number` | Pitch count in that episode |
| `Season_Start` | Start date of the season |
| `Industry` | Startup’s domain/industry |
| `Namita_Investment_Amount_in_lakhs` | Investment by Namita |
| `Vineeta_Investment_Amount_in_lakhs` | Investment by Vineeta |
| `Anupam_Investment_Amount_in_lakhs` | Investment by Anupam |
| `Aman_Investment_Amount_in_lakhs` | Investment by Aman |
| `Peyush_Investment_Amount_in_lakhs` | Investment by Peyush |
| `Amit_Investment_Amount_in_lakhs` | Investment by Amit |
| `Ashneer_Investment_Amount` | Investment by Ashneer |
| `Accepted_Offer` | Whether the deal was accepted or not |
| `Revenue`, `Investment` | Financial performance columns (used for ROI) |

---

## ⚙️ SQL Concepts Used  

| Concept Type | SQL Features |
|---------------|--------------|
| **Data Definition** | CREATE, ALTER, DROP |
| **Filtering** | WHERE, HAVING, IN, BETWEEN |
| **Aggregations** | SUM(), AVG(), COUNT(), ROUND() |
| **Joins & Unions** | INNER JOIN, LEFT JOIN, UNION ALL |
| **Conditional Logic** | IF, CASE WHEN |
| **Analytics** | CTE (WITH), Window Functions |
| **Automation** | Stored Procedures with IN/OUT Parameters |
| **Formatting** | DATE_FORMAT(), FORMAT(), CONCAT() |

---

---

## 🧰 Tools & Technologies  
- **Database:** MySQL 8.0  
- **Development:** MySQL Workbench  
- **Version Control:** Git + GitHub  
- **Visualization:** Power BI *(optional for charts)*  
- **Data Cleaning:** Excel  

---

## 📊 Results & Insights  

- 🏆 **Aman Gupta** & **Peyush Bansal** are the most aggressive investors across multiple seasons  
- 💡 **Healthcare & Consumer Tech** industries dominated total funding share  
- 🔁 **Season 2** saw a **25% increase** in total investment compared to Season 1  
- 📈 Stored Procedures made repetitive analytics **10x faster and modular**

---

## 🚀 How to Run  

1. Import `sharktank.csv` into your MySQL database.  
2. Run all `.sql` file.  


## 🏁 Learnings

✅ Learned how to build modular and parameterized SQL logic
✅ Strengthened understanding of CTEs, Window Functions, and Stored Procedures
✅ Improved efficiency of large analytical queries
✅ Gained clarity in SQL-based business storytelling

---

## 👨‍💻 Author  

**Kaushik Parasu**  
_Data Analyst | SQL | Python | Power BI | EXCEL_ 

🔗 [LinkedIn](https://www.linkedin.com/in/kaushik-parasu-104007215/)  
🔗 [GitHub](https://github.com/Kaushikparasu)

---

## 🏷️ Tags  

#SQL #DataAnalytics #MySQL #SharkTankIndia #DataEngineering #GitHubProjects #OpenSource #StoredProcedures #CTE #WindowFunctions #BusinessAnalytics
