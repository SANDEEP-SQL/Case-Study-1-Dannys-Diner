# Case-Study 1 Danny's Diner
The following are my solutions to the Case Study 1 Danny's Diner questions in 
[Danny Ma's Serious SQL course](https://www.datawithdanny.com/ "Data With Danny")
<br/>
<br/>
Danny has shared with you 3 key datasets for this case study :
<br/>
- `sales`
- `menu`
- `members`
<br/>

## Case Study Questions

## [Question #1](#case-study-questions)
> What is the total amount each customer spent at the restaurant?
```sql
SELECT
	s.customer_id,
	SUM(m.price) AS total_sales
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
| customer_id  | total_sales |
|--------------|-------------|
|      A       |    76       |
|      B       |    74       |
|      C       |    36       |

## [Question #2](#case-study-questions)
> How many days has each customer visited the restaurant?
```sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS Customer_Visit
FROM dannys_diner.sales
GROUP BY customer_id;
```
| customer_id  | Customer_Visit |
|--------------|----------------|
|      A       |        4       |
|      B       |        6       |
|      C       |        2       |

## [Question #3](#case-study-questions)
> What was the first item(s) from the menu purchased by each customer?
```sql
SELECT
	T.customer_id,
	T.product_name
FROM
(
	SELECT
		s.customer_id,
		m.product_name,
		RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rn
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m
		ON s.product_id = m.product_id
) AS T
WHERE T.rn = 1;
```
| customer_id  |  product_name  |
|--------------|----------------|
|      A       |     sushi      |
|      A       |     curry      |
|      B       |     curry      |
|      c       |     ramen      |
|      c       |     ramen      |

## [Question #4](#case-study-questions)
> What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
SELECT
	TOP 1
	m.product_name,
	COUNT(s.product_id) AS purchased
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchased DESC;
```
| product_name  |  purchased   |
|-------------- |--------------|
|      ramen    |     8        |

## [Question #5](#case-study-questions)
> Which item(s) was the most popular for each customer?
```sql
SELECT
	t.customer_id,
	t.product_name,
	t.item_quantity
FROM 
(
	SELECT
		s.customer_id,
		m.product_name,
		COUNT(1) as item_quantity,
		DENSE_RANK() OVER ( PARTITION BY s.customer_id ORDER BY COUNT(1) DESC) AS RN
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m
	on s.product_id = m.product_id
	GROUP BY S.customer_id,m.product_name
) AS T
WHERE T.RN = 1;
```
| customer_id | product_name | item_quantity |
|-------------|--------------|---------------|
|      A      |     ramen    |      3        |
|      B      |     sushi    |      2        |
|      B      |     curry    |      2        |
|      B      |     ramen    |      2        |
|      C      |     ramen    |      3        |

## [Question #6](#case-study-questions)
> Which item was purchased first by the customer after they became a member and what date was it? (including the date they joined)
```sql
WITH CTE AS
(
SELECT
s.customer_id,
s.order_date,
FIRST_VALUE(m.product_name) OVER (PARTITION BY S.customer_id ORDER BY s.order_date ASC) AS first_product_name,
DENSE_RANK() OVER (PARTITION BY S.customer_id ORDER BY s.order_date asc) AS RN
FROM dannys_diner.sales S
INNER JOIN dannys_diner.members MB
	ON S.customer_id = MB.customer_id
INNER JOIN dannys_diner.menu M
	ON S.product_id = M.product_id
WHERE S.order_date >= MB.join_date
)
	SELECT
		CTE.CUSTOMER_ID,
		CTE.ORDER_DATE,
		CTE.FIRST_PRODUCT_NAME
	FROM CTE
	WHERE CTE.RN = 1;
```
| customer_id | order_date   | product_name  |
|-------------|--------------|---------------|
|      A      |2021-01-07    |      curry    |
|      B      |2021-01-11    |      sushi    |

## [Question #7](#case-study-questions)
> Which menu item(s) was purchased just before the customer became a member and when?

This is very similar to question 6 previously but now the record orders should be reversed using the window functions.
```sql
WITH CTE AS
(
SELECT
	S.customer_id,
	S.order_date,
	S.product_id,
	M.product_name,
	DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS RN
FROM dannys_diner.sales S
INNER JOIN dannys_diner.members MB
	ON S.customer_id = MB.customer_id
INNER JOIN dannys_diner.menu M
	ON S.product_id = M.product_id
WHERE S.order_date < MB.join_date
)
	SELECT
		CTE.CUSTOMER_ID,
		CTE.ORDER_DATE,
		CTE.PRODUCT_NAME
	FROM CTE
	WHERE CTE.RN = 1;
```
| customer_id | order_date   | product_name  |
|-------------|--------------|---------------|
|      A      |2021-01-01    |      sushi    |
|      A      |2021-01-01    |      curry    |
|      B      |2021-01-04    |      sushi    |

## [Question #8](#case-study-questions)
> What is the number of unique menu items and total amount spent for each member before they became a member?

We can use a similar approach to the previous 2 questions but this time we might not need to look at the window functions!
```sql
SELECT
	S.customer_id,
	COUNT(DISTINCT M.product_name) AS unique_menu_items,
	SUM(m.price) AS total_spends
FROM dannys_diner.sales S
INNER JOIN dannys_diner.members MB
	ON S.customer_id = MB.customer_id
INNER JOIN dannys_diner.menu M
	ON S.product_id = M.product_id
WHERE S.order_date < MB.join_date
GROUP BY S.customer_id
```
| customer_id | unique_menu_items | total_spends |
|-------------|-------------------|--------------|
|      A      |        2          |      25      |
|      B      |        2          |      40      |

## [Question #9](#case-study-questions)
> If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

We will need to use a `CASE WHEN` statement for this question to figure out when there is a sushi item purchased - then we can aggregate the points altogether for each customer using a `GROUP BY`
```sql
SELECT
	S.customer_id,
	SUM(CASE 
		WHEN M.product_name = 'sushi' THEN M.price * 10 * 2
		ELSE M.price * 10 * 1
	    END 
	   ) AS points
FROM dannys_diner.sales S
INNER JOIN dannys_diner.menu M
	ON S.product_id = M.product_id
GROUP BY S.customer_id
```
| customer_id   |  points  |
|-------------- |----------|
|      A        |     860  |
|      B        |     940  |
|      C        |     360  |

## [Question #10](#case-study-questions)
> In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

This is an extension of the previous question with a modifier to make it more difficult!

How will you manage to look at the join date and the week after? Be careful of the date boundaries used throughout this SQL query - you may need to change a few different dates below!
```sql
WITH CTE AS
(
SELECT
	S.customer_id,
	S.order_date,
	mb.join_date,
	DATEADD(DD, 6, mb.join_date) AS next_week,
	M.product_name,
	M.price
FROM dannys_diner.sales S
INNER JOIN dannys_diner.members MB
	ON S.customer_id = MB.customer_id
INNER JOIN dannys_diner.menu M
	ON S.product_id = M.product_id
WHERE S.order_date <= '2021-01-31'
)
	SELECT
		CTE.customer_id,
		SUM(CASE
			WHEN CTE.order_date BETWEEN CTE.join_date AND CTE.next_week 
				THEN CTE.price * 2 * 10
			WHEN CTE.product_name = 'sushi' THEN CTE.price * 2 * 10
			ELSE CTE.price * 1 * 10
		    END
			) AS points
	FROM CTE 
	GROUP BY CTE.customer_id
```
| customer_id   |  points |
|-------------- |---------|
|      A        |   1370  |
|      B        |    820  |
