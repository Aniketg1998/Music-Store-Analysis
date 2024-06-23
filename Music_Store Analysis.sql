
--Who is the senior most employee based on job title? 
select * from employee
order by levels desc
limit 1;

--Which countries have the most Invoices? 
select count(*), billing_country from invoice
group by billing_country
order by count(*) desc
limit 1;

--What are top 3 values of total invoice? 
select invoice_id, total from invoice
order by total desc
limit 3;
 
--Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 
select billing_city, sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1;


--Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select cu.first_name, cu.last_name, sum(i.total) from customer cu join invoice i on cu.customer_id=i.customer_id
group by cu.first_name, cu.last_name
order by sum(i.total) desc
limit 1
 

--Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 
select DISTINCT cu.email, cu.first_name, cu.last_name from customer cu
JOIN invoice i on cu.customer_id=i.customer_id
JOIN invoice_line il on i.invoice_id=il.invoice_id
JOIN track tr on tr.track_id=il.track_id
JOIN genre ge on ge.genre_id= tr.genre_id
WHERE ge.name='Rock'
ORDER BY cu.email

--Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands 
SELECT a.artist_id, a.name,COUNT(a.artist_id) AS num_of_songs from artist a 
JOIN album al on al.artist_id=a.artist_id
JOIN track tr on tr.album_id=al.album_id
JOIN genre ge on ge.genre_id=tr.genre_id
WHERE ge.name='Rock'
GROUP BY a.artist_id
ORDER BY num_of_songs desc
LIMIT 10;


--Return all the track names that have a song length longer than the average song length.  Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	select AVG(milliseconds) from track 
)
ORDER BY milliseconds desc;


--Find how much amount spent by each customer on top selling artist? Write a query to return customer name, artist name and total spent 
with top_selling_artist AS (
	SELECT a.artist_id as artist_id, a.name as artist_name, SUM(il.unit_price * il.quantity) as total_spent
	FROM artist a
	JOIN album al on al.artist_id=a.artist_id
	JOIN track tr on tr.album_id=al.album_id
	JOIN invoice_line il on il.track_id=tr.track_id
	group by a.artist_id
	order by total_spent desc
	limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, tsa.artist_name, SUM(il.unit_price * il.quantity) as total_spent 
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN top_selling_artist tsa ON tsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, tsa.artist_name
ORDER BY c.customer_id;


--We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres 
WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	RANK() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS Rank_num 
    FROM invoice_line il
	JOIN invoice i ON i.invoice_id = il.invoice_id
	JOIN customer c ON c.customer_id = i.customer_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY c.country, g.name, g.genre_id
	ORDER BY c.country ASC, count(il.quantity) DESC
)
SELECT country, name, purchases FROM popular_genre WHERE Rank_num <= 1

	
--Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
WITH RECURSIVE 
	customter_spend AS (
		SELECT customer.customer_id,first_name,last_name, country,SUM(total) AS total_spend
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name, country
		ORDER BY 2,3 DESC),

	max_spending AS(
		SELECT country, MAX(total_spend) AS max_spending
		FROM customter_spend
		GROUP BY country)

SELECT cs.country, cs.first_name, cs.last_name, cs.total_spend, cs.customer_id
FROM customter_spend cs
JOIN max_spending ms
ON cs.country = ms.country
WHERE cs.total_spend = ms.max_spending
ORDER BY cs.country;
