
-- 1. What is the total amount each customer spent at the restaurant?

select 
	s.customer_id,
	sum(mn.price) as Total_amount
from dannys_diner.sales as s
inner join dannys_diner.menu as mn
	on s.product_id = mn.product_id
group by s.customer_id

--2.How many days has each customer visited the restaurant?
select 
	s.customer_id,
	COUNT(distinct s.order_date) as Totaldays
from dannys_diner.sales s
group by s.customer_id

--3. What was the first item(s) from the menu purchased by each customer?

Select customer_id,product_name from
(
Select
	s.customer_id ,
	mn.product_name,
	Dense_RANK() Over(partition by s.customer_id order by s.order_date) as rn
From dannys_diner.sales s
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
) as e
Where rn = 1

--4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select 
	top 1
	mn.product_name,
	count(mn.product_name) as TimesPurchased
from dannys_diner.sales s
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
group by mn.product_name
order by TimesPurchased desc

--5. Which item(s) was the most popular for each customer?
select 
	s.customer_id,
	mn.product_name,
	count(mn.product_name) as TimesPurchased
from dannys_diner.sales s
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
group by s.customer_id,mn.product_name
order by s.customer_id,TimesPurchased desc

--6. Which item was purchased first by the customer after they became a member and what date was it? 
--(including the date they joined)

;with cte as 
(
select 
	s.customer_id,
	s.order_date,
	mb.join_date,
	mn.product_name,
	DENSE_RANK() over (partition by s.customer_id order by s.order_date asc) as rn
from dannys_diner.sales s
inner join dannys_diner.members mb
	on s.customer_id = mb.customer_id
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
where s.order_date >= mb.join_date
)
	select * from cte where cte.rn = 1


--7. Which menu item(s) was purchased just before the customer became a member and when?

;with cte as 
(
select 
	s.customer_id,
	s.order_date,
	mb.join_date,
	mn.product_name,
	DENSE_RANK() over (partition by s.customer_id order by s.order_date asc) as rn
from dannys_diner.sales s
inner join dannys_diner.members mb
	on s.customer_id = mb.customer_id
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
where s.order_date < mb.join_date
)
	select * from cte where cte.rn = 1

--8. What is the number of unique menu items and total amount spent for each member before they became a member?
--We can use a similar approach to the previous 2 questions but this time we might not need to look at the window functions!
;with cte as 
(
select 
	s.customer_id,
	s.order_date,
	mb.join_date,
	mn.product_name,
	mn.price
from dannys_diner.sales s
inner join dannys_diner.members mb
	on s.customer_id = mb.customer_id
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
where s.order_date < mb.join_date
)
	select 
		customer_id,
		count(distinct product_name) as Unique_Menu_Items,
		sum(price) as Total_amount_spent
	from cte 
	group by customer_id


--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

Select
	s.customer_id,
	sum(iif (mn.product_name = 'sushi', mn.price*2.0 *10, mn.price*10))  as Points
From dannys_diner.sales s
inner join dannys_diner.menu mn
	on s.product_id = mn.product_id
group by s.customer_id
order by Points desc


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi.
-- how many points do customer A and B have at the end of January?

;With Cte as 
(
Select 
	s.customer_id,
	s.order_date,
	mb.join_date,
	DATEADD(D,6,mb.join_date) First_7_days,
	mn.product_name,
	mn.price
From dannys_diner.sales s
Inner Join dannys_diner.members mb
	On s.customer_id = mb.customer_id
Inner Join dannys_diner.menu mn
	on s.product_id = mn.product_id
Where s.order_date <= '2021-01-31'
)	
	Select 
		customer_id,
		Sum(
		Case 
			When order_date Between join_date And First_7_days Then price*2*10
			When product_name = 'sushi' Then price*2*10
			Else price*10
			End 
		) as Total_Points
	From Cte
	Group by customer_id

--11. Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL Recreate the following table output using the available data.

Select 
	s.customer_id,
	s.order_date,
	mn.product_name,
	mn.price,
	IIF(s.order_date > mb.join_date,'Y','N') as member
From dannys_diner.sales s 
Left Join dannys_diner.members mb
	on s.customer_id = mb.customer_id
Inner Join dannys_diner.menu mn
	on s.product_id = mn.product_id
Order By customer_id asc, price desc

--12. Danny also requires further information about the ranking of customer products, 
--but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

;With Cte as 
(
Select 
	s.customer_id,
	s.order_date,
	mn.product_name,
	mn.price,
	IIF(s.order_date >= mb.join_date,'Y','N') as member
From dannys_diner.sales s 
Left Join dannys_diner.members mb
	on s.customer_id = mb.customer_id
Left Join dannys_diner.menu mn
	on s.product_id = mn.product_id
)
	Select 
		*,
		Case
			When member = 'N' Then Null
			Else RANK() Over (Partition By customer_id, member Order by Price Desc, order_date ) 
			End ranking
	From Cte
