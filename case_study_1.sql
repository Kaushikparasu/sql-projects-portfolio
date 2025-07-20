create database projects_case_study; 
use projects_case_study;

select * from salaries;
select distinct experience_level from salaries;


-- 1
-- You're a Compensation analyst employed by a multinational corporation. 
-- Your Assignment is to Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD
select distinct company_location from salaries
where job_title like '%manager%' and remote_ratio = 100 and salary_in_usd > 90000; 


-- 2
-- AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. 
-- you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.
select company_location,count(*) as c
from salaries
where company_size = 'L' and experience_level = 'EN'
group by company_location
order by c desc
limit 5;


-- 3
-- Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
-- Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
select (count(remote_ratio)/(select count(*)
			from salaries
			where salary_in_usd > 100000))*100 as remote_percentage
from salaries
where remote_ratio = 100 and salary_in_usd > 100000;

-- another approach
set @deno = (select count(*) from salaries where salary_in_usd > 100000);
set @nume = (select count(*) from salaries where salary_in_usd > 100000 and remote_ratio = 100);
set @perc = ((select @nume)/(select @deno))*100;
select round(@perc,2);


-- 4
-- Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the 
-- Locations where entry-level average salaries exceed the average salary for that job title IN market for entry level.
with t1 as 
(select distinct job_title,company_location,
avg(salary_in_usd) over(partition by job_title ,company_location) as avg_country
from salaries
where experience_level = 'EN'),

t2 as
(select distinct job_title,
avg(salary_in_usd) over(partition by job_title) as avg_total
from salaries
where experience_level = 'EN')

select job_title,company_location from(
select t1.job_title,company_location,avg_country,avg_total
from t1
join t2
on t1.job_title = t2.job_title) as t
where avg_country>avg_total;


-- 5
-- You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
-- Your job is to Find out for each job title which. Country pays the maximum average salary. This helps you to place your candidates IN those countries

select job_title,company_location,avg_salary from (
select *,
row_number() over(partition by job_title order by avg_salary desc) as r
from(
select job_title,company_location,
avg(salary_in_usd) over(partition by job_title,company_location) as avg_salary
from salaries) as t1) as t2
where r = 1;


