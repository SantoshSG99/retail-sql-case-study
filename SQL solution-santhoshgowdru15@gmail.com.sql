				--//[DATA PREPARATION AND UNDERSTANDING]//--
							--//[SOLUTIONS]//--




--ans 1]   --**total number of_ rows_ from_ 3 tables**-- 

    select count(*) from [dbo].[Customer]
    select COUNT(*) from [dbo].[prod_cat_info]
	select count(*) from [dbo].[Transactions]

	   ---end



--ans 2]   --**total number of_ transaction_ that have return_**--

	select sum([total_amt]) as [total return]
	from [dbo].[Transactions]
	where total_amt < 0

       ---end


--ans 3]   --**date_format_ for_  transaction_date**-


	update [dbo].[Transactions]
	set [tran_date] =convert(varchar,convert(date,[tran_date],112),23) 

	 --**date_format_ for_ customer_dob**--
	update [dbo].[Customer]
	set [DOB] = convert(varchar,convert(date,[DOB],112),23)

	update [dbo].[Transactions]
	set [Qty] = CONVERT(float(25),[Qty])

	alter table [dbo].[Transactions]
	alter column [Qty] float (35)

    
	---end
  


--ans 4]   --**time_ range_  of_ transaction_ by_ date_,month_,year_,** 

      select 
	  DATEDIFF(day,min([tran_date]),max([tran_date])) as [days],
	  DATEDIFF(month,min([tran_date]),MAX([tran_date])) as[months],
	  datediff(year,MIN([tran_date]),MAX([tran_date])) as[years]
	   from [dbo].[Transactions]

	   ---end



--ans 5]   --** the prod_cat having_ sub_category DIY**-

      select [prod_cat],[prod_subcat] from [dbo].[prod_cat_info]
      where [prod_subcat] ='diy'
  
        ---end


	--///[DATA ANALYSIS]///

--ans 1]   --most frequently used channel for transaction--
	 SELECT TOP 1 [Store_type],COUNT(Store_type) as Transaction_Count FROM [dbo].[Transactions]
	 GROUP BY [Store_type]
	 ORDER BY Transaction_Count Desc
	
	--end


--ans 2]   --**count_  of_ male and_ female**-

   select  gender,count(gender) as[count of gender] from [dbo].[Customer]
     where gender is not null
    group by gender


	---end

--ans 3]    --**maximum number of customer by city **--

	 select top 1 [city_code],count(customer_Id) as [number of customer] from [dbo].[Customer]
	 group by [city_code]
	 order by [number of customer] desc

	    ---end


--ans 4]      --**subcategories under the books category**--

      select [prod_cat],count([prod_subcat]) as sub_category from [dbo].[prod_cat_info]
      where [prod_cat] = 'books'
	  group by [prod_cat]
	 
	 ---end

--ans 5]      **maximum quantity of product ever ordered**

       select max(abs([Qty]))  as max_Qty from [dbo].[Transactions]
	   where Qty > 0
	      
		  ---end

--ans 6]   -- ** net total revenue  for_ electronics and books**--

      select p.prod_cat,SUM(t.total_amt) as total_revenue from [dbo].[prod_cat_info] as p
	  join [dbo].[Transactions] as t on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code =p.prod_sub_cat_code
	  where total_amt > 0
	  group by p.prod_cat
      having   p.prod_cat = 'electronics' or p.prod_cat = 'books'  
		 ---end
	

--ans 7]   --**customer having_ >10 transction with_ excluding returns_***--

     select [cust_id],count([transaction_id]) as [transaction > 10] from [dbo].[Transactions]
	 where total_amt>0
	 group by [cust_id]
	 having count([transaction_id]) > 10 


--ans 8]  --//combined revenue for for the 'electronics and clothing from flagship stores//--
    
     select t.store_type, sum(CASE WHEN t.total_amt > 0 THEN t.total_amt ELSE 0 END) as [combined revenue] from prod_cat_info as p 
	 join [dbo].[Transactions] as t on t.prod_cat_code = p.prod_cat_code and t.prod_cat_code =p.prod_sub_cat_code
	 where Store_type = 'flagship store' and ( p.prod_cat = 'clothing' or p.prod_cat = 'electronics')
	 group by Store_type


