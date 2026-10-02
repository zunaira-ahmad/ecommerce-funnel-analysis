WITH user_steps AS (
  SELECT
      user_pseudo_id,
      ANY_VALUE(device.category) as device,
      MAX(IF(event_name = 'page_view', 1, 0))        AS visited,
      MAX(IF(event_name = 'view_item', 1, 0))        AS viewed_item,
      MAX(IF(event_name = 'add_to_cart', 1, 0))      AS added_to_cart,
      MAX(IF(event_name = 'begin_checkout', 1, 0))   AS began_checkout,
      MAX(IF(event_name = 'add_payment_info', 1, 0)) AS added_payment,
      MAX(IF(event_name = 'purchase', 1, 0))         AS purchased
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    GROUP BY user_pseudo_id
)
SELECT
  device,
  SUM(visited) AS step1_visit,
  SUM(visited*viewed_item) AS step2_view_item,
  SUM(visited*viewed_item*added_to_cart) AS step3_add_to_cart,
  SUM(visited*viewed_item*added_to_cart*began_checkout) AS step4_checkout,
  SUM(visited*viewed_item*added_to_cart*began_checkout*added_payment) AS step5_payment,
  SUM(visited*viewed_item*added_to_cart*began_checkout*added_payment*purchased) AS step6_purchase,
FROM user_steps
GROUP BY device
ORDER BY step1_visit DESC;