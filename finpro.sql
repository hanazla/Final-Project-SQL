--NO 1--
SELECT 
EXTRACT(MONTH FROM order_date) as monthly_transactions,
SUM(after_discount) as total_transactions

FROM
`metal-node-401808.finalsql.order_detail`

WHERE
EXTRACT(YEAR FROM order_date) = 2021 AND is_valid = 1

GROUP BY
monthly_transactions

ORDER BY
total_transactions DESC
LIMIT 1;

--NO 2--
SELECT 
s.category,
SUM(o.after_discount) as total_transactions

FROM `metal-node-401808.finalsql.sku_detail` s

JOIN `metal-node-401808.finalsql.order_detail` o ON s.id = o.sku_id

WHERE EXTRACT(YEAR FROM o.order_date) = 2022 AND o.is_valid = 1

GROUP BY s.category

ORDER BY total_transactions DESC

LIMIT 1

--NO 3--
WITH yeartotals AS (
    SELECT
        s.category,
        EXTRACT(YEAR FROM o.order_date) AS years,
        SUM(o.after_discount) AS total_transaction
    FROM
        `metal-node-401808.finalsql.sku_detail` s
        JOIN `metal-node-401808.finalsql.order_detail` o ON s.id = o.sku_id
    WHERE
        o.is_valid = 1
        AND EXTRACT(YEAR FROM o.order_date) IN (2021, 2022)
    GROUP BY
        s.category, years
)
SELECT
    a.category,
    a.years AS year_2021,
    b.years AS year_2022,
    a.total_transaction AS total_transaction_2021,
    b.total_transaction AS total_transaction_2022,
    CASE
        WHEN b.total_transaction > a.total_transaction AND b.years = 2022 THEN 'Peningkatan'
        WHEN b.total_transaction < a.total_transaction AND a.years = 2021 THEN 'Penurunan'
        ELSE 'Tidak berubah'
    END AS transaction_change
FROM
    yeartotals a
JOIN
    yeartotals b ON a.category = b.category
    AND a.years = 2021
    AND b.years = 2022;

--NO 4--
WITH PaymentMethodCounts as(
	SELECT
	p.payment_method,
	count(distinct o.id) as unique_order
	FROM
	`metal-node-401808.finalsql.order_detail` o
	JOIN `metal-node-401808.finalsql.payment_detail` p on o.payment_id = p.id
	WHERE
	o.is_valid = 1
	AND EXTRACT(YEAR FROM o.order_date) = 2022
	GROUP BY
	p.payment_method
)
SELECT
payment_method,
unique_order
FROM
PaymentMethodCounts
ORDER BY
unique_order DESC
LIMIT 5;

--NO 5--
SELECT
    s.sku_name,
    SUM(o.after_discount) AS total_transaction
FROM
    `metal-node-401808.finalsql.sku_detail` s
JOIN
    `metal-node-401808.finalsql.order_detail` o ON s.id = o.sku_id
WHERE
    s.sku_name LIKE '%Samsung%'
    OR s.sku_name LIKE '%Apple%'
    OR s.sku_name LIKE '%Sony%'
    OR s.sku_name LIKE '%Huawei%'
    OR s.sku_name LIKE '%Lenovo%'
    AND o.is_valid = 1
GROUP BY
    s.sku_name
ORDER BY
    total_transaction DESC;

