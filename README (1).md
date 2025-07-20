# 💼 SQL Case Study: Global Salary & Employment Analysis

This project presents a comprehensive SQL case study that answers 19 real-world business questions using a `salaries` dataset. These queries are designed around practical scenarios from HR, compensation, business strategy, and database administration domains.

---

## 📊 Dataset Description

The dataset contains global salary records with fields such as:
- `job_title`
- `experience_level`
- `company_location`
- `employment_type`
- `remote_ratio`
- `work_year`
- `salary_in_usd`

---

## ✅ SQL Challenges (19 Realistic Scenarios)

Each question below represents a real-world scenario and is solved using SQL. Some queries use advanced techniques like window functions, CTEs, views, and case-based updates.

1. **Identify countries with remote jobs for managers with salary > $90K**
2. **Top 5 countries with most large companies hiring freshers**
3. **% of employees earning > $100K who work fully remote**
4. **Entry-level jobs with country-wise average salary > global avg**
5. **Top-paying country for each job title**
6. **Countries with consistently increasing avg salary (2022–2024)**
7. **Remote work % by experience level (2021 vs 2024)**
8. **Salary increase % for each title and experience level (2023 vs 2024)**
9. **Role-based access control using SQL Views and GRANT**
10. **Company size distribution in 2021**
11. **Top 3 highest-paid job titles in full-time roles for 2023 in high-sample countries**
12. **Countries where mid-level avg salary > global avg (2023)**
13. **Highest & lowest paying countries for senior-level roles (2023)**
14. **% increase in avg salary per job title (2023–2024)**
15. **Top 3 countries with highest entry-level salary growth (2020–2023)**
16. **Update remote_ratio to 100 for US/AU employees earning > $90K**
17. **Update 2024 salaries based on level-based hike %**
18. **Year with highest avg salary per job title**
19. **Pivot table showing % employment types (FT, PT, CT, FL) for each job role**

---

## 🧠 Concepts Covered

- Aggregate functions
- Window functions (`ROW_NUMBER`, `RANK`)
- CTEs and Subqueries
- Views and Permissions
- `CASE WHEN` logic
- `UPDATE` with conditions
- Role-based access control in SQL
- Pivot-style queries using CASE

---

## 🗃️ Usage

Run this file in MySQL Workbench or any SQL-compatible environment with the `salaries` dataset.

---

## 📁 File Structure

- `case_study_1.sql`: Main SQL file with all 19 business questions and solutions
- `README.md`: Project overview and documentation (you are here)

---

## 📌 Author

Created by Kaushik Parasu as part of a SQL portfolio for data analytics.

---

## 🏁 Goal

Showcase ability to solve real-world business problems using SQL and database design.