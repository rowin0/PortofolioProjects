use portofolioproject;

select * from features;

select * from train;

select * from stores;

--looking at tables datatype and modify datatype for some columns

alter table features
alter column Fuel_Price float;

update features 
set Unemployment=0
where Unemployment = 'NA';

alter table features
alter column Unemployment float;

alter table features
alter column Date date;

update features
set CPI=0
where CPI = 'NA';

alter table features
alter column CPI float;

alter table train
alter column Date date;

alter table stores
alter column Size float;

--looking at Weekly sales per store, store column is in all three tables 
--looking to see if the number of stores from all three tables matches 

select Store, count(distinct(Store))
from features
group by Store
order by Store desc;


select Store, count(distinct(Store))
from train
group by Store
order by Store asc;


select Store, count(distinct(Store))
from stores
group by Store
order by Store asc;

-- all three tables have the same number of stores 45 now we can look at weekly sales per store

alter table train
alter column Weekly_Sales float; 

select stores.Store, avg(train.Weekly_Sales) as Stores_Weekly_Sales
from stores
inner join train
on stores.Store=train.Store
group by stores.Store
order by Stores_Weekly_Sales desc;

-- we can see that the three top stores are 20, 4, and 14 
-- and the bottom three are 5, 33 and 44


--looking at weekly sales per department 

select * from train;

select Dept, avg(Weekly_Sales) as Dept_Weekly_Sales
from train
group by Dept
order by Dept_Weekly_Sales desc;

-- we can see that that Dept 92- Grocery, 95-DSD Grocery (Vendors) and 38 - Pharmacy are the top three performers
-- Dept 47- Jewelry has a negative balance which needs further investigation, might be from returns, stolen goods or other
-- all bottom Dept that are under $100 need further investigation because the balance is too low for the 45 stores involved



--looking at Holiday column 

select * from train;


select avg(Weekly_Sales)
from train
where IsHoliday = 'TRUE';

select(
(select sum(Weekly_Sales)
from train
where IsHoliday = 'TRUE')/sum(Weekly_Sales)*100) as Overall_Holiday_Increase_Percentage
from train;

-- Overall_Holiday_Percentage = 7.5% we cannot determine if it reaches the target set by budget planners
-- for a better understanding we can analyze what the percentage per store and year is, 
--as each year each store has a set target increase percentage, most stores are counting on holidays to reach their target.

select * from train;

select
year(date)
from train;

alter table train
add Year int;

update train
set year= year(date);

select
month(Date)
from train;

alter table train
add Month int;

update train
set Month = month(Date);

select * from train;


select Store,
(sum(case when IsHoliday= 'True' then Weekly_Sales else 0 end)/sum(Weekly_Sales)*100) as Store_Holiday_Increase_Percentage
from train
group by Store
order by Store_Holiday_Increase_Percentage desc;

-- we can see that the percentage for each store is between 8.2 and 6.8, now depends on the target set for each store 
select Year, 
count(Distinct(Year))
from train
group by Year;


select Store,
(sum(case when IsHoliday= 'True' then Weekly_Sales 
          when Year=2010 then Weekly_Sales		  
          else 0 end)
/sum(Weekly_Sales)*100) as Store_Holiday_Increase_Percentage2010
from train
group by Store
order by Store_Holiday_Increase_Percentage2010 desc;

--2010 increase sales percentage during holidays is between 44% and 34%


select Store,
(sum(case when IsHoliday= 'True' then Weekly_Sales 
          when Year=2011 then Weekly_Sales		  
          else 0 end)
/sum(Weekly_Sales)*100) as Store_Holiday_Increase_Percentage2011
from train
group by Store
order by Store_Holiday_Increase_Percentage2011 desc;

-- 2011 increase sales percentage during holidays is between 42% and 38%

select Store,
(sum(case when IsHoliday= 'True' then Weekly_Sales 
          when Year=2012 then Weekly_Sales		  
          else 0 end)
/sum(Weekly_Sales)*100) as Store_Holiday_Increase_Percentage2012
from train
group by Store
order by Store_Holiday_Increase_Percentage2012 desc;

--2012 increase sales percentage during holidays is between 38% and 30%

--now looking at the markdowns columns

select * from features;

update features
set MarkDown1 = 0,
MarkDown2 = 0,
MarkDown3 = 0,
MarkDown4 = 0,
MarkDown5 = 0
where MarkDown1 = 'NA' or
MarkDown2 = 'NA'or
MarkDown3 = 'NA' or
MarkDown4 = 'NA' or
MarkDown5 = 'NA';

alter table features
alter column  MarkDown1 float;

alter table features
alter column  MarkDown2 float;

alter table features
alter column  MarkDown3 float;

alter table features
alter column  MarkDown4 float;

alter table features
alter column  MarkDown5 float;

-- looking at the total of markdowns during holidays and regular season for each store
select * from features;

select Store,
sum(case when IsHoliday = 'FALSE' then MarkDown1 else 0 end)+
sum(case when IsHoliday = 'FALSE' then MarkDown2 else 0 end)+
sum(case when IsHoliday = 'FALSE' then MarkDown3 else 0 end)+
sum(case when IsHoliday = 'FALSE' then MarkDown4 else 0 end)+
sum(case when IsHoliday = 'FALSE' then MarkDown5 else 0 end) as NonHolidays_Markdowns,
sum(case when IsHoliday = 'TRUE' then MarkDown1 else 0 end)+
sum(case when IsHoliday = 'TRUE' then MarkDown2 else 0 end)+
sum(case when IsHoliday = 'TRUE' then MarkDown3 else 0 end)+
sum(case when IsHoliday = 'TRUE' then MarkDown4 else 0 end)+
sum(case when IsHoliday = 'TRUE' then MarkDown5 else 0 end) as Holidays_Markdowns
from features 
group by Store
order by Holidays_Markdowns  desc;

-- we can see that in the regular season stores 39, 28 and 27 have the most markdowns 
-- during the holiday’s stores 13, 10 and 20 have the most markdowns.


-- looking at CPI and Weekly_Sales per stores

select
year(date)
from features;

alter table features
add Year int;

update features
set Year= year(date);

select features.Year, 
avg(train.Weekly_Sales) as Avg_Weekly_Sales, 
avg(features.CPI) as Avg_CPI
from features
inner join train 
on features.Date = train.Date
group by features.Year
order by features.Year asc;

-- we can see that there is an inverse proportional between CPI and Sales,
-- as the CPI increases the sales decrease


--looking how unemployment affects sales

select features.Year, 
avg(train.Weekly_Sales) as Avg_Weekly_Sales, 
avg(features.Unemployment) as Avg_Unemployment
from features
inner join train 
on features.Date = train.Date
group by features.Year
order by features.Year asc;

-- we can see an odd trend sales and unemployment are direct proportional, 
-- meaning that even that unemployment is dropping, sales are dropping too
-- seems like customers behavior is changing and needs further investigations


-- looking if temperature has any effect on sales
select*from features;

alter table features
alter column Temperature float;

select train.Month, 
avg(train.Weekly_Sales) as Avg_Weekly_Sales, 
avg(features.Temperature) as Avg_Temperature
from features
inner join train 
on features.Date = train.Date
group by train.Month
order by Avg_Weekly_Sales desc;

-- seems like temperature is not influence sales in a direct way 
-- we can see as the holiday months and the ones that have the most sales.


