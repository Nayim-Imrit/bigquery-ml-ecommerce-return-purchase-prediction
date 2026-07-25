/*Task 4. Predict which new visitors will come back and purchase

Now create the machine learning model finalized_classification_model to predict the performance of the model. Run the following query to create the finalized_classification_model.*/

  CREATE OR REPLACE MODEL `ecommerce.finalized_classification_model`
  OPTIONS
    (model_type="logistic_reg", labels = ["will_buy_on_return_visit"]) AS

  WITH all_visitor_stats AS (
  SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
    FROM `data-to-insights.ecommerce.web_analytics`
    GROUP BY fullvisitorid
  )

  # add in new features
  SELECT * EXCEPT(unique_session_id) FROM (

    SELECT
        CONCAT(fullvisitorid, CAST(visitId AS STRING)) AS unique_session_id,

        # labels
        will_buy_on_return_visit,

        MAX(CAST(h.eCommerceAction.action_type AS INT64)) AS latest_ecommerce_progress,

        # behavior on the site
        IFNULL(totals.bounces, 0) AS bounces,
        IFNULL(totals.timeOnSite, 0) AS time_on_site,
        IFNULL(totals.pageviews, 0) AS pageviews,

        # where the visitor came from
        trafficSource.source,
        trafficSource.medium,
        channelGrouping,

        # mobile or desktop
        device.deviceCategory,

        # geographic
        IFNULL(geoNetwork.country, "") AS country

    FROM `data-to-insights.ecommerce.web_analytics`,
      UNNEST(hits) AS h

      JOIN all_visitor_stats USING(fullvisitorid)

    WHERE 1=1
      # only predict for new visits
      AND totals.newVisits = 1
      AND date BETWEEN "20160801" AND "20170430" # train 9 months

    GROUP BY
    unique_session_id,
    will_buy_on_return_visit,
    bounces,
    time_on_site,
    totals.pageviews,
    trafficSource.source,
    trafficSource.medium,
    channelGrouping,
    device.deviceCategory,
    country
  );

/*
    Write a query to predict which new visitors will come back and make a purchase.
    The query uses the finalized_classification_model model to predict the probability that a first-time visitor to the Google Merchandise Store will make a purchase on a later visit.
    You have to make the predictions in the last 1 month (out of 12 months) of the dataset.

For Task 4, you need to use the finalized_classification_model to predict which new visitors in the last month of the dataset (July 2017) will return and make a purchase.*/

-- Run this prediction query in the BigQuery console:
SELECT
  *
FROM
  ML.PREDICT(MODEL `ecommerce.finalized_classification_model`,
    (
      SELECT
        * EXCEPT(unique_session_id)
      FROM (
        SELECT
          CONCAT(fullvisitorid, CAST(visitId AS STRING)) AS unique_session_id,
          MAX(CAST(h.eCommerceAction.action_type AS INT64)) AS latest_ecommerce_progress,
          IFNULL(totals.bounces, 0) AS bounces,
          IFNULL(totals.timeOnSite, 0) AS time_on_site,
          IFNULL(totals.pageviews, 0) AS pageviews,
          trafficSource.source,
          trafficSource.medium,
          channelGrouping,
          device.deviceCategory,
          IFNULL(geoNetwork.country, "") AS country
        FROM
          `data-to-insights.ecommerce.web_analytics`,
          UNNEST(hits) AS h
        WHERE
          totals.newVisits = 1
          AND date BETWEEN "20170701" AND "20170731"   -- last month (July 2017)
        GROUP BY
          unique_session_id,
          bounces,
          time_on_site,
          pageviews,
          source,
          medium,
          channelGrouping,
          deviceCategory,
          country
      )
    )
);

/* What to look for in the output:

    predicted_will_buy_on_return_visit – the model's binary prediction (0 = won't buy, 1 = will buy).

    predicted_will_buy_on_return_visit_probs – the probability scores. You'll see an array like [{"label":"0","prob":0.85}, {"label":"1","prob":0.15}]. The higher the probability for label "1", the more confident the model is that the visitor will purchase on a return visit.

You can optionally filter for only the most promising visitors by adding WHERE predicted_will_buy_on_return_visit = 1 or ordering by the probability score.*/
