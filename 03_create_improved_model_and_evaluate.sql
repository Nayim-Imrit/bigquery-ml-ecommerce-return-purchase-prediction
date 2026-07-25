/*Task 3. Improve model performance with Feature Engineering and Evaluate the model to see if there is better predictive power

In this task, use dataset features that may help the customer_classification_model model better understand the relationship between a visitor's first session and the likelihood that they purchase on a subsequent visit.

Now add some new features and create a second machine learning model called improved_customer_classification_model.

    How far the visitor got in the checkout process on their first visit
    Where the visitor came from(traffic source: organic search, referring site, etc..)
    Device category(mobile, tablet, desktop)
    Geographic information(country)

Now, evaluate the newly created model improved_customer_classification_model to see if there is better predictive power than customer_classification_model.*/

-- Step 1: Create the improved model

-- Run this query to create improved_customer_classification_model with the new features:
CREATE OR REPLACE MODEL `ecommerce.improved_customer_classification_model`
OPTIONS(
  model_type='logistic_reg',
  labels = ['will_buy_on_return_visit']
) AS

WITH
  features AS (
    SELECT
      fullVisitorId,
      IFNULL(totals.bounces, 0) AS bounces,
      IFNULL(totals.timeOnSite, 0) AS time_on_site,
      IFNULL(totals.pageviews, 0) AS pageviews,                  -- how far they got (engagement)
      trafficSource.source AS traffic_source,                    -- where they came from
      device.deviceCategory AS device_category,                  -- mobile/tablet/desktop
      geoNetwork.country AS country                              -- geographic info
    FROM
      `data-to-insights.ecommerce.web_analytics`
    WHERE
      totals.newVisits = 1
      AND date BETWEEN '20160801' AND '20170430'                 -- same training period
  ),

  labels AS (
    SELECT
      fullvisitorid,
      IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
    FROM
      `data-to-insights.ecommerce.web_analytics`
    GROUP BY fullvisitorid
  )

SELECT
  * EXCEPT(fullVisitorId)                                       -- exclude visitor ID from training
FROM
  features
JOIN
  labels
ON
  features.fullVisitorId = labels.fullvisitorid;

-- Step 2: Evaluate the improved model

-- Run this query to evaluate improved_customer_classification_model on the same unseen evaluation data (May 2017):
SELECT
  roc_auc,
  accuracy,
  precision,
  recall
FROM
  ML.EVALUATE(MODEL `ecommerce.improved_customer_classification_model`,
    (
      SELECT
        * EXCEPT(fullVisitorId)
      FROM
        (SELECT
          fullVisitorId,
          IFNULL(totals.bounces, 0) AS bounces,
          IFNULL(totals.timeOnSite, 0) AS time_on_site,
          IFNULL(totals.pageviews, 0) AS pageviews,
          trafficSource.source AS traffic_source,
          device.deviceCategory AS device_category,
          geoNetwork.country AS country
        FROM
          `data-to-insights.ecommerce.web_analytics`
        WHERE
          date BETWEEN '20170501' AND '20170531')               -- evaluation period
        JOIN
        (SELECT
          fullvisitorid,
          IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
        FROM
          `data-to-insights.ecommerce.web_analytics`
        GROUP BY fullvisitorid)
        USING (fullVisitorId)
    )
);

/*What to observe:

    Compare the roc_auc from this evaluation to the one you got in Task 2.

    The improved model should show a higher roc_auc (e.g., > 0.8) because the new features (pageviews, traffic source, device, country) add predictive power.

    Once you confirm the improvement, you're ready for the final task.*/