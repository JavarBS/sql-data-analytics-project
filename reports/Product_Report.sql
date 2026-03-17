/* Product Report 
---------------------------------------------------------------------------------------
Purpose: This report consolidates key product metrics and behaviors.  

Highlights:
    1. Gathers essential fields such as product name, categor, subcategory, and cost.
    2. Segments products by revenye to identify High-Performers, Mid_range, or Low-Performers.
    3. Aggeregates product-level metrics:
        - total sales
        - total orders
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valube KPIs:
        - Recency (months since last sale)
        - average order revenue (AOR) 
        - average monthly revenue (AMR)
--------------------------------------------------------------------------------------*/
Create view gold.report_products as
With base_query as (
-- 1) Base Query: Retrieve core columns from table
Select
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
Where order_date is not null
),

product_aggregation as (
    -- 2) Product Aggreagations: Summarizes Key metrics at the product level
Select
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    (date_part('year', age(max(order_date), min(order_date))) * 12 +
    date_part('month', age(max(order_date), min(order_date))))::int as lifespan,
    max(order_date) as last_sale_date,
    count(distinct order_number) as total_orders,
    count(distinct customer_key) as total_customers,
    sum(sales_amount) as total_sales,
    sum(quantity) as total_quantity,
    round(avg(cast(sales_amount as numeric) / nullif(quantity, 0)),1) as avg_selling_price
from base_query
group by product_key, product_name, category, subcategory, cost
)

-- 3) Final Query: Combines all product results into one output
------------------------------------------------------------------------------------------------
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    extract(year from age(current_date, last_sale_date)) * 12 +
    extract(month from age(current_date, last_sale_date)) as recency_in_months,
    case
        when total_sales > 50000 then 'High-Performer'
        when total_sales >= 10000 then 'Mid-Range'
        else 'Low-Performer'
    end as product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Compute average order revenue (AOR)
    case
        when total_orders = 0 then 0
        else total_sales / total_orders
    end as avg_order_revenue,
    -- Avegarge Monthly Revenue
    case when lifespan = 0 then total_sales
    else total_sales / lifespan
    end as avg_monthly_revenue
from product_aggregation;