use `projects_case_study`;

select * from sharktank;
truncate table sharktank;
drop table sharktank;

CREATE TABLE sharktank (
  Season_Number INT,
  Startup_Name VARCHAR(255),
  Episode_Number INT,
  Pitch_Number INT,
  Season_Start VARCHAR(20),
  Season_End VARCHAR(20),
  Anchor VARCHAR(100),
  Industry VARCHAR(255),
  Business_Description TEXT,
  Started_in VARCHAR(50),
  Number_of_Presenters INT,
  Male_Presenters INT,
  Female_Presenters INT,
  Transgender_Presenters INT,
  Couple_Presenters INT,
  Pitchers_Average_Age VARCHAR(50),
  Pitchers_City VARCHAR(100),
  Pitchers_State VARCHAR(100),
  Yearly_Revenue_in_lakhs VARCHAR(20),
  Monthly_Sales_in_lakhs VARCHAR(20),
  Original_Ask_Amount FLOAT,
  Original_Offered_Equity_in_percent FLOAT,
  Valuation_Requested_in_lakhs FLOAT,
  Received_Offer VARCHAR(50),
  Accepted_Offer VARCHAR(50),
  Total_Deal_Amount_in_lakhs FLOAT,
  Total_Deal_Equity_percent FLOAT,
  Number_of_Sharks_in_Deal INT,
  Namita_Investment_Amount_in_lakhs FLOAT,
  Vineeta_Investment_Amount_in_lakhs FLOAT,
  Anupam_Investment_Amount_in_lakhs FLOAT,
  Aman_Investment_Amount_in_lakhs FLOAT,
  Peyush_Investment_Amount_in_lakhs FLOAT,
  Amit_Investment_Amount_in_lakhs FLOAT,
  Ashneer_Investment_Amount FLOAT,
  Namita_Present VARCHAR(5),
  Vineeta_Present VARCHAR(5),
  Anupam_Present VARCHAR(5),
  Aman_Present VARCHAR(5),
  Peyush_Present VARCHAR(5),
  Amit_Present VARCHAR(5),
  Ashneer_Present VARCHAR(5)
)
CHARACTER SET utf8mb4;


Load data INFILE  "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sharktank.csv"
into table sharktank
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

DESCRIBE sharktank;


SHOW VARIABLES LIKE 'secure_file_priv';



-- You Team must promote shark Tank India season 4, The senior come up with the idea 
-- to show highest funding domain wise so that new startups can be attracted, and you were assigned the task to show the same. 
select Industry,max(Total_Deal_Amount_in_lakhs) as Deal_Amount_in_lakhs 
from sharktank
group by Industry
order by Deal_Amount_in_lakhs desc;


-- You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
select *,round( (total_female/ cast(total_male as float)) *100 ,2) 
from(
select Industry,sum(Male_Presenters) as total_male,sum(Female_Presenters) as total_female from sharktank
group by Industry) 
as t
where cast(total_female as float)/cast(total_male as float) > 0.7;



-- You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per season sale pitch made, 
-- pitches who received offer and pitches that were converted. Also show the percentage of pitches converted and percentage of pitches entertained.

select 
Season_Number,
count(Season_Number),
sum(case when Received_Offer = 'Yes' then 1 
    else 0
    end)  as received_offer,
(sum(case when Received_Offer = 'Yes' then 1 else 0 end)/count(Season_Number))*100 as percent_received_offer,
sum(case when Accepted_Offer = 'Yes' then 1 
    else 0
    end)  as Accepted_Offer,
(sum(case when Accepted_Offer = 'Yes' then 1 else 0 end)/count(Season_Number))*100 as percent_Accepted_Offer
from sharktank
group by Season_Number;



-- As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show, 
-- you are determining the season with the highest average monthly sales and 
-- identify the top 5 industries with the highest average monthly sales during that season to optimize investment decisions?

set @season = (select Season_Number from sharktank
			   where Monthly_Sales_in_lakhs <> 'Not Mentioned'
			   group by Season_Number
			   order by round(avg(Monthly_Sales_in_lakhs)) desc
			   limit 1);

select Industry,round(avg(Monthly_Sales_in_lakhs),2) as avg_sales 
from sharktank
where season_number =@season
and Monthly_Sales_in_lakhs <> 'Not Mentioned'
group by Industry
order by round(avg(Monthly_Sales_in_lakhs)) desc
limit 5;



-- As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent increases in funds raised over multiple seasons. 
-- This requires focusing on industries where data is available across all three seasons. 
-- Once these industries are pinpointed, your task is to delve into the specifics, analyzing the number of pitches made, offers received, and offers converted per season within each industry.

-- find industries that are present in all 3 seasons

with c_i as (
		(select distinct Industry from sharktank
		where Season_Number = 1)
		intersect
		(select distinct Industry from sharktank
		where Season_Number = 2)
		intersect
		(select distinct Industry from sharktank
		where Season_Number = 3)
		),