--ans 9]  --//total revenue from male for custumers from electronics as output subcat//--
           
	   select p.prod_subcat,c.gender,SUM(CASE WHEN t.total_amt > 0 THEN t.total_amt ELSE 0 END) as revenue from [dbo].[Customer] as c
	   join [dbo].[Transactions] as t on t.cust_id =c .customer_Id
	   join [dbo].[prod_cat_info] as p on p.prod_cat_code = t.prod_cat_code and p.prod_sub_cat_code =t.prod_subcat_code
	   where c.Gender = 'm' and( p.prod_cat = 'electronics')
	   group by p.prod_subcat,Gender


--ans 10]    --//percentage of sales and return by prod sub category  by top 5 sub category in terms of sales//-- 
          
		    
		--- 10.What is percentage of sales and returns by product sub category; display only top 
-- 5 sub categories in terms of sales?




 WITH SalesReturns AS (
						SELECT P.prod_subcat,
									SUM(CASE WHEN T.total_amt > 0 THEN T.total_amt ELSE 0 END) AS Total_Sales,
									SUM(CASE WHEN T.total_amt < 0 THEN -T.total_amt ELSE 0 END) AS Total_Returns
																												FROM Transactions T

    JOIN prod_cat_info P ON T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code =P.prod_sub_cat_code
    GROUP BY P.prod_subcat
																		),

SalesReturnsPercentages AS (
						 SELECT  prod_subcat, Total_Sales, Total_Returns,
						 Total_Sales / (Total_Sales + Total_Returns) * 100 AS Sales_Percentage,
						Total_Returns / (Total_Sales + Total_Returns) * 100 AS Returns_Percentage
																									FROM SalesReturns )
																														

SELECT TOP 5 *
FROM SalesReturnsPercentages
ORDER BY Sales_Percentage DESC;


		 


--ans 11]    --	//the net total revenue for customers aged between 25 to 35  from last 30 days transaction//-

    with tmp_1 as (
    select MAX([tran_date]) as m_date from [dbo].[Transactions]
    )

	select SUM([total_amt]) as total_revenue
	from [dbo].[Transactions] as t
	join  [dbo].[Customer] as c on c.customer_Id =t.cust_id
	join tmp_1 as m on m.m_date = c.DOB
	where DATEDIFF(year,c.dob,m_date) between 25 and 35 and t.tran_date>=DATEADD(day,-30,m_date)
	
	  


--ans 12 ]   --// the max value of returns from the last 3 months transaction by the product//--
         
		DECLARE @MaxDate DATE;
SELECT @MaxDate = MAX(tran_date) FROM Transactions;

-- Calculate the total returns for each product category in the last 3 months from the max transaction date
WITH CategoryReturns AS (
    SELECT  P.prod_cat, SUM(T.total_amt) AS Total_Returns FROM   Transactions T
    JOIN  prod_cat_info P ON T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
    WHERE T.tran_date BETWEEN DATEADD(MONTH, -3, @MaxDate) AND @MaxDate   AND T.total_amt < 0
    GROUP BY P.prod_cat
)

-- Select the category with the maximum returns
SELECT TOP 1 *
FROM CategoryReturns
ORDER BY Total_Returns DESC;


--ans 13 ]   --//maximum product sell by sore type //--

         alter table [dbo].[Transactions]
		 alter column [Qty] numeric

		 select top 1 Store_type,SUM([total_amt]) as [maximum sale],sum (qty) as [maximum qty] from [dbo].[Transactions]
		 where total_amt>0 and Qty> 0
		 group by Store_type
		 order by  [maximum sale]  desc


--ans 14 ]   --the categories for which the averege revenue is above the overall averege//--
            
		

	        select  p.prod_cat,avg(total_amt) as averge_amt   from [dbo].[Transactions] as t
			join [dbo].[prod_cat_info] as p  on p.prod_cat_code =t.prod_cat_code  and p.prod_sub_cat_code = p.prod_sub_cat_code	      
			group by p.prod_cat
			having avg(total_amt) > (select AVG([total_amt]) as [total average] from [dbo].[Transactions]  )
			             
			


--ans 15 ]    --//average and total revenue by each subcategory for the category which are among top 5 category in term quentity sold//-- 
           
 
 SELECT  p.prod_subcat, 
		AVG(t.total_amt) as AverageRevenue, 
		SUM(t.total_amt) as TotalRevenue
										FROM Transactions t
JOIN 
     prod_cat_info p ON t.prod_cat_code = p.prod_cat_code AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE 
    t.prod_cat_code IN (
					SELECT TOP 5 prod_cat_code
					FROM Transactions
					GROUP BY prod_cat_code
					ORDER BY SUM(Qty) DESC
    )
GROUP BY p.prod_subcat;
