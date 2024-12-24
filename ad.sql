-- FIRST QUESTION ANSWER

select city_id, count(trip_id) as total_trip,
sum(fare_amount) as amount , sum(distance_travelled_km) as total_dis,
sum(fare_amount)/ sum(distance_travelled_km) as avg_fare_par_km,
sum(fare_amount)/count(trip_id) as avg_fare_par_trip
from fact_trips
group by city_id

select count(trip_id) as overall_trip
from fact_trips

select city_name from dim_city
-------MAIN QUERY-------------
select dc.city_name,city_data.total_trip,
city_data.avg_fare_par_km as avg_fare_par_km,
city_data.avg_fare_par_trip as avg_fare_par_trip,
ROUND((city_data.total_trip*100.0/overall_data.overall_trip),2) as pct_contribution
from
	(select city_id, count(trip_id) as total_trip,
	sum(fare_amount) as amount , sum(distance_travelled_km) as total_dis,  
	sum(fare_amount)/ sum(distance_travelled_km) as avg_fare_par_km,
	sum(fare_amount)/count(trip_id) as avg_fare_par_trip
	from fact_trips															------SUB QUERY------
	group by city_id)city_data
	JOIN dim_city dc ON city_data.city_id = dc.city_id
    cross join(   
	  select count(trip_id) as overall_trip
      from fact_trips) overall_data
	  ORDER BY pct_contribution DESC
	  
--- SECOND QUESTION ANSWER

select actual_data.city_id,
       dim_city.city_name,
	   dim_date.month_name,
	   actual_data.month_start,
	   actual_data.actual_trip,
	   mt.total_target_trips,
	   case
	   		when actual_data.actual_trip > mt.total_target_trips then 'Above Trips' else 'Below Trips'
			end as performance_status,
			(actual_data.actual_trip - mt.total_target_trips)*100/mt.total_target_trips as pct_difference
   from (select city_id,
		DATE_TRUNC('month',date) as month_start,
		count(trip_id) as actual_trip
        from fact_trips
        group by city_id,DATE_TRUNC('month',date) )actual_data      -------SUB QUERY--------
        JOIN dim_city on actual_data.city_id = dim_city.city_id
        JOIN dim_date on actual_data.month_start = dim_date.start_of_month
		JOIN temp_monthly_target_trips mt on actual_data.city_id = mt.city_id and actual_data.month_start = mt.month
		order by pct_difference desc				----ORDER BY USE ONE AT A TIME ------
		order by dim_date.month_name,dim_city.city_name
		
		select city_id,
		DATE_TRUNC('month',date) as month_start,
		count(trip_id) as actual_trip
        from fact_trips
        group by city_id,DATE_TRUNC('month',date)


----- create temp_monthly_target_trips table for solving second question
select * from temp_monthly_target_trips


CREATE TABLE temp_monthly_target_trips (
	month DATE NOT NULL,
	city_id VARCHAR(5) NOT NULL,
	total_target_trips INT,
	PRIMARY KEY (month , city_id)
);

INSERT INTO temp_monthly_target_trips
 VALUES ('2024-01-01','AP01',4500),
 ('2024-01-01','CH01',7000),
 ('2024-01-01','GJ01',9000),
 ('2024-01-01','GJ02',6000),
 ('2024-01-01','KA01',2000),
 ('2024-01-01','KL01',7500),
 ('2024-01-01','MP01',7000),
 ('2024-01-01','RJ01',13000),
 ('2024-01-01','TN01',3500),
 ('2024-01-01','UP01',13000),
 ('2024-02-01','AP01',4500),
 ('2024-02-01','CH01',7000),
 ('2024-02-01','GJ01',9000),
 ('2024-02-01','GJ02',6000),
 ('2024-02-01','KA01',2000),
 ('2024-02-01','KL01',7500),
 ('2024-02-01','MP01',7000),
 ('2024-02-01','RJ01',13000),
 ('2024-02-01','TN01',3500),
 ('2024-02-01','UP01',13000),
 ('2024-03-01','AP01',4500),
 ('2024-03-01','CH01',7000),
 ('2024-03-01','GJ01',9000),
 ('2024-03-01','GJ02',6000),
 ('2024-03-01','KA01',2000),
 ('2024-03-01','KL01',7500),
 ('2024-03-01','MP01',7000),
 ('2024-03-01','RJ01',13000),
 ('2024-03-01','TN01',3500),
 ('2024-03-01','UP01',13000),
 ('2024-04-01','AP01',5000),
 ('2024-04-01','CH01',6000),
 ('2024-04-01','GJ01',10000),
 ('2024-04-01','GJ02',6500),
 ('2024-04-01','KA01',2500),
 ('2024-04-01','KL01',9000),
 ('2024-04-01','MP01',7500),
 ('2024-04-01','RJ01',9500),
 ('2024-04-01','TN01',3500),
 ('2024-04-01','UP01',11000),
 ('2024-05-01','AP01',5000),
 ('2024-05-01','CH01',6000),
 ('2024-05-01','GJ01',10000),
 ('2024-05-01','GJ02',6500),
 ('2024-05-01','KA01',2500),
 ('2024-05-01','KL01',9000),
 ('2024-05-01','MP01',7500),
 ('2024-05-01','RJ01',9500),
 ('2024-05-01','TN01',3500),
 ('2024-05-01','UP01',11000),
 ('2024-06-01','AP01',5000),
 ('2024-06-01','CH01',6000),
 ('2024-06-01','GJ01',10000),
 ('2024-06-01','GJ02',6500),
 ('2024-06-01','KA01',2500),
 ('2024-06-01','KL01',9000),
 ('2024-06-01','MP01',7500),
 ('2024-06-01','RJ01',9500),
 ('2024-06-01','TN01',3500),
 ('2024-06-01','UP01',11000);

