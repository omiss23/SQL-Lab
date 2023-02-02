use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		
# Answer:-
select DATE_FORMAT(Order_Date,'%Y-%m') as Month,
sum(Quantity) as Quantities_Sold,
sum(Sales) as Sales 
from orders as ord 
left join ordered_items as ord_itm 
on ord.Order_Id = ord_itm.Order_Id
left join product_info as prod_info 
on ord_itm.Item_Id = prod_info.Product_Id
where LOWER(Product_Name) like '%nike%'
group by 1 

-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/
# Answer:-
select Product_Id, Product_Name, cat.Name as Category_Name, dep.Name as Department_Name, Product_Price
from product_info prod  
inner join category cat 
on prod.Category_Id = cat.Id 
inner join department dep 
on prod.Department_Id = dep.Id 
order by Product_Price desc
limit 5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
# Answer:-
select Product_Name, SUM(Sales) as Sales, COUNT(distinct Order_Id) as Distinct_Order_Count
from orders 
inner join ordered_items ord_id 
using(Order_Id) 
inner join product_info pi 
on ord_id.Item_Id = pi.Product_Id
where Type = 'CASH'
group by Product_Name
order by COUNT(distinct Order_Id), SUM(Sales) desc
limit 10;

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
# Answer:-
select * from orders ord
inner join customer_info ci 
on ord.Customer_Id = ci.Id
where State = 'TX' and LOWER(Street) like '%Plaza%' and LOWER(Street) not like '%Mountain%'
order by Order_ID;

-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
# Answer:-
select COUNT(Order_ID) as Order_Count
from orders ord 
inner join customer_info cust_id 
on ord.Customer_Id = cust_id.Id
inner join ordered_items oi 
using(Order_Id) 
inner join product_info pi 
on oi.Item_Id = pi.Product_Id 
inner join department dep 
on pi.Department_Id = dep.Id
where Segment = 'Home Office' and dep.Name = 'Apparel' or dep.Name = 'Outdoors';

-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
# Answer:-
with Orders_cnt as
(
select ord.Order_ID , ord.Customer_Id
from orders ord 
inner join customer_info ci 
on ord.Customer_Id = ci.Id
inner join ordered_items oi 
using(Order_Id) 
inner join product_info pi 
on oi.Item_Id = pi.Product_Id 
inner join department dep 
on pi.Department_Id = dep.Id
where Segment = 'Home Office' and dep.Name = 'Apparel' or dep.Name = 'Outdoors'
)
select State as Order_State, City as Order_City, count(Order_ID) as Order_Count,
dense_rank() over(partition by State order by count(ORDER_ID) desc) as City_rank
from customer_info c  inner join 
Orders_cnt oc 
on oc.Customer_Id = c.Id
group by State, City
order by State, City_rank, City;

-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
# Answer:-
select Shipping_Mode,COUNT(Order_Id) as Shipping_Underestimated_Order_Count,
row_number()over(partition by year(Order_Date) order by count(Order_Id)desc) as Shipping_Mode_Rank
from Orders ord
inner join customer_info ci 
on ord.Customer_Id = ci.Id
where Scheduled_Shipping_Days < Real_Shipping_Days and (Order_Status = 'COMPLETE' or Order_Status = 'CLOSED')
and Segment = 'Consumer'
group by Shipping_Mode, year(Order_Date);

-- **********************************************************************************************************************************





