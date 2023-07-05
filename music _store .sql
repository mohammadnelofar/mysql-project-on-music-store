create database dataset;
use dataset;
CREATE TABLE employee(
employee_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
last_name TEXT,
first_name TEXT ,
title TEXT,
reports_to INT DEFAULT NULL,
levels TEXT ,
birthdate TEXT,
hire_date TEXT,
address TEXT,
city TEXT,
state TEXT,
country TEXT,
postal_code TEXT,
phone TEXT,
fax TEXT,
email TEXT);



select * from employee ;

CREATE TABLE customer(
customer_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
first_name TEXT,
last_name TEXT,
company TEXT,
address TEXT,
city TEXT,
state TEXT,
country TEXT,
postal_code TEXT,
phone TEXT,
fax TEXT,
email TEXT,
support_rep_id INT,
FOREIGN KEY(support_rep_id)
REFERENCES employee(employee_id));

select * from customer;



create table invoice(
invoice_id int auto_increment primary key NOT NULL,
customer_id INT NOT NULL,
invoice_date TEXT,
billing_address TEXT,
billing_city TEXT,
billing_state TEXT,
billing_country TEXT,
billing_postal_code TEXT,
total FLOAT,
FOREIGN KEY(customer_id)
REFERENCES customer(customer_id));

select * from invoice;

create table artist(
artist_id int auto_increment primary key NOT NULL,
name TEXT);
select count(*)from artist;

create table album(
album_id int auto_increment primary key NOT NULL,
title TEXT,
artist_id  INT ,
FOREIGN KEY(artist_id)
REFERENCES artist(artist_id));

select count(*) from album;


create table media_type(
media_type_id int auto_increment primary key NOT NULL,
name TEXT );
 
 select count( * )from media_type;
create table genre(
genre_id int auto_increment primary key NOT NULL,
name TEXT);
select  * from genre;
DROP TABLE track;

create table track(
track_id int  NOT NULL auto_increment primary key,
name varchar(200),
album_id int,
media_type_id int,
genre_id int,
composer varchar(1000) default null,
milliseconds varchar(100),
bytes varchar(100),
unit_price varchar(100),
foreign key (album_id)
references album(album_id),
foreign key (media_type_id)
references media_type(media_type_id),
foreign key (genre_id)
references genre(genre_id));


 select count(*) from track;
 
 drop table playlist;
 
create table playlist(
playlist_id int auto_increment primary key,
name varchar(100));

select count(*) playlist;

create table playlist_track(
playlist_id int,
track_id  INT,
FOREIGN KEY(playlist_id)
REFERENCES playlist(playlist_id),
foreign key(track_id )
references track(track_id)
);

select count(*) from playlist_track;


create table invoice_line(
invoice_line_id int auto_increment primary key NOT NULL,
invoice_id INT,
track_id INT,
unit_price TEXT,
quantity TEXT,
FOREIGN KEY(invoice_id)
REFERENCES invoice(invoice_id),
FOREIGN KEY(track_id)
REFERENCES track(track_id));

select count(*) from invoice_line;

-- alter the table where values are null

update employee
set reports_to = Null 
where employee_id = 9;


select * FROM employee;
alter table employee
add constraint fk_reports_to
foreign key (reports_to)
references employee(employee_id);

select * from  employee;


----- ==================================================================EASY===========================================================================================
-- 1. Who is the senior most employee based on job title?
select max(title) as max_title,concat(first_name,' ',last_name) as employee_name from employee
where title=(select max(title) from employee)
group by employee_name
order by max_title;

-- 2.Which countries have the most Invoices?
select * from invoice;
SELECT count(*) as Invoices ,billing_country
FROM Invoice
GROUP BY billing_country
ORDER BY Invoices desc
limit 5;

-- 3.What are top 3 values of total invoice?
SELECT DISTINCT Total,billing_country
FROM Invoice
ORDER BY Total DESC limit 3;

/* 4.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals*/

select * from invoice;
SELECT  billing_city  as city,sum(total) as max_total 
FROM invoice
group by city
order by max_total DESC limit 1;

/* 5 Who is the best customer? The customer who has spent the most money will be declared the best customer.
 Write a query that returns the person who has spent the most money*/
 select * from customer;
select * from invoice_line;

select * from customer;
select customer.customer_id,concat(customer.first_name,' ',customer.last_name) as customer_name, sum(invoice_line.unit_price*invoice_line.quantity) as most_money
from customer join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
group by customer.customer_id
order by most_money desc;


 ----- ========================================================== MODERATE ===============================================================================================
----- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select distinct customer. email,concat(first_name,' ',last_name) as name,genre.name 
 from customer 
 join invoice on customer.customer_id=invoice.customer_id
 join invoice_line on invoice.invoice_id =invoice_line.invoice_id
 join track on invoice_line.track_id=track.track_id
 join genre on track.genre_id=genre.genre_id
 where genre.name = 'Rock' and customer.email like 'a%'
 order by email Asc;
 
 /*2.Let's invite the artists who have written the most rock music in our dataset.
 Write a query that returns the Artist name and total track count of the top 10 rock bands*/
 
 select *from track;
 SELECT artist.artist_id, artist.name,COUNT(*) AS track_count
 from artist
 join album on artist.artist_id=album.artist_id
 join track on album.album_id=track.album_id
 join genre on track.genre_id=genre.genre_id
 where genre.name='rock'
 group by artist.artist_id
 order by track_count desc limit 10;
 
 /*3.Return all the track names that have a song length longer than the average song length. 
 Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first */
select name,milliseconds from track
where milliseconds>(select avg(milliseconds)from track)
order by milliseconds desc;
-- =================================================================advance==========================================================================
/*1.Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent*/
select * from  customer;
select  distinct concat(customer.first_name,' ',customer.last_name) as customer_name,artist.name as artist_name,sum(invoice_line.unit_price*invoice_line.quantity) as most_money
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by customer.customer_id,artist.artist_id
order by customer_name, artist_name, most_money desc;

/*2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
 Write a query that returns each country along with the top Genre. 
 For countries where the maximum number of purchases is shared return all Genres*/
 
 with Tgen as (select  distinct customer.country ,genre.name as top_genre, sum(invoice_line.quantity)as total_purchase
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice.invoice_id = invoice_line.invoice_id
 join track on invoice_line.track_id= track.track_id
 join genre on track.genre_id = genre.genre_id
 group by customer.country,genre.genre_id
 order by customer.country,total_purchase desc)
 select country,coalesce(max(top_genre),"unknown") as top_gen
 from Tgen 
 group by country;
 
 
 /*3.Write a query that determines the customer that has spent the most on music for each country.
 Write a query that returns the country along with the top customer and how much they spent.
 For countries where the top amount spent is shared, provide all customers who spent this amount */
with tspent as ( select customer.country,concat(customer.first_name," ",customer.last_name) as customer_name,sum(invoice_line.unit_price *invoice_line.quantity) as total_spent
from customer
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice.invoice_id = invoice_line.invoice_id
group by customer.customer_id)
select country,customer_name,total_spent
from tspent
where (country,total_spent)in( select country ,max(total_spent) as maxspent
from tspent
group by country)
order by country;


 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  
  





  
















