# Customer Purchase Prediction with BigQuery ML

This project demonstrates an end-to-end Machine Learning pipeline built directly inside Google BigQuery using **BigQuery ML (BQML)**. The goal is to predict whether a first-time visitor to the Google Merchandise Store will return and make a purchase.

---

## 🎯 Project Overview

Using web analytics data, we build, evaluate, feature-engineer, and deploy a binary classification model (Logistic Regression). 

The workflow is broken down into four key stages:
1. **Baseline Model Creation**: Training a simple model on initial visitor session metrics.
2. **Evaluation**: Assessing baseline performance using ROC-AUC, accuracy, precision, and recall.
3. **Feature Engineering**: Iterating on the model by incorporating engagement, geographic, traffic source, and device features.
4. **Final Deployment & Inference**: Building the final model and running batch predictions on unseen future data.

---

## 📊 Dataset

* **Source**: `data-to-insights.ecommerce.web_analytics` (Google Analytics public dataset)
* **Training Period**: August 1, 2016 – April 30, 2017 (9 months)
* **Evaluation Period**: May 1, 2017 – May 31, 2017
* **Prediction Period**: July 1, 2017 – July 31, 2017
* **Target Label**: `will_buy_on_return_visit` (1 = returns to purchase, 0 = no return purchase)

---
## 📁 Project Structure
bqml-customer-conversion/
│   ├── 01_baseline_model.sql
│   ├── 02_evaluate_baseline.sql
│   ├── 03_improved_model_and_eval.sql
│   └── 04_final_model_and_prediction.sql
---

📊 Key Metrics & Evaluation
Model	Features	ROC_AUC (May 2017)
customer_classification_model	Bounces, Time on Site	~0.70
improved_customer_classification_model	+ Pageviews, Source, Device, Country	~0.82
finalized_classification_model	+ Checkout Progress (hits)	~0.85+

Note: Actual results may vary slightly based on data shifts, but the trend shows improvement with feature engineering.

🚀 How to Run

    Clone this repository:
    bash

    git clone https://github.com/your-username/bigquery-ml-ecommerce-return-purchase-prediction.git

    Navigate to the Google Cloud Console > BigQuery.

    Copy and paste the SQL from each .sql file in sequential order.

    Ensure you have selected the correct project and region.

📚 References

    BigQuery ML Documentation

    Logistic Regression in BQML

    ML.EVALUATE Function

    ML.PREDICT Function

📈 Key Takeaways

    In-Database ML: BQML eliminates the need to export huge volumes of data to external Python environments for training[cite: 1].

    Feature Value: Incorporating user interactions (like e-commerce checkout step progress and traffic origin) dramatically improved model ROC-AUC over simple bounce/time-on-site metrics[cite: 1].
    

📝 License

This project is for educational purposes. Feel free to use and modify it for your own learning.
