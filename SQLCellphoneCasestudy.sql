
---------------------------------------------------------ADVANCE SQL CASE STUDY-----------------------------------------------------------------

select * from dim_customer 
select * from dim_date
select * from dim_location
select * from dim_manufacturer
select * from dim_model
select * from fact_transactions

--Q1. List all the states in which we have customers who have bought cellphones from 2005 till today .
	select distinct [state]              
	from 
	dim_location as T1 
	left join fact_transactions as T2  on T1.idlocation = T2.idlocation
	where date >= '2005-01-01'

--Q2. What state in the US is buying more 'Samsung' cell phones ? 
	select top 1
	[state] , sum(Quantity) as cnt
	from 
	dim_location as T1
	left join fact_transactions as T2  on T1.idlocation = T2.idlocation
	left join dim_model as T3 on T2.IDmodel = T3.IDmodel
	left join dim_manufacturer as T4 on T3.IDManufacturer = T4.IDManufacturer
	where country = 'US' and manufacturer_name = 'Samsung'
	group by  [state] 
	order by sum(Quantity)  desc

--Q3.Show the number of transactions for each model per zip code per state .
	select 
	zipcode , [state] , model_name , count(Quantity) as no_of_transactions 
	from 
	dim_location as T1
	left join fact_transactions as T2  on T1.idlocation = T2.idlocation
	left join dim_model as T3 on T2.IDmodel = T3.IDmodel
	left join dim_manufacturer as T4 on T3.IDManufacturer = T4.IDManufacturer
	group by zipcode , [state] ,model_name

--Q4. Show the cheapest cell phone .
	 select top 1
	 manufacturer_name , model_name , MIN(unit_price) as cheap_phone
	 from 
	 dim_model T1
	 left join dim_manufacturer as T2 on T1.idmanufacturer = T2.idmanufacturer 
	 group by manufacturer_name , model_name
	 order by MIN(unit_price ) asc

--Q5.Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price .
		select Model_Name , avg(unit_price) as avg_price 
		from 
		FACT_TRANSACTIONS as T1 
		left join DIM_MODEL as T2 on T2.IDModel = T1.IDModel
		right join (select top 5 
					T3.idmanufacturer ,Manufacturer_Name , sum(quantity) as cnt 
					from 
					fact_transactions as T1                    
					left join DIM_MODEL as T2 on T1.IDModel = T2.IDModel
					left join DIM_MANUFACTURER as T3 on T3.IDManufacturer = T2.IDManufacturer
					group by Manufacturer_Name , T3.idmanufacturer 
					order by cnt  desc) as T3  on T3.IDManufacturer = T2.IDManufacturer
		group by  Model_Name 

--Q6. List the names of the customers and the average amount spent in 2009 , where the average is higher than 500
	select 
	customer_name , T2.IDCustomer,  [Date],  avg(totalprice) as avg_spent
	from 
	DIM_CUSTOMER as T1
	left join FACT_TRANSACTIONS as T2 on T1.IDCustomer = T2.IDCustomer 
	where datepart(year , [date] ) = '2009' 
	group by customer_name , T2.IDCustomer,  [Date]
	having avg(totalprice) > 500

--Q7.List if there is any model that was in the top 5 in terms of quantity , simultaneously in 2008 , 2009 and 2010
	select 
	Model_Name 
	from 
	(
		select top 5                                 
		Model_Name , sum(quantity) as quant 
		from 
		DIM_MODEL as T1 
		left join FACT_TRANSACTIONS as T2 on T1.IDModel = T2.IDModel
		where year([date]) = '2008'
		group by 
		Model_Name
		order by quant desc) as TT1
intersect 
	select 
	Model_Name 
	from 
		(
		select top 5
		Model_Name , sum(quantity) as quant 
		from 
		DIM_MODEL as T1 
		left join FACT_TRANSACTIONS as T2 on T1.IDModel = T2.IDModel
		where year([date]) = '2009'
		group by 
		Model_Name
		order by quant desc) as TT2
intersect 
	select
	 Model_Name 
	 from 
		(
		select top 5
		Model_Name , sum(quantity) as quant 
		from 
		DIM_MODEL as T1 
		left join FACT_TRANSACTIONS as T2 on T1.IDModel = T2.IDModel
		where year([date]) = '2010'
		group by 
		Model_Name
		order by quant desc) as TT3 



