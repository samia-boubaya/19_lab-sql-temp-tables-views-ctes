-- -- This View aggregates rental count per customer
-- ===============================================================================================================
-- LEFT JOIN ensures customers with zero rentals are included
-- COUNT(r.rental_id) avoids counting NULLs

-- ===============================================================================================================
-- SOLVED CHALLENGE #1: Create a view that shows each customer's total rentals
USE sakila;
-- ===============================================================================================================

-- 1. Create a View:
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
-- ---------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r 
    ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;


-- ===============================================================================================================
-- SOLVED CHALLENGE #2: Create a Temporary Table:
-- ===============================================================================================================

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    v.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary v
LEFT JOIN payment p 
    ON v.customer_id = p.customer_id
GROUP BY v.customer_id;


-- ===============================================================================================================
-- SOLVED CHALLENGE #3: Create a CTE and Customer Summary Report
-- ===============================================================================================================

-- 3.1 Create a CTE
WITH customer_summary AS (
    SELECT 
        v.customer_id,
        CONCAT(v.first_name, ' ', v.last_name) AS customer_name,
        v.email,
        v.rental_count,
        COALESCE(t.total_paid, 0) AS total_paid
    FROM customer_rental_summary v
    LEFT JOIN customer_payment_summary t
        ON v.customer_id = t.customer_id
)

-- ---------------------------------------------------------------------------------------------------------------
-- 3.2 Create a Customer Summary Report
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count = 0 THEN 0
        ELSE total_paid / rental_count
    END AS average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC;
