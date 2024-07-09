

use project4python_sql

drop table  df_orders
truncate table df_orders
select * from df_orders


--1. find top 10 highest revenue generating product
select top 10 product_id , sum(total_sale_price) as sales
from df_orders
group by product_id 
order by sales desc 


--2. find top 5 product in each region by highest revenue generating 
with cte as (
select region, product_id , sum(total_sale_price) as sales
from df_orders
group by region, product_id )

select * from (
select * ,
row_number() over(partition by region order by sales desc) as rn
from cte ) a 
where a.rn <=5 


--3. find month over month growth for year 2022 and 2023 
with cte as (
select year(order_date) as year , MONTH(order_date) as month,
sum(total_sale_price) as sales from df_orders 
group by year(order_date) , MONTH(order_date)
) 
select month, 
sum(case when year = 2023 then sales else 0 end) as sales_2023 ,
sum(case when year = 2022 then sales else 0 end )as sales_2022 
from cte 
group by month


--4. for each category which month has highest sales 
with cte as(
select
category ,format(order_date,'yyyyMM') as month_year,count(total_sale_price) as total
from df_orders 
group by category ,format(order_date,'yyyyMM')
)
select * from (
select * , 
row_number() over(partition by category order by total desc) as rn 
from cte ) a 
where rn =1 



select * from df_orders

--5. which subcategory has highest yoy growth
with cte as (
select sub_category,year(order_date) as year ,
sum(total_sale_price) as sales
from df_orders 
group by sub_category,year(order_date) 
) ,
cte2 as (
select sub_category, 
sum(case when year = 2023 then sales else 0 end) as sales_2023 ,
sum(case when year = 2022 then sales else 0 end )as sales_2022 
from cte 
group by sub_category )

select top 1 * , 
round(((sales_2023- sales_2022 ) * 100 ) / sales_2022 ,3) as growth 
from cte2 
order by growth desc 