--Q8.Show the manufacturer with the 2nd top sales in the year of 2009 and the manufaccturer with the 2nd top sales in the year 2010.

	select * from 
	(
	select top 1
	Manufacturer_Name , sum(TotalPrice  ) as sales 
	from 
	DIM_MANUFACTURER as T1
	left join DIM_MODEL as T2 on T1.IDManufacturer = T2.IDManufacturer
	left join FACT_TRANSACTIONS as T3 on T2.IDModel = T3.IDModel
	where datepart(year,[Date])='2009'                         
	group by Manufacturer_Name                                 
	having  sum(TotalPrice  ) <(select 
		max(sales) as max_sale 
		from  (select 
		Manufacturer_Name , sum(TotalPrice  )  as sales
		from 
		DIM_MANUFACTURER as T1
		left join DIM_MODEL as T2 on T1.IDManufacturer = T2.IDManufacturer
		left join FACT_TRANSACTIONS as T3 on T2.IDModel = T3.IDModel
		where datepart(year,[Date])='2009' 
		group by Manufacturer_Name
		) as T1)  
	order by sales desc) as T1

	union all 

	select * from 
	(
	select top 1
	Manufacturer_Name , sum(TotalPrice  ) as sales
	from 
	DIM_MANUFACTURER as T1
	left join DIM_MODEL as T2 on T1.IDManufacturer = T2.IDManufacturer
	left join FACT_TRANSACTIONS as T3 on T2.IDModel = T3.IDModel
	where datepart(year,[Date])='2010' 
	group by Manufacturer_Name
	having  sum(TotalPrice  ) <(select 
		max(sales) as max_sale 
		from  (select 
		Manufacturer_Name , sum(TotalPrice  )  as sales
		from 
		DIM_MANUFACTURER as T1
		left join DIM_MODEL as T2 on T1.IDManufacturer = T2.IDManufacturer
		left join FACT_TRANSACTIONS as T3 on T2.IDModel = T3.IDModel
		where datepart(year,[Date])='2010' 
		group by Manufacturer_Name
		) as T1 )
	order by sales desc) as T2

--Q9. Show the manufacturers that sold cellphone in 2010 but did't in 2009 
	 select Manufacturer_Name
	 from 
	 DIM_MANUFACTURER as T1 
	 left join DIM_MODEL as T2  on T2.IDManufacturer = T1.IDManufacturer
	 left join FACT_TRANSACTIONS as T3 on T2.IDModel = T3.IDModel
	 where DATEPART(year , [date] ) = '2010' 
	 except
	 select Manufacturer_Name
	 from 
	 DIM_MANUFACTURER as T1 
	 left join DIM_MODEL as T2  on T2.IDManufacturer = T1.IDManufacturer
	 left join FACT_TRANSACTIONS as T3 on T2.IDModel = T3.IDModel
	 where DATEPART(year , [date] ) = '2009'

--Q10. Find top 100 customers and their average spend , average quantity by each year , Also find the percentage of change in their spend .
	select top 25
	T2.IDCustomer,                
	avg(case when year([date]) = '2003' then TotalPrice end) as avg_spend_03 ,
	avg(case when year([date]) = '2004' then TotalPrice end) as avg_spend_04 ,
	abs(avg(case when year([date]) = '2003' then TotalPrice end) -avg(case when year([date]) = '2004' then TotalPrice end)) / (avg(case when year([date]) = '2003' then TotalPrice end)) * 100 as percentage_change ,
	avg(case when year([date]) = '2005' then TotalPrice end) as avg_spend_05 ,
	avg(case when year([date]) = '2006' then TotalPrice end) as avg_spend_06 ,
	abs(avg(case when year([date]) = '2005' then TotalPrice end) -avg(case when year([date]) = '2006' then TotalPrice end)) / (avg(case when year([date]) = '2005' then TotalPrice end)) * 100 as percentage_change ,
	avg(case when year([date]) = '2007' then TotalPrice end) as avg_spend_07 ,
	avg(case when year([date]) = '2008' then TotalPrice end) as avg_spend_08 ,
	abs(avg(case when year([date]) = '2007' then TotalPrice end) -avg(case when year([date]) = '2008' then TotalPrice end)) / (avg(case when year([date]) = '2007' then TotalPrice end)) * 100 as percentage_change ,
	avg(case when year([date]) = '2009' then TotalPrice end) as avg_spend_09 ,
	avg(case when year([date]) = '2010' then TotalPrice end) as avg_spend_10 ,
	abs(avg(case when year([date]) = '2009' then TotalPrice end) -avg(case when year([date]) = '2010' then TotalPrice end)) / (avg(case when year([date]) = '2009' then TotalPrice end)) * 100 as percentage_change ,
	avg(case when year([date]) = '2003' then Quantity end) as avg_qty_03,
	avg(case when year([date]) = '2004' then Quantity end) as avg_qty_04,
	avg(case when year([date]) = '2005' then Quantity end) as avg_qty_05,
	avg(case when year([date]) = '2006' then Quantity end) as avg_qty_06,
	avg(case when year([date]) = '2007' then Quantity end) as avg_qty_07,
	avg(case when year([date]) = '2008' then Quantity end) as avg_qty_08,
	avg(case when year([date]) = '2009' then Quantity end) as avg_qty_09,
	avg(case when year([date]) = '2010' then Quantity end) as avg_qty_10
	from 
	FACT_TRANSACTIONS as T1
	left join DIM_CUSTOMER as T2 on T1.IDCustomer = T2.IDCustomer
	group by 
	T2.IDCustomer
	order by avg_spend_03 desc ,avg_spend_04 desc,avg_spend_05 desc,avg_spend_06 desc,avg_spend_07 desc,
	avg_spend_08 desc,avg_spend_09 desc,avg_spend_10 desc 

