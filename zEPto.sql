WITH 
    sales_metrics AS (
        SELECT 
            fat_content,
            item_type,
            outlet_name,
            outlet_establishment,
            outlet_size,
            outlet_location,
            outlet_type,
            SUM(total_sales) AS total_sales,
            AVG(average_sales) AS average_sales,
            SUM(number_of_items) AS total_items,
            AVG(average_rating) AS average_rating
        FROM sales_data
        GROUP BY fat_content, item_type, outlet_name, outlet_establishment, outlet_size, outlet_location, outlet_type
    ),
    
    total_sales_by_fat_content AS (
        SELECT 
            fat_content,
            total_sales,
            average_sales,
            total_items,
            average_rating,
            ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS sales_rank
        FROM sales_metrics
        GROUP BY fat_content, total_sales, average_sales, total_items, average_rating
    ),
    
    total_sales_by_item_type AS (
        SELECT 
            item_type,
            SUM(total_sales) AS total_sales,
            AVG(average_sales) AS average_sales,
            SUM(total_items) AS total_items,
            AVG(average_rating) AS average_rating,
            ROW_NUMBER() OVER (ORDER BY SUM(total_sales) DESC) AS item_rank
        FROM sales_metrics
        GROUP BY item_type
    ),
    
    fat_content_by_outlet AS (
        SELECT 
            outlet_name,
            fat_content,
            SUM(total_sales) AS total_sales,
            AVG(average_sales) AS average_sales,
            SUM(total_items) AS total_items,
            AVG(average_rating) AS average_rating,
            ROW_NUMBER() OVER (PARTITION BY outlet_name ORDER BY SUM(total_sales) DESC) AS outlet_rank
        FROM sales_metrics
        GROUP BY outlet_name, fat_content
    ),
    
    total_sales_by_outlet_establishment AS (
        SELECT 
            outlet_establishment,
            SUM(total_sales) AS total_sales,
            ROW_NUMBER() OVER (ORDER BY SUM(total_sales) DESC) AS establishment_rank
        FROM sales_metrics
        GROUP BY outlet_establishment
    ),
    
    sales_by_outlet_size AS (
        SELECT 
            outlet_size,
            SUM(total_sales) AS total_sales,
            ROW_NUMBER() OVER (ORDER BY SUM(total_sales) DESC) AS size_rank
        FROM sales_metrics
        GROUP BY outlet_size
    ),
    
    sales_by_outlet_location AS (
        SELECT 
            outlet_location,
            SUM(total_sales) AS total_sales,
            ROW_NUMBER() OVER (ORDER BY SUM(total_sales) DESC) AS location_rank
        FROM sales_metrics
        GROUP BY outlet_location
    ),
    
    all_metrics_by_outlet_type AS (
        SELECT 
            outlet_type,
            SUM(total_sales) AS total_sales,
            AVG(average_sales) AS average_sales,
            SUM(total_items) AS total_items,
            AVG(average_rating) AS average_rating,
            ROW_NUMBER() OVER (ORDER BY SUM(total_sales) DESC) AS type_rank
        FROM sales_metrics
        GROUP BY outlet_type
    )

-- Final output combining all metrics
SELECT 
    'Total Sales by Fat Content' AS metric_type,
    fat_content, total_sales, average_sales, total_items, average_rating
FROM total_sales_by_fat_content

UNION ALL

SELECT 
    'Total Sales by Item Type' AS metric_type,
    item_type, total_sales, average_sales, total_items, average_rating
FROM total_sales_by_item_type

UNION ALL

SELECT 
    'Fat Content by Outlet' AS metric_type,
    CONCAT(outlet_name, ' - ', fat_content) AS fat_content_info, total_sales, average_sales, total_items, average_rating
FROM fat_content_by_outlet

UNION ALL

SELECT 
    'Total Sales by Outlet Establishment' AS metric_type,
    outlet_establishment, total_sales, NULL AS average_sales, NULL AS total_items, NULL AS average_rating
FROM total_sales_by_outlet_establishment

UNION ALL

SELECT 
    'Sales by Outlet Size' AS metric_type,
    outlet_size, total_sales, NULL AS average_sales, NULL AS total_items, NULL AS average_rating
FROM sales_by_outlet_size

UNION ALL

SELECT 
    'Sales by Outlet Location' AS metric_type,
    outlet_location, total_sales, NULL AS average_sales, NULL AS total_items, NULL AS average_rating
FROM sales_by_outlet_location

UNION ALL

SELECT 
    'All Metrics by Outlet Type' AS metric_type,
    outlet_type, total_sales, average_sales, total_items, average_rating
FROM all_metrics_by_outlet_type;
