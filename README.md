# Case-Study 1 Danny's Diner
<img src='https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft%20sql%20server&logoColor=white)'/>

The following are my solutions to the Case Study 2 Pizza Runner questions in 
[Danny Ma's Serious SQL course](https://www.datawithdanny.com/ "Data With Danny")
<br/>
<br/>
Danny has shared with you 3 key datasets for this case study :
[Data Set](https://github.com/Shailesh-python/Case_Study_1_Dannys_Diner/blob/main/Data%20And%20Tables)
<br/>
- `sales`
- `menu`
- `members`

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


## Bonus Questions

## [Question #11](#case-study-questions)
> Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL Recreate the following table output using the available data.

The trick for this question is to try and understand what is going on from the results and work backwards - something that we’ve covered in a ton of depth throughout the 2 extended case studies already in this course!

If we view that last `member` column - we can see that there is `N` and `Y` values for each customer. What might this relate to? Does it have something with each customer’s join date?

Additionally - be sure to check the order of this table - what do you notice about the sorting of rows?
```sql
SELECT 
	s.customer_id,
	s.order_date,
	m.product_name,
	m.price,
	CASE WHEN mb.join_date >= s.order_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales S
INNER JOIN dannys_diner.members MB
	ON S.customer_id = MB.customer_id
INNER JOIN dannys_diner.menu M
	ON S.product_id = M.product_id;
```
![image](https://github.com/Shailesh-python/Case_Study_1_Dannys_Diner/blob/main/Question_11.jpg)

## [Question #12](#case-study-questions)
> Danny also requires further information about the `ranking` of customer products, but he purposely does not need the `ranking` for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

This final question is actually slightly difficult so be sure to take this one slowly!

This was based off a real work problem I was helping one of my mentees with - so it’s really safe to say that these types of problems really do occur at work!

The first thing to note is how similar this table is to the output from question 11.

The next thing is to try and understand why there are `null` values for the `ranking` column - do you notice how they all seem to line up with the `member` column values?

This scenario should instantly scream `CASE WHEN` at you once you’ve seen this a few times in the wild - but how do we perform this operation with some sort of ordering window function?

Also take special note of the largest values for the ranking column - this has a huge impact on which specific ordering window function to use. Remember the differences between `RANK`, `ROW_NUMBER` and `DENSE_RANK` - which one should we use in this situation?
```sql
WITH CTE AS
(
SELECT
	s.customer_id,
	s.order_date,
	mn.product_name,
	mn.price,
	IIF(s.order_date >= mb.join_date,'Y','N') AS member
FROM dannys_diner.sales s 
LEFT JOIN dannys_diner.members mb
	ON s.customer_id = mb.customer_id
LEFT JOIN dannys_diner.menu mn
	ON s.product_id = mn.product_id
)
	SELECT 
		*,
		CASE
			WHEN member = 'N' THEN Null
			ELSE RANK() Over (PARTITION BY CTE.customer_id, CTE.member ORDER BY CTE.Price DESC, order_date ) 
		END AS ranking
	FROM CTE
```
![image](https://github.com/Shailesh-python/Case_Study_1_Dannys_Diner/blob/main/Question_12.jpg)