----------------THIRD QUESTION ANSWER---------------------

	select dc.city_name,
		   ROUND(MAX(CASE WHEN dr.trip_count = '2-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "2-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '3-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "3-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '4-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "4-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '5-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "5-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '6-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "6-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '7-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "7-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '8-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "8-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '9-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "9-Trips",
		   ROUND(MAX(CASE WHEN dr.trip_count = '10-Trips' THEN (dr.repeat_passenger_count * 100.0 / total_passenger.total_repeat_passenger) ELSE 0 END),2) AS "10-Trips"
	from dim_repeat_trip_distribution dr
	join ( select city_id, sum(repeat_passenger_count) as total_repeat_passenger from dim_repeat_trip_distribution
		 group by city_id )total_passenger
		 on dr.city_id = total_passenger.city_id
		 join dim_city dc on dr.city_id = dc.city_id
		 group by dc.city_name
		 ORDER BY dc.city_name;


----- Fourth Question ----------
		
	select city_name,
				total_new_passenger,
		case 
			when rank_desc <=3 then 'Top 3'
			when rank_asc <=3 then 'Bottom 3'
		ELSE NULL
	END AS city_category
		from
		(
		select total_passenger.city_id,
		total_passenger.total_new_passenger,
		dim_city.city_name,
		RANK() 	over(order by total_passenger.total_new_passenger desc) as rank_desc,
		RANK()	over (order by total_passenger.total_new_passenger asc) as rank_asc
from (
 select city_id, sum(new_passenger) as total_new_passenger
	from fact_passenger_summary
	group by city_id
	) total_passenger
join dim_city on total_passenger.city_id = dim_city.city_id ) ranked_cities
where rank_desc <=3 or rank_asc<= 3
order by city_category desc;


------fifth Question----------

 select dim_city.city_name,
 	dim_date.month_name,
	city_month_revenue.total_revenue,
	(city_month_revenue.total_revenue*100/city_month_revenue.total_revenue) as percentage_contribution
  from(select city_id, 
  DATE_TRUNC('month',date) as month_start,
  sum(fare_amount) as total_revenue,
  rank() over (partition by city_id order by sum(fare_amount) desc) as revenue_rank
  from fact_trips
  group by city_id, date_trunc('month',date))city_month_revenue
  join dim_city on city_month_revenue.city_id = dim_city.city_id
  join dim_date on city_month_revenue.month_start = dim_date.start_of_month
  where city_month_revenue.revenue_rank = 1
  order by city_name
  
  
SELECT
    dc.city_name, -- City name from dim_city
    dd.month_name AS highest_revenue_month, -- Month name from dim_date
    city_month_revenue.revenue, -- Highest revenue for the city
    ROUND((city_month_revenue.revenue * 100.0 / city_total_revenue.total_revenue), 2) AS percentage_contribution
FROM (
    -- Calculate revenue for each city and month
    SELECT
        ft.city_id,
        DATE_TRUNC('month', ft.date) AS month_start,
        SUM(ft.fare_amount) AS revenue,
        RANK() OVER (PARTITION BY ft.city_id ORDER BY SUM(ft.fare_amount) DESC) AS revenue_rank
    FROM fact_trips ft
    GROUP BY ft.city_id, DATE_TRUNC('month', ft.date)
) city_month_revenue
JOIN (
    -- Calculate total revenue for each city
    SELECT
        ft.city_id,
        SUM(ft.fare_amount) AS total_revenue
    FROM fact_trips ft
    GROUP BY ft.city_id
) city_total_revenue
ON city_month_revenue.city_id = city_total_revenue.city_id
JOIN dim_city dc ON city_month_revenue.city_id = dc.city_id
JOIN dim_date dd ON city_month_revenue.month_start = dd.start_of_month
WHERE city_month_revenue.revenue_rank = 1 -- Filter for the highest revenue month in each city
ORDER BY city_name;


-----------sixth question-----------
SELECT
    dc.city_name,
    dd.month_name AS month,
    monthly_data.total_passenger,
    monthly_data.repeat_passenger,
    monthly_data.monthly_repeat_passenger_rate,
    city_data.city_repeat_passenger_rate
FROM (
    -- Monthly metrics
    SELECT
        fps.city_id,
        fps.month,
        SUM(fps.total_passenger) AS total_passenger,
        SUM(fps.repeat_passenger) AS repeat_passenger,
        ROUND((SUM(fps.repeat_passenger) * 100.0 / NULLIF(SUM(fps.total_passenger), 0)), 2) AS monthly_repeat_passenger_rate
    FROM fact_passenger_summary fps
    GROUP BY fps.city_id, fps.month
) monthly_data
JOIN (
    -- City-wide metrics
    SELECT
        fps.city_id,
        SUM(fps.total_passenger) AS total_passenger,
        SUM(fps.repeat_passenger) AS repeat_passenger,
        ROUND((SUM(fps.repeat_passenger) * 100.0 / NULLIF(SUM(fps.total_passenger), 0)), 2) AS city_repeat_passenger_rate
    FROM fact_passenger_summary fps
    GROUP BY fps.city_id
) city_data
ON monthly_data.city_id = city_data.city_id
JOIN dim_city dc ON monthly_data.city_id = dc.city_id
JOIN dim_date dd ON monthly_data.month = dd.start_of_month
ORDER BY city_repeat_passenger_rate desc;
