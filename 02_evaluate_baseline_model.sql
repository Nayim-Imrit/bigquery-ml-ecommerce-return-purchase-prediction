/*Task 2. Evaluate classification model performance

In this task, you have to evaluate the performance of the customer_classification_model against new unseen evaluation data.

In BigQuery ML, roc_auc is simply a queryable field when evaluating your trained ML model. So run the query to evaluate how well the model performs using ML.EVALUATE.

After evaluating your model, observe the predictive power of this model.

For Task 2, you need to evaluate your model using ML.EVALUATE on new, unseen data (the evaluation period is typically May 2017, since you trained on August 2016 – April 2017).*/

-- Run this query in the BigQuery console:
SELECT
  roc_auc,
  accuracy,
  precision,
  recall
FROM
  ML.EVALUATE(MODEL `ecommerce.customer_classification_model`,
    (
      SELECT
        * EXCEPT(fullVisitorId)
      FROM
        (SELECT
          fullVisitorId,
          IFNULL(totals.bounces, 0) AS bounces,
          IFNULL(totals.timeOnSite, 0) AS time_on_site
        FROM
          `data-to-insights.ecommerce.web_analytics`
        WHERE
          date BETWEEN '20170501' AND '20170531')   -- evaluation data (May 2017)
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

/* What to observe:

    roc_auc – the main metric. A value around 0.7–0.8 indicates decent predictive power.

    accuracy, precision, recall – additional metrics to judge model performance.

After running this, you'll see the evaluation results. The model likely shows moderate performance, which you'll improve in the next tasks.*/