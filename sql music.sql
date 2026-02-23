/*/Customers Who Spent the Most Money/*/
alter table customer modify column customer_id int primary key;

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

/*/What is the average customer lifetime value (CLV)?/*/
SELECT 
    AVG(CustomerTotal) AS Avg_Customer_Lifetime_Value
FROM (
    SELECT 
        customer_id,
        SUM(Total) AS CustomerTotal
    FROM invoice
    GROUP BY customer_id
) AS customer_spending;

/*/Repeat vs One-Time Customers/*/
SELECT
    CASE 
        WHEN purchase_count = 1 THEN 'One-Time Purchase'
        ELSE 'Repeat Purchase'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM (
    SELECT 
        customer_id,
        COUNT(invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
) AS purchase_data
GROUP BY customer_type;

/*/Country Generating Most Revenue per Customer/*/
SELECT 
    billing_country,
    SUM(total) / COUNT(DISTINCT customer_id) AS revenue_per_customer
FROM invoice
GROUP BY billing_country
ORDER BY revenue_per_customer DESC;

/*/Customers With No Purchase in Last 6 Months/*/
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer c
LEFT JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MAX(i.invoice_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
       OR MAX(i.invoice_date) IS NULL;
       
/*/Monthly Revenue Trends (Last 2 Years)/*/


SELECT 
    MIN(invoice_date) AS start_date,
    MAX(invoice_date) AS end_date
FROM invoice;

SELECT 
    DATE_FORMAT(invoice_date,'%Y-%m') AS month,
    SUM(Total) AS monthly_revenue
FROM invoice
WHERE invoice_date>= (
    SELECT DATE_SUB(MAX(invoice_date), INTERVAL 2 YEAR)
    FROM invoice
)
GROUP BY month
ORDER BY month;

/*/Average Value of an Invoice (Average Purchase Value)/*/
SELECT 
    AVG(total) AS average_invoice_value
FROM invoice;

/*/Which Payment Methods Are Used Most Frequently?/*/
SELECT 
    PaymentMethod,
    COUNT(*) AS usage_count
FROM invoice
GROUP BY PaymentMethod
ORDER BY usage_count DESC;

show tables;

/*/Revenue Contribution by Each Sales Representative/*/
SELECT 
    e.employee_id,
    CONCAT(e.first_name,' ',e.last_name) AS sales_rep,
    SUM(i.Total) AS total_revenue
FROM employee e
JOIN customer c 
    ON e.employee_id= c.support_rep_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id	, sales_rep
ORDER BY total_revenue DESC;

/*/Peak Sales Months / Quarters/*/
SELECT 
    MONTHNAME(invoice_date) AS month,
    SUM(total) AS revenue
FROM invoice
GROUP BY month
ORDER BY revenue DESC;

/*/Quarterly Sales/*/
SELECT 
    CONCAT('Q', QUARTER(invoice_date)) AS quarter,
    SUM(total) AS revenue
FROM invoice
GROUP BY quarter
ORDER BY revenue DESC;

/*/Which tracks generated the most revenue?/*/
SELECT 
    t.track_id,
    t.Name AS track_name,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
GROUP BY t.track_id, t.Name
ORDER BY total_revenue DESC;

/*/Which albums are most frequently included in purchases?/*/
ALTER TABLE albu
RENAME COLUMN AlbumId TO album_id; 

SELECT 
    a.album_id,
    a.Title AS album_name,
    COUNT(il.invoice_line_id) AS purchase_count
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN albu a
    ON t.album_id= a.album_id
GROUP BY a.album_id, a.Title
ORDER BY purchase_count DESC;

/*/Tracks or Albums Never Purchased/*/
SELECT 
    t.track_id,
    t.Name
FROM track t
LEFT JOIN invoice_line il
    ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

/*/Average Price per Track Across Genres/*/
SELECT 
    g.Name AS genre,
    AVG(t.unit_price) AS avg_price
FROM track t
JOIN genre g 
    ON t.genre_id= g.genre_id
GROUP BY g.Name
ORDER BY avg_price DESC;

/*/Tracks per Genre & Correlation with Sales/*/
SELECT 
    g.Name AS genre,
    COUNT(DISTINCT t.TrackId) AS total_tracks,
    SUM(il.UnitPrice * il.Quantity) AS total_sales
FROM genre g
LEFT JOIN track t 
    ON g.GenreId = t.GenreId
LEFT JOIN invoice_line il 
    ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY total_sales DESC;

/*/Tracks per Genre & Correlation with Sales/*/
SELECT 
    g.Name AS genre,
    COUNT(DISTINCT t.track_id) AS total_tracks,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM genre g
LEFT JOIN track t 
    ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY g.Name
ORDER BY total_sales DESC;

Alter table albu rename column ArtistId to artist_id;
/*/Top 5 Highest-Grossing Artists/*/
SELECT 
    ar.artist_id,
    ar.Name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN albu al 
    ON t.album_id = al.album_id
JOIN artist ar 
    ON al.artist_id = ar.artist_id
GROUP BY ar.artist_id, ar.Name
ORDER BY total_revenue DESC
LIMIT 5;

/*/Most Popular Genres/*/
SELECT 
    g.genre_id,
    g.Name AS genre,
    SUM(il.quantity) AS tracks_sold
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY g.genre_id, g.Name
ORDER BY tracks_sold DESC;

/*/Genres by Total Revenue/*/
SELECT 
    g.genre_id,
    g.Name AS genre,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY g.genre_id, g.Name
ORDER BY total_revenue DESC;

/*/Genre Popularity by Country/*/
SELECT 
    i.billing_country,
    g.Name AS genre,
    SUM(il.quantity) AS tracks_sold
FROM invoice_line il
JOIN invoice i 
    ON il.invoice_id = i.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY i.billing_country, g.Name
ORDER BY i.billing_country, tracks_sold DESC;

/*/. Employee & Operational Efficiency/*/

SELECT 
    e.employee_id,
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(i.total) AS customer_spending
FROM employee e
JOIN customer c 
    ON e.employee_id = c.support_rep_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id, employee_name,
         c.customer_id, customer_name
ORDER BY customer_spending DESC;

/*/What is the average number of customers per employee?/*/
SELECT 
    AVG(customer_count) AS avg_customers_per_employee
FROM (
    SELECT 
        support_rep_id,
        COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY support_rep_id
) AS employee_customers;

/*/Which Employee Regions Bring the Most Revenue?/*/
SELECT 
    e.employee_id,
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    i.billing_country,
    SUM(i.total) AS total_revenue
FROM employee e
JOIN customer c 
    ON e.employee_id = c.support_rep_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id, employee_name, i.billing_country
ORDER BY total_revenue DESC;

/*/Which Countries Have the Highest Number of Customers?/*/
SELECT 
    country,
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY country
ORDER BY total_customers DESC;

/*/Cities with Highest Number of Customers/*/
SELECT 
    city,
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY city
ORDER BY total_customers DESC;

/*/2How Does Revenue Vary by Region (Country)?/*/

SELECT 
    billing_country,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

/*/revenue by city/*/
SELECT 
    billing_city,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC;

/*/Underserved Geographic Regions/*/
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COALESCE(SUM(i.total),0) AS total_revenue,
    ROUND(
        COALESCE(SUM(i.total),0) /
        COUNT(DISTINCT c.customer_id), 2
    ) AS revenue_per_customer
FROM customer c
LEFT JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer ASC;

/*/ How many purchases each customer makes./*/
SELECT 
    purchase_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT 
        customer_id,
        COUNT(invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
) AS purchase_data
GROUP BY purchase_count
ORDER BY purchase_count;

/*/Average Time Between Customer Purchases/*/
SELECT 
    AVG(days_between) AS avg_days_between_purchases
FROM (
    SELECT 
        customer_id,
        DATEDIFF(
            invoice_date,
            LAG(invoice_date) OVER (
                PARTITION BY customer_id
                ORDER BY invoice_date
            )
        ) AS days_between
    FROM invoice
) t
WHERE days_between IS NOT NULL;

/*/% Customers Buying From More Than One Genre/*/
SELECT 
    ROUND(
        100 * SUM(CASE WHEN genre_count > 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS percent_multi_genre_customers
FROM (
    SELECT 
        i.customer_id,
        COUNT(DISTINCT t.genre_id) AS genre_count
    FROM invoice i
JOIN invoice_line il 
        ON i.invoice_id = il.invoice_id
JOIN track t 
        ON il.track_id = t.track_id
    GROUP BY i.customer_id
) AS genre_data;

/*/Most Common Track Combinations Purchased Togethe/*/
SELECT 
    il1.track_id AS track_1,
    il2.track_id AS track_2,
    COUNT(*) AS times_bought_together
FROM invoice_line il1
JOIN invoice_line il2
    ON il1.invoice_id = il2.invoice_id
   AND il1.track_id < il2.track_id
GROUP BY track_1, track_2
ORDER BY times_bought_together DESC
LIMIT 10;

/*/Pricing Patterns vs Sales/*/
SELECT 
    unit_price,
    SUM(quantity) AS total_tracks_sold
FROM invoice_line
GROUP BY unit_price
ORDER BY unit_price;

/*/Media Types Increasing or Declining in Usage/*/
SELECT 
    mt.Name AS media_type,
    YEAR(i.invoice_date) AS year,
    SUM(il.quantity) AS total_sales
FROM invoice_line il
JOIN invoice i 
    ON il.invoice_id = i.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN media_type mt 
    ON t.media_type_id = mt.media_type_id
GROUP BY media_type, year
ORDER BY media_type, year;

/*/-----------------------------------------------------------------------------------------/*/
/*/Q1. Who is the senior most employee based on job title?/*/
SELECT 
    employee_id,
    first_name,
    last_name,
    Title
FROM employee
ORDER BY Title DESC
LIMIT 1;

/*/Q2. Which Countries Have the Most Invoices?/*/
SELECT 
billing_country,   COUNT(invoice_id) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

/*/Q3. Top 3 Values of Total Invoice/*/
SELECT 
    invoice_id,
    total
FROM invoice
ORDER BY Total DESC
LIMIT 3;

/*/Q4. Which City Has the Best Customers?/*/
SELECT 
    billing_city,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 1;

/*/Q5. Who is the Best Customer?/*/
SELECT 
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(i.Total) AS total_spent
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 1;

/*/ Q6. Rock Music Listeners/*/
SELECT DISTINCT
    c.email,
    c.first_name,
    c.last_name,
    g.Name AS Genre
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE g.Name = 'Rock'
ORDER BY c.email;

/*/Q7. Top 10 Artists Who Wrote Most Rock Music/*/
SELECT 
    ar.Name AS artist_name,
    COUNT(t.track_id) AS total_rock_tracks
FROM track t
JOIN albu al 
    ON t.album_id = al.	album_id
JOIN artist ar 
    ON al.artist_id = ar.artist_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE g.Name = 'Rock'
GROUP BY ar.Name
ORDER BY total_rock_tracks DESC
LIMIT 10;

/*/Q8. Tracks Longer Than Average Song Length/*/
SELECT 
    Name,
    milliseconds
FROM track
WHERE milliseconds > (
        SELECT AVG(milliseconds)
        FROM track
)
ORDER BY Milliseconds DESC;

/*/Q9. Amount Spent by Each Customer on Artists/*/
SELECT 
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    ar.Name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN albu al 
    ON t.album_id = al.album_id
JOIN artist ar 
    ON al.artist_id = ar.artist_id
GROUP BY customer_name, artist_name
ORDER BY total_spent DESC;
/*/Q10. Most Popular Genre for Each Country/*/
WITH genre_purchases AS (
    SELECT 
        i.billing_country AS country,
        g.Name AS genre,
        COUNT(il.invoice_line_id) AS purchases
    FROM invoice_line il
    JOIN invoice i 
        ON il.invoice_id = i.invoice_id
    JOIN track t 
        ON il.track_id = t.track_id
    JOIN genre g 
        ON t.genre_id = g.genre_id
    GROUP BY country, genre
),
ranked_genres AS (
    SELECT *,
           RANK() OVER(
               PARTITION BY country
               ORDER BY purchases DESC
           ) AS rnk
    FROM genre_purchases
)
SELECT country, genre, purchases
FROM ranked_genres
WHERE rnk = 1
ORDER BY country;

/*/Q11. Top Spending Customer per Country (Include Ties)/*/

WITH customer_spending AS (
    SELECT 
        i. billing_country AS country,
        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY country, c.customer_id, customer_name
),
ranked_customers AS (
    SELECT *,
           RANK() OVER(
               PARTITION BY country
               ORDER BY total_spent DESC
           ) AS rnk
    FROM customer_spending
)
SELECT country, customer_name, total_spent
FROM ranked_customers
WHERE rnk = 1
ORDER BY country;

/*/Q12. Most Popular Artists/*/
SELECT 
    ar.Name AS artist_name,
    SUM(il.quantity) AS total_tracks_sold
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN albu al 
    ON t.album_id = al.album_id
JOIN artist ar 
    ON al.artist_id = ar.artist_id
GROUP BY ar.Name
ORDER BY total_tracks_sold DESC;

/*/Q13. Most Popular Song/*/
SELECT 
    t.Name AS track_name,
    SUM(il.quantity) AS total_purchases
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
GROUP BY t.Name
ORDER BY total_purchases DESC
LIMIT 1;

/*/Q14. Average Prices of Different Types of Music/*/
SELECT 
    mt.Name AS media_type,
    AVG(t.unit_price) AS avg_price
FROM track t
JOIN media_type mt 
    ON t.media_type_id = mt.media_type_id
GROUP BY mt.Name
ORDER BY avg_price DESC;

/*/Q15. Most Popular Countries for Music Purchases/*/
SELECT 
    billing_country,
    COUNT(invoice_id) AS total_purchases,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;