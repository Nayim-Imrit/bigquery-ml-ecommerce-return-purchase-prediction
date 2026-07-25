/* Task 1. Create a new dataset and machine learning model

One of the projects you are working on needs to provide analysis based on real-world data. Your role in this project is to develop and evaluate machine learning models.

So, in this task, you have to create a dataset with the dataset ID ecommerce in which you can store your machine learning models.

Now create the machine learning model customer_classification_model to predict the performance of the model. Run the following query to create the customer_classification_model.*/

      CREATE OR REPLACE MODEL `ecommerce.customer_classification_model`
        OPTIONS
        (
        model_type='logistic_reg',
        labels = ['will_buy_on_return_visit']
        )
        AS

        #standardSQL
        SELECT
        * EXCEPT(fullVisitorId)
        FROM

        # features
        (SELECT
            fullVisitorId,
            IFNULL(totals.bounces, 0) AS bounces,
            IFNULL(totals.timeOnSite, 0) AS time_on_site
        FROM
            `data-to-insights.ecommerce.web_analytics`
        WHERE
            totals.newVisits = 1
            AND date BETWEEN '20160801' AND '20170430') # train on first 9 months
        JOIN
        (SELECT
            fullvisitorid,
            IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
        FROM
            `data-to-insights.ecommerce.web_analytics`
        GROUP BY fullvisitorid)
        USING (fullVisitorId);