# Funnel Analysis on Google's GA4 Merchandise Store

**Where do shoppers drop off before buying, who is leaving, and how much revenue could we restore?**

📊 **[View the interactive Tableau dashboard](https://public.tableau.com/app/profile/zunaira.ahmad8647/viz/EcommerceFunnelAnalysis_17918054925600/FunnelDashboard)**

**Tools:** SQL (Google BigQuery) · Google Sheets / Excel · Tableau Public

---

## Summary

- Only **about 1 in 100 visitors (1.1%)** completes a purchase.
- The biggest drop-offs happen early: **77% of visitors never view a product**, and **80% of product viewers never add to cart**.
- Conversion is **almost identical across desktop, mobile and tablet**, so device is not the cause.
- **Paid ads convert the worst (0.69%)**, a statistically significant gap vs Google search (0.89%, p ≈ 0.02).
- Referral looked like the best channel, but **about 44% of referral visitors came from the store's own website** (a self-referral tracking error).
- Winning back just 10% of the people who leave at each step is worth **$6K to $92K per step** in extra revenue.

---

## 1. Project Overview

Funnel analysis looks at the sequential steps users take toward a goal, to understand **where users leave** and **how to improve that**.

In this project, I analyse user behaviour on Google's online Merchandise Store, from the first page view to purchase, to answer three questions:

1. **Where** is the user drop-off happening?
2. **Who** is leaving?
3. **How much revenue** could we restore by fixing these drop-offs?

## 2. Data

- **Source:** Google's public GA4 sample dataset, `bigquery-public-data.ga4_obfuscated_sample_ecommerce`
- **Store:** Google Merchandise Store (Google's official online shop)
- **Period:** 3 months (Nov 2020 to Jan 2021)
- **Size:** about 270,000 visitors and 4.3 million events
- Each row is one action (event) a visitor took, such as `page_view`, `view_item`, `add_to_cart` or `purchase`.

## 3. Approach

| Step | What I did | SQL file |
|---|---|---|
| 1. Explore the data | Counted every type of action users take, to choose the funnel steps and check data quality | `01_event_overview.sql` |
| 2. Build the funnel | Built a strict 6-step funnel, where a user only counts at a step if they completed every step before it | `02_closed_funnel.sql` |
| 3. Split the funnel | Compared the funnel by device and by traffic channel, and checked where referral traffic comes from | `03_funnel_by_device.sql`, `03b_funnel_by_channel.sql`, `03c_referral_check.sql` |
| 4. Size the revenue | Calculated average order value and estimated the revenue at stake at each step | `04_average_order_value.sql` |
| 5. Test significance | Ran a two-proportion z-test on paid ads vs Google search conversion | `significance_test.xlsx` |
| 6. Visualise | Built an interactive Tableau Public dashboard | [Dashboard](https://public.tableau.com/app/profile/zunaira.ahmad8647/viz/EcommerceFunnelAnalysis_17918054925600/FunnelDashboard) |

**Funnel steps:** Visited site (`page_view`) → Viewed a product (`view_item`) → Added to cart (`add_to_cart`) → Started checkout (`begin_checkout`) → Entered payment (`add_payment_info`) → Purchased (`purchase`)

## 4. Findings

### 4.1 Where do users drop off?

| Step | Users | % who made it from the step before |
|---|---|---|
| 1. Visited | 269,792 | n/a |
| 2. Viewed a product | 61,224 | 22.7% |
| 3. Added to cart | 12,539 | 20.5% |
| 4. Started checkout | 5,656 | 45.1% |
| 5. Entered payment | 3,654 | 64.6% |
| 6. Purchased | 2,915 | 79.8% |

**Overall conversion: 1.1%**

- 77% of users who visit the site never view a product. **This is the biggest drop by volume.**
- 80% of product viewers don't add the product to cart. This could be due to price, product photos, shipping costs, etc.
- 55% of users who add a product to cart don't proceed to checkout.
- 35% of users quit during checkout before entering payment. **This checkout friction is a fixable issue.**
- 20% of users enter payment but don't purchase.

### 4.2 Who is leaving? By device

*Question: is the funnel worse for mobile users than desktop users?*

| Step (% who made it from the step before) | Desktop | Mobile | Tablet |
|---|---|---|---|
| Viewed a product | 22.8% | 22.6% | 23.1% |
| Added to cart | 20.4% | 20.7% | 19.8% |
| Started checkout | 44.6% | 45.8% | 45.1% |
| Entered payment | 64.5% | 64.8% | 63.2% |
| Purchased | 79.1% | 80.6% | 82.3% |
| **Overall conversion** | **1.06%** | **1.12%** | **1.07%** |

The three devices behave almost the same way, with every step within 1 to 3 percentage points. **The funnel is not worse for mobile users than desktop users**, so the drop-off problem is not caused by a specific device.

### 4.3 Who is leaving? By traffic channel

*Question: does conversion depend on how visitors found the store?* (`traffic_source.medium`)

| Channel | Visitors | Viewed product | Added to cart | Started checkout | Entered payment | Purchased | **Overall** |
|---|---|---|---|---|---|---|---|
| Organic (Google search) | 98,625 | 21.6% | 19.1% | 43.5% | 62.4% | 79.2% | **0.89%** |
| (none) (typed URL) | 63,446 | 22.3% | 20.7% | 45.2% | 63.8% | 80.4% | **1.07%** |
| Referral (link on another site) | 42,478 | 25.0% | 22.4% | 47.0% | 69.2% | 79.3% | **1.44%** |
| CPC (paid ads) | 13,409 | 20.3% | 17.4% | 41.9% | 56.1% | 82.9% | **0.69%** |
| `<Other>` (hidden)* | 44,622 | 20.5% | 18.6% | 44.0% | 55.4% | 76.8% | 0.71% |
| `(data deleted)` (hidden)* | 7,212 | 45.5% | 30.3% | 50.0% | 81.5% | 83.2% | 4.67% |

\*Hidden by Google's obfuscation (about 19% of visitors). Left out of the channel comparison.

- **Paid ads convert the least (0.69%)**, even though the store pays for every click. The gap vs Google search is **statistically significant (p ≈ 0.02)**.
- **Google search has the most visitors yet a below-average conversion rate (0.89%).** Since this is the biggest channel, small improvements here would have a big impact.
- **Referral appears to convert the best (1.44%)** and is ahead at nearly every step. However, a common GA4 tracking issue is counting shoppers who return to the store from another page as "referral" visitors, so I investigated further (4.4).

### 4.4 Does referral really have the highest conversion rate?

| Referring site | Visitors | Buyers | Conversion |
|---|---|---|---|
| `<Other>` (hidden) | 32,880 | 468 | 1.42% |
| shop.googlemerchandisestore.com | 26,065 | 568 | 2.18% |

The results show a tracking mistake. `shop.googlemerchandisestore.com` is **the store's own website**, so these visitors were not referred from another site. GA4 is mislabelling **about 44% of referral visitors** (self-referral), and they convert well, which inflates referral's result. Because of this, **we can't confirm how good the referral channel really is.**

### 4.5 What is it costing?

**Average order value: $81.35** (4,452 orders, about $362K revenue)

If the store won back just **10%** of the people who leave at each step:

| Where people leave | People who quit | Extra revenue (estimate) |
|---|---|---|
| Viewed product, didn't add to cart | 48,685 | ~$92,100 |
| Visited, never viewed a product | 208,568 | ~$80,800 |
| Added to cart, didn't start checkout | 6,883 | ~$28,900 |
| Started checkout, didn't enter payment | 2,002 | ~$13,000 |
| Entered payment, didn't buy | 739 | ~$6,000 |

**Method:** people won back × share of them who would go on to buy × average order value. The calculations (with an adjustable win-back rate) are in `revenue_opportunity.xlsx`.

## 5. Recommendations

1. **Fix checkout first (quick win).** 2,002 people started checkout but never entered payment. This step is easier and faster to fix than product pages, and winning back just 10% of them could add about **$13,000** in revenue. Possible fixes: guest checkout, fewer form fields, and showing shipping costs earlier.
2. **Review paid ads before spending more.** Paid ads have the lowest conversion (0.69% vs 0.89% for Google search, a statistically significant gap, p ≈ 0.02), even though the store pays for each click. I'd recommend the marketing team check that ads send people to the right product pages before increasing ad spend.
3. **Fix the GA4 tracking.**
   - **Missing add-to-cart events:** 34% of buyers have no add-to-cart event, which makes the funnel undercount buyers.
   - **Self-referral:** add the store's own domain to GA4's "unwanted referrals" list, so channel reports are accurate.

## 6. Data Quality Issues Found

- **34% of buyers had no `add_to_cart` event** (1,504 of 4,419). This could be due to a "Buy now" feature or a tracking bug. I kept the strict funnel because it is easy and clear to interpret, and documented this as a limitation.
- **Self-referral:** the store's own domain shows up as a referral source, which makes the referral channel look better than it is.
- **`add_shipping_info` fires at the same time as `begin_checkout`** (9,714 vs 9,715 users), so I left it out of the funnel.
- **`view_item_list` is barely tracked** (71 users vs 13,180 for `select_item`), which suggests list tracking is broken, so I ignored it.

## 7. Limitations

- Google scrambled ("obfuscated") this dataset for privacy, so some values are hidden and revenue is approximate.
- About 19% of visitors have a hidden traffic channel, so I left them out of the channel comparison.
- The strict funnel undercounts buyers because of the add-to-cart tracking gap.
- A small number of users visit from more than one device; each user is assigned one device.
- Revenue estimates are "what if" scenarios, not forecasts. They assume won-back users buy at the same rate as current shoppers.

## 8. Repository Structure

| File | What it does |
|---|---|
| `sql/01_event_overview.sql` | Counts each type of action |
| `sql/02_closed_funnel.sql` | Builds the 6-step funnel and checks for buyers with no add-to-cart event |
| `sql/03_funnel_by_device.sql` | Funnel split by device |
| `sql/03b_funnel_by_channel.sql` | Funnel split by traffic channel |
| `sql/03c_referral_check.sql` | Checks where referral traffic comes from |
| `sql/04_average_order_value.sql` | Calculates average order value |
| `revenue_opportunity.xlsx` | Revenue-at-stake calculations |
| `significance_test.xlsx` | Tests whether the paid ads vs Google search gap is real |
| `data/` | Funnel results used in the Tableau dashboard |

---

*Author: Zunaira*
