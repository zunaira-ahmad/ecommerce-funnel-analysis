SELECT
  traffic_source.source as referring_site,
  Count(DISTINCT user_pseudo_id) as visitors,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS buyers
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE traffic_source.medium = 'referral'
GROUP BY referring_site
ORDER BY Visitors DESC
Limit 10;