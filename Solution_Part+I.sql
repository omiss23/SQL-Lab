use supply_db ;


Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/
# Answer:-
select Product_Id, Product_Name
from category as cat 
inner join product_info as pi
on cat.id = pi.category_id
where name regexp "golf"
order by Product_Id;

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/
# Answer:-
select pi.product_name, sum(oi.sales) as Sales 
from product_info as pi 
inner join category as cat 
on pi.category_id = cat.id 
inner join ordered_items as oi 
on pi.product_id = oi.item_id
where cat.name like '%GOLF%'
group by pi.product_name
order by sales desc
limit 10;

-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/
# Answer:-
select Segment as Customer_segment, count(Order_Id) as Orders
from customer_info as ci 
inner join orders as ord 
on ci.Id = ord.Customer_Id
group by Segment
order by Orders desc;

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/
# Answer:-
with order_seg as
(
select ci.segment as customer_segment,
    count(o.order_id) as orders 
from orders o 
left join customer_info ci
on o.customer_id = ci.id 
where real_shipping_days = 6
group by 1 
)

-- **********************************************************************************************************************************
