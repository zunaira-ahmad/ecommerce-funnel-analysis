SELECT
  COUNT(DISTINCT ecommerce.transaction_id) AS orders,
  ROUND(SUM(ecommerce.purchase_revenue), 2) AS total_revenue,
  ROUND(SUM(ecommerce.purchase_revenue) / COUNT(DISTINCT ecommerce.transaction_id), 2) AS avg_order_value
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'purchase';