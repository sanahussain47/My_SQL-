create database portfolio_project;

select * from customer_status; 
select * from population;

select* from telco_dataset;


select* from telco_dataset where Customer_ID in (select Customer_ID from telco_dataset where CustomerStatus = "Churned")  order by AvgMonthlyLongDistanceCharges desc limit 5;


WITH churned_customers AS (
  SELECT Customer_id, Age, Gender, Contract, MonthlyCharge
  FROM telco_dataset
  WHERE ChurnLabel = 'yes'
),
ranked_groups AS (
  SELECT 
    Age,
    Gender,
    Contract,
    AVG(MonthlyCharge) AS avg_monthly_charge,
    ROW_NUMBER() OVER (ORDER BY AVG(MonthlyCharge) DESC) AS ranks
  FROM (
    SELECT 
      CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
      END AS Age,
      Gender,
      Contract,
      MonthlyCharge
    FROM churned_customers
  ) AS subquery
  GROUP BY Age, Gender, Contract
)
SELECT *
FROM ranked_groups
WHERE ranks <= 5;

;


SELECT 
    Customer_ID,
    Contract,
    Gender,
    CustomerStatus,
    ChurnLabel,
    Age,
    Churn_Category,
    ChurnReason
FROM
    telco_dataset;
    
    
    WITH churned_customers AS (
  SELECT Customer_ID, PaymentMethod, ChurnLabel
  FROM telco_dataset
  WHERE ChurnLabel = 'yes'
),
payment_method_churn AS (
  SELECT 
    PaymentMethod,
    COUNT(DISTINCT Customer_id) AS churned_customers,
    SUM(CASE WHEN ChurnLabel = 'yes' THEN 1 ELSE 0 END) AS total_churns,
    ROUND(SUM(CASE WHEN ChurnLabel = 'yes' THEN 1 ELSE 0 END) / 
         (SELECT COUNT(*) FROM telco_dataset WHERE PaymentMethod = pm.PaymentMethod), 4) AS churn_rate
  FROM churned_customers pm
  GROUP BY PaymentMethod
)
SELECT 
  PaymentMethod,
  churned_customers,
  total_churns,
  churn_rate
FROM payment_method_churn
ORDER BY churn_rate DESC;
