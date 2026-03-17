/* Customer Report 
--------------------------------------------------------------------------------------
Purpose:
    - This report consolidates key customer metrics and behaviors.
Highlights:
    1. Gathers essentail fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders 
        - total sales 
        - total quantity purchased 
        - total products 
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - Recency (months since last order)
        - average order value 
        - average monthly spend
--------------------------------------------------------------------------------------*/
create view gold.report_customers as
With base_query as (
-- 1) Base Query: Retrieve core columns from table
SELECT
f.order_number, f.product_key, f.order_date, f.sales_amount, f.quantity,
c.customer_key, c.customer_number, concat(c.first_name, ' ', c.last_name) as customer_name, 
extract(year from age(current_date, c.birthdate)) as customer_age
from gold.fact_sales f 
left join gold.dim_customers c
on f.customer_key = c.customer_key
where order_date is not NULL)

, customer_aggregation as (

-- 2) Customer Aggregation: Aggregate metrics at the customer level
Select 
    customer_key, customer_number, customer_name, customer_age,
    count(distinct order_number) as total_orders,
    sum(sales_amount) as total_sales,
    sum(quantity) as total_quantity,
    count(distinct product_key) as total_products,
    max(order_date) as last_order_date,
    (date_part('year', age(max(order_date), min(order_date))) * 12 +
    date_part('month', age(max(order_date), min(order_date))))::int as lifespan
from base_query
group by
 customer_key, customer_number, customer_name, customer_age
)

select 
    customer_key, customer_number, customer_name, customer_age,
    case
    when customer_age < 20 then 'Under 20'
    when customer_age between 20 and 29 then '20-29'
    when customer_age between 30 and 39 then '30-39'
    when customer_age between 40 and 49 then '40-49'
    else '50+'
    end as age_group,
    case
        when lifespan >= 12 AND total_sales > 5000 then 'VIP'
        when lifespan >= 12 AND total_sales <= 5000 then 'Regular'
        else 'New'
    end as customer_segment,
    last_order_date,
    (date_part('year', age(current_date, last_order_date)) * 12 +
    date_part('month', age(current_date, last_order_date)))::int as recency_months,
    total_orders, total_sales, total_quantity, total_products, lifespan,
    -- Compute average order value (AVO)
    case
        when total_orders = 0 then 0
        else total_sales / total_orders
    end as average_order_value,
    -- Compute average monthly spend (AMS)
    case when lifespan = 0 then total_sales
    else total_sales / lifespan
    end as average_monthly_spend
from customer_aggregation