-- 6 
-- AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations. 
-- Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years 
-- (Countries WHERE data is available for 3 years Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.

with selection as (
select company_location,work_year from (
select company_location, work_year,
count(work_year) over(partition by company_location) c
from salaries
where work_year in (2024,2023,2022)
group by company_location,work_year) as t
where c = 3),

final_data as (
select s2.company_location,s2.work_year,salary_in_usd from salaries s1
join selection s2
on s1.company_location=s2.company_location and s1.work_year = s2.work_year)

select * from(
select company_location,
avg(case when work_year = 2022 then salary_in_usd end) as avg_2022,
avg(case when work_year = 2023 then salary_in_usd end) as avg_2023,
avg(case when work_year = 2024 then salary_in_usd end) as avg_2024
from final_data
group by company_location) as t
where avg_2023> avg_2022 and avg_2024>avg_2023;


-- 7
--  Picture yourself AS a workforce strategist employed by a global HR tech startup. 
-- Your Mission is to Determine the percentage of fully remote work for each experience level IN 2021 and compare it WITH the corresponding figures for 2024.alter
with remote as (
select experience_level,work_year,count(*) as remote_count
from salaries
where work_year in(2021,2024) and remote_ratio = 100
group by experience_level,work_year),

total as(
select experience_level,work_year,count(*) as total_count
from salaries
where work_year in(2021,2024)
group by experience_level,work_year)

select r.experience_level,
max(case when t.work_year = 2024 then (remote_count/total_count)*100 end )as 2024_percentage,
max(case when t.work_year = 2021 then (remote_count/total_count)*100 end )as 2021_percentage
from remote r
join total t on r.experience_level=t.experience_level and r.work_year=t.work_year
WHERE r.work_year IN (2021, 2024)
group by experience_level;


-- 8  
-- AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. 
-- Your objective is to calculate the average salary increase percentage for each experience level and job title between the years 2023 and 2024.

select *,
((avg_2024-avg_2023)*100)/avg_2023 as increase_percentage
from
(select experience_level,job_title,
avg(case when work_year = 2023 then salary_in_usd end) as avg_2023,
avg(case when work_year = 2024 then salary_in_usd end) as avg_2024
from salaries
where work_year in (2023,2024)
group by experience_level,job_title) as t;


-- 9
-- You're a database administrator tasked with role-based access control for a company's employee database. 
-- Your goal is to implement a security measure where employees in different experience level (e.g. Entry Level, Senior level etc.) 
-- can only access details relevant to their respective experience level, ensuring data confidentiality and minimizing the risk of unauthorized access.

create user 'Entry-level'@'%' identified by 'EN';
create user 'Mid-level'@'%' identified by 'MI';
create user 'Senior-level'@'%' identified by 'SE';
create user 'Executive-level'@'%' identified by 'EX';
show privileges;

create view ENTRY_LEVEL as (
select * from salaries where experience_level = 'EN'
);
create view MID_LEVEL as (
select * from salaries where experience_level = 'MI'
);
create view SENIOR_LEVEL as (
select * from salaries where experience_level = 'SE'
);
create view EXECUTIVE_LEVEL as (
select * from salaries where experience_level = 'EX'
);

grant select on `projects_case_study`.ENTRY_LEVEL to 'Entry-level'@'%';
grant select on `projects_case_study`.ENTRY_LEVEL to 'Mid-level'@'%';
grant select on `projects_case_study`.ENTRY_LEVEL to 'Senior-level'@'%';
grant select on `projects_case_study`.ENTRY_LEVEL to 'Executive-level'@'%';



-- 10 
-- As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. 
-- Your Task is to know how many people were employed IN different types of companies AS per their size IN 2021.

select company_size,count(*)
from salaries
where work_year = 2021
group by company_size;

-- 11
-- Imagine you are a talent Acquisition specialist Working for an International recruitment agency. 
-- Your Task is to identify the top 3 job titles that command the highest average salary Among full-time Positions IN the year 2023. 
-- However, you are Only Interested IN Countries WHERE there are more than 50 employees, Ensuring a robust sample size for your analysis.

with loc as (
select company_location from salaries
where work_year = 2023 and employment_type = 'FT'
group by company_location
having count(*) > 50),

tab as (
select * from salaries 
where company_location in (select * from loc))

select job_title,avg(salary_in_usd) as average
from tab
where work_year = 2023 and employment_type = 'FT'
group by job_title
order by average desc
limit 3;

-- 12 
--  As a database analyst you have been assigned the task to Select Countries where 
-- average mid-level salary is higher than overall mid-level salary for the year 2023.

select * from (
select distinct company_location,
avg(salary_in_usd) over(partition by company_location) as per_loc,
avg(salary_in_usd) over() as overall
from salaries
where work_year = 2023 and experience_level = 'MI') as t
where per_loc > overall;
 
-- 13
-- As a database analyst you have been assigned the task to Identify the 
-- company locations with the highest and lowest average salary for senior-level (SE) employees in 2023. 


create view abc as (
select company_location, avg(salary_in_usd) as a
from salaries
where work_year = 2023 and experience_level = 'SE'
group by company_location);

select * from 
(select *, 'Highest' as stats from abc order by a desc limit 1)
as high
union 
select * from 
(select *,'lowest' as stats from abc order by a limit 1)
as low;

-- 14
-- You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. 
-- By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles. 

select *,
((avg_24-avg_23)*100)/avg_23 as percentage_increase
from(
select job_title,
avg(case when work_year = 2023 then salary_in_usd end) as avg_23,
avg(case when work_year = 2024 then salary_in_usd end) as avg_24
from salaries
where work_year in (2023,2024)
group by job_title) as t;


-- 15
-- You've been hired by a global HR Consultancy to identify 
-- Countries experiencing significant salary growth for entry-level roles. 
-- Your task is to list the top three Countries with the highest salary growth rate FROM 2020 to 2023, 
-- Considering Only companies with more than 20 employees, helping multinational Corporations identify Emerging talent markets.

with countries as (
select company_location
from salaries
where experience_level = 'EN'
group by company_location
having count(*) > 20),

final_data as (
select * from salaries 
where company_location in (select * from countries))

select *,
(avg_2023-avg_2020)*100/avg_2020 as increase_percentage from(
select company_location,
avg(case when work_year = 2020 then salary_in_usd end) as avg_2020,
avg(case when work_year = 2023 then salary_in_usd end) as avg_2023
from final_data
where experience_level = 'EN' and work_year in (2020,2023)
group by company_location) as t
order by increase_percentage desc
limit 3;



-- 16
-- Picture yourself as a data architect responsible for database management. 
-- Companies in US and AU(Australia) decided to create a hybrid model for employees they decided that employees earning salaries exceeding $90000 USD, will be given work from home. 
-- You now need to update the remote work ratio for eligible employees, ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.

update salaries
set remote_ratio = 100
where salary_in_usd > 90000 and company_location in ('US','AU');


-- 17 
-- In the year 2024, due to increased demand in the data industry, there was an increase in salaries of data field employees.
-- Entry Level-35% of the salary.
-- Mid junior – 30% of the salary.
-- Immediate senior level- 22% of the salary.
-- Expert level- 20% of the salary.
-- Director – 15% of the salary.
-- You must update the salaries accordingly and update them back in the original database.

update salaries 
set salary_in_usd = salary_in_usd+salary_in_usd*0.30
where experience_level = 'MI' and work_year = 2024;

update salaries 
set salary_in_usd = salary_in_usd+salary_in_usd*0.35
where experience_level = 'EN' and work_year = 2024;
 
update salaries 
set salary_in_usd = salary_in_usd+salary_in_usd*0.22
where experience_level = 'SE' and work_year = 2024;

update salaries 
set salary_in_usd = salary_in_usd+salary_in_usd*0.20
where experience_level = 'EX' and work_year = 2024;

-- or


UPDATE salaries
SET salary_in_usd = salary_in_usd * (
    CASE 
        WHEN experience_level = 'EN' THEN 1.35
        WHEN experience_level = 'MI' THEN 1.30
        WHEN experience_level = 'SE' THEN 1.22
        WHEN experience_level = 'EX' THEN 1.20
        ELSE 1
    END
    )
WHERE work_year = 2024
  AND (
    experience_level IN ('EN', 'MI', 'SE', 'EX')
  );

-- 18 
-- You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.

select job_title,work_year,sal
from(
select *,
rank() over(partition by job_title order by sal desc) as r
from(
select job_title, work_year, avg(salary_in_usd) as sal
from salaries
group by job_title, work_year) as t1) as t2
where r =1;

-- 19 
-- You have been hired by a market research agency where you have been assigned the task to show the percentage of different employment type (full time, part time) in Different job roles, 
-- in the format where each row will be job title, each column will be type of employment type and cell value for that row and column will show the % value.


with abc as (
select job_title,employment_type,count(*) as `both`
from salaries
group by job_title,employment_type),

abd as (
select job_title, count(*) as total
from salaries
group by job_title),

final_data as (
select job_title,employment_type,
`both`*100/total as percentage
from(
select abc.job_title,employment_type,`both`,total from abc
join abd on abc.job_title = abd.job_title) as t)

select job_title,
round(coalesce(max(Case When employment_type = 'CT' then percentage end), 0), 2),
round(coalesce(max(Case When employment_type = 'FT' then percentage end), 0), 2),
round(coalesce(max(Case When employment_type = 'PT' then percentage end), 0), 2),
round(coalesce(max(Case When employment_type = 'FL' then percentage end), 0), 2)
from final_data
group by job_title;





























