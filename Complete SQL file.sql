USE ecommerce_analytics;

-- 1. TABLE ROW COUNTS
SHOW TABLES;
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;

-- 2. DUPLICATE PRIMARY IDENTIFIER CHECKS (expected: 0)
SELECT 'customers.customer_id' AS check_name, COUNT(*) AS duplicate_groups
FROM (SELECT customer_id FROM customers GROUP BY customer_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'orders.order_id', COUNT(*)
FROM (SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'products.product_id', COUNT(*)
FROM (SELECT product_id FROM products GROUP BY product_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'sellers.seller_id', COUNT(*)
FROM (SELECT seller_id FROM sellers GROUP BY seller_id HAVING COUNT(*) > 1) d;

-- 3. FOREIGN KEY / ORPHAN CHECKS (expected: 0)
SELECT 'orders -> customers' AS relationship_name, COUNT(*) AS invalid_rows
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'order_items -> orders', COUNT(*)
FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'order_items -> products', COUNT(*)
FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items -> sellers', COUNT(*)
FROM order_items oi LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 4. NULL / MISSING VALUE PROFILE
SELECT 'orders' AS table_name,
       SUM(order_approved_at IS NULL) AS missing_field_1,
       SUM(order_delivered_customer_date IS NULL) AS missing_field_2
FROM orders
UNION ALL
SELECT 'products', SUM(product_category_name IS NULL), SUM(product_weight_g IS NULL)
FROM products
UNION ALL
SELECT 'reviews', SUM(review_comment_title IS NULL), SUM(review_comment_message IS NULL)
FROM reviews;

-- Missing order dates by status
SELECT order_status, COUNT(*) AS total_orders,
       SUM(order_approved_at IS NULL) AS missing_approval_dates,
       SUM(order_delivered_customer_date IS NULL) AS missing_delivery_dates
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Payment quality profile
SELECT COUNT(*) AS payment_records,
       SUM(payment_value IS NULL) AS null_values,
       SUM(payment_value = 0) AS zero_values,
       SUM(payment_value < 0) AS negative_values,
       MIN(payment_value) AS minimum_value,
       MAX(payment_value) AS maximum_value,
       ROUND(AVG(payment_value), 2) AS average_value
FROM payments;

-- Inspect zero-value payments; do not delete automatically
SELECT p.order_id, p.payment_sequential, p.payment_type,
       p.payment_installments, p.payment_value, o.order_status
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE p.payment_value = 0
ORDER BY p.order_id, p.payment_sequential;

-- 5. PAYMENT VS ORDER ITEM RECONCILIATION
-- Aggregate each table separately to avoid many-to-many row multiplication.
WITH payment_totals AS (
    SELECT order_id, SUM(payment_value) AS total_payment
    FROM payments GROUP BY order_id
),
item_totals AS (
    SELECT order_id, SUM(price + freight_value) AS item_plus_freight
    FROM order_items GROUP BY order_id
)
SELECT p.order_id,
       ROUND(p.total_payment, 2) AS total_payment,
       ROUND(i.item_plus_freight, 2) AS item_plus_freight,
       ROUND(p.total_payment - i.item_plus_freight, 2) AS difference
FROM payment_totals p
JOIN item_totals i ON p.order_id = i.order_id
WHERE ABS(p.total_payment - i.item_plus_freight) > 0.01
ORDER BY ABS(p.total_payment - i.item_plus_freight) DESC
LIMIT 50;
-- 6. OVERALL BUSINESS KPIs
SELECT COUNT(*) AS total_orders,
       COUNT(DISTINCT customer_id) AS customer_order_accounts,
       SUM(order_status = 'delivered') AS delivered_orders,
       SUM(order_status = 'canceled') AS canceled_orders,
       ROUND(100 * SUM(order_status = 'delivered') / COUNT(*), 2)
           AS delivered_order_percentage
FROM orders;

SELECT COUNT(*) AS order_items,
       COUNT(DISTINCT order_id) AS orders_with_items,
       ROUND(SUM(price), 2) AS product_sales,
       ROUND(SUM(freight_value), 2) AS freight_value,
       ROUND(SUM(price + freight_value), 2) AS item_plus_freight_value,
       ROUND(AVG(price), 2) AS average_item_price
FROM order_items;

SELECT COUNT(DISTINCT order_id) AS orders_with_payment_records,
       COUNT(*) AS payment_records,
       ROUND(SUM(payment_value), 2) AS recorded_payments
FROM payments;

-- 7. ORDER STATUS DISTRIBUTION
SELECT order_status, COUNT(*) AS total_orders,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS order_percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 8. MONTHLY SALES TREND
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COUNT(*) AS items_sold,
       ROUND(SUM(oi.price), 2) AS product_sales,
       ROUND(SUM(oi.freight_value), 2) AS freight_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

-- Delivered orders only
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       ROUND(SUM(oi.price), 2) AS delivered_product_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

-- 9. TOP PRODUCT CATEGORIES
SELECT COALESCE(ct.product_category_name_english,
                p.product_category_name, 'unknown') AS product_category,
       COUNT(DISTINCT oi.order_id) AS orders,
       COUNT(*) AS items_sold,
       ROUND(SUM(oi.price), 2) AS product_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english,
                  p.product_category_name, 'unknown')
ORDER BY product_sales DESC
LIMIT 10;

-- 10. CUSTOMER GEOGRAPHY
SELECT c.customer_state, COUNT(DISTINCT o.order_id) AS total_orders,
       COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 10;

SELECT c.customer_city, c.customer_state,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_city, c.customer_state
ORDER BY total_orders DESC
LIMIT 10;
-- 11. PAYMENT METHOD ANALYSIS
-- Payment record counts are not the same as unique order counts.
SELECT payment_type, COUNT(*) AS payment_records,
       COUNT(DISTINCT order_id) AS orders_using_method,
       ROUND(SUM(payment_value), 2) AS recorded_payment_value,
       ROUND(AVG(payment_value), 2) AS average_payment_record
FROM payments
GROUP BY payment_type
ORDER BY recorded_payment_value DESC;

SELECT payment_installments, COUNT(*) AS payment_records,
       ROUND(SUM(payment_value), 2) AS recorded_payment_value
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- 12. REVIEW ANALYSIS
SELECT review_score, COUNT(*) AS review_records,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM reviews), 2)
           AS review_percentage
FROM reviews
GROUP BY review_score
ORDER BY review_score;

SELECT COUNT(*) AS review_records,
       ROUND(AVG(review_score), 2) AS average_review_score,
       SUM(review_comment_message IS NULL) AS reviews_without_comment
FROM reviews;

-- 13. DELIVERY PERFORMANCE
SELECT COUNT(*) AS delivered_orders_with_dates,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                          order_purchase_timestamp)), 2) AS average_delivery_days,
       MIN(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)) AS minimum_delivery_days,
       MAX(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)) AS maximum_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;

SELECT COUNT(*) AS delivered_orders_with_estimate,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                          order_estimated_delivery_date)), 2)
           AS average_days_vs_estimate,
       SUM(order_delivered_customer_date > order_estimated_delivery_date)
           AS delivered_after_estimate,
       SUM(order_delivered_customer_date <= order_estimated_delivery_date)
           AS delivered_on_or_before_estimate
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- 14. TOP SELLERS
SELECT s.seller_id, s.seller_city, s.seller_state,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       COUNT(*) AS items_sold,
       ROUND(SUM(oi.price), 2) AS product_sales
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY product_sales DESC
LIMIT 10;

-- END