-- find the avg / total funds across seasons and compare(maybe pivot it)
 ind as (
select * from 
		(
		SELECT 
			Industry,
			ROUND(SUM(CASE WHEN Season_Number = 1 THEN Total_Deal_Amount_in_lakhs ELSE 0 END), 2) AS Season_1_Total,
			ROUND(SUM(CASE WHEN Season_Number = 2 THEN Total_Deal_Amount_in_lakhs ELSE 0 END), 2) AS Season_2_Total,
			ROUND(SUM(CASE WHEN Season_Number = 3 THEN Total_Deal_Amount_in_lakhs ELSE 0 END), 2) AS Season_3_Total
		FROM sharktank
		WHERE Industry IN (SELECT * FROM c_i)
		GROUP BY Industry
		ORDER BY Industry
		) as t
where Season_3_Total > Season_2_Total and Season_2_Total > Season_1_Total and Season_1_Total <> 0
)

-- go into specifics per season as mentioned in question.
select Season_Number,Industry, count(Pitch_Number),
sum(case when Received_Offer = 'Yes' then 1 else 0 end) as Received_Offer,
sum(case when Accepted_Offer = 'Yes' then 1 else 0 end) as Accepted_Offer 
from sharktank
where Industry in (select Industry from ind)
group by Industry,Season_Number
order by Industry,Season_Number;



-- Every shark wants to know in how much year their investment will be returned, so you must create a system for them, 
-- where shark will enter the name of the startup’s and the based on the total deal and 
-- equity given in how many years their principal amount will be returned and make their investment decisions.
-- next level is telling how much each shark will make it back if multiple sharks are involved. 

select * from sharktank;

delimiter $$
create procedure ROI (in startup varchar(100))
begin
    declare offer_status varchar(20);
    declare equity int;
    declare rev varchar(30);
    declare deal_amt int;
    
    select Accepted_Offer,Total_Deal_Equity_percent,Yearly_Revenue_in_lakhs,Total_Deal_Amount_in_lakhs
    into offer_status,equity,rev,deal_amt
    from sharktank
    where Startup_Name = startup;
    
    case
      when
        offer_status = 'No' then select 'cant calculate' as roi;
	  when
        offer_status = 'Yes' and rev = 'Not Mentioned' then select 'cant calculate' as roi;
	  else
        select startup,rev,deal_amt,equity,round((deal_amt*100)/(rev*equity),2);
        
	end case;
end $$ 
delimiter ;

drop procedure ROI;

call ROI('TagzFoods');


-- In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," 
-- tends to put the most money into each deal on average. This comparison helps us see who's the most generous with 
-- their investments and how they measure up against their fellow investors.

select shark, avg(investment) from(
select Namita_Investment_Amount_in_lakhs as investment, 'Namita' as shark from sharktank where Namita_Investment_Amount_in_lakhs > 0
union all 
select Vineeta_Investment_Amount_in_lakhs as investment, 'Vineeta' as shark from sharktank where Vineeta_Investment_Amount_in_lakhs > 0
union all 
select Anupam_Investment_Amount_in_lakhs as investment, 'Anupam' as shark from sharktank where Anupam_Investment_Amount_in_lakhs > 0
union all 
select Aman_Investment_Amount_in_lakhs as investment, 'Aman' as shark from sharktank where Aman_Investment_Amount_in_lakhs > 0
union all 
select Peyush_Investment_Amount_in_lakhs as investment, 'Peyush' as shark from sharktank where Peyush_Investment_Amount_in_lakhs > 0
union all 
select Amit_Investment_Amount_in_lakhs as investment, 'Amit' as shark from sharktank where Amit_Investment_Amount_in_lakhs > 0
union all 
select Ashneer_Investment_Amount as investment, 'Ashneer' as shark from sharktank where Ashneer_Investment_Amount > 0) as t
group by shark;



-- Develop a stored procedure that accepts inputs for the season number and the name of a shark. 
-- The procedure will then provide detailed insights into the total investment made by that specific shark across different industries during the specified season. 
-- Additionally, it will calculate the percentage of their investment in each sector relative to the total investment in that year, 
-- giving a comprehensive understanding of the shark's investment distribution and impact.

select * from sharktank;


delimiter $$
create procedure shark_investment (in season int, name varchar(50))
begin
    with shark_data as (
			select Season_Number,Namita_Investment_Amount_in_lakhs as investment, 'Namita' as shark,Startup_Name,Industry from sharktank
			union all
			select Season_Number,Vineeta_Investment_Amount_in_lakhs as investment, 'Vineeta' as shark,Startup_Name,Industry from sharktank
			union all
			select Season_Number,Anupam_Investment_Amount_in_lakhs as investment, 'Anupam' as shark,Startup_Name,Industry from sharktank
			union all
			select Season_Number,Aman_Investment_Amount_in_lakhs as investment, 'Aman' as shark,Startup_Name,Industry from sharktank
			union all
			select Season_Number,Peyush_Investment_Amount_in_lakhs as investment, 'Peyush' as shark,Startup_Name,Industry from sharktank
			union all
			select Season_Number,Amit_Investment_Amount_in_lakhs as investment, 'Amit' as shark,Startup_Name,Industry from sharktank
			union all
			select Season_Number,Ashneer_Investment_Amount as investment, 'Ashneer' as shark,Startup_Name,Industry from sharktank
	)

    select *,
    round((total_investment_industry_wise*100)/sum(total_investment_industry_wise) over(),2) as percent
    from (
    select Industry,round(sum(investment),2) as total_investment_industry_wise from shark_data
    where Season_Number = season and  shark = name
    group by Industry
    having sum(investment) > 0) as t;


end $$
delimiter ;

drop procedure shark_investment;

call shark_investment(2,'Aman');
