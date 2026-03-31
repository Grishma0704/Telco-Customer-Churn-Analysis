--creating table 
CREATE TABLE customers (
    CustomerID text,
	City text,
	Gender text,
	Senior_Citizen text,
	Partner text,
	Dependents text,
	Tenure_Months integer,
	Contract varchar,
	Payment_Method varchar,
	Monthly_Charges float,
	Total_Charges varchar,
	Churn_Label varchar,
	Churn_Score float,
	Churn_Reason text
);

select * from customers

--transforming total_charges
select count(total_charges) from customers
where total_charges = ''

update customers
set total_charges = NULL
where total_charges = 'Null'

ALTER TABLE customers
ALTER COLUMN total_charges TYPE DOUBLE PRECISION
USING total_charges::DOUBLE PRECISION;
--copying data
create table customer_features as 
select * from customers

select * from customer_features

--churn(target variable)

alter table customer_features add column churn_flag int

update customer_features
set churn_flag = case
   when churn_label = 'Yes' then 1
   else 0 end

--avg monthly spend
alter table customer_features add column avg_monthly_value float

UPDATE customer_features
SET avg_monthly_value = total_charges / NULLIF(tenure_months, 0);

--contract risks
alter table customer_features add column contract_risks int

update customer_features
set contract_risks = case
   when contract  = 'Month-to-month' then 2
   when contract  = 'One year' then 1
   else 0 end

--payment risks
ALTER TABLE customer_features ADD COLUMN payment_risk INT;

UPDATE customer_features
SET payment_risk =
    CASE 
        WHEN payment_method = 'Electronic check' THEN 1
        ELSE 0
    END;
	
--engagement
ALTER TABLE customer_features ADD COLUMN engagement_score FLOAT;

UPDATE customer_features
SET engagement_score =
    (tenure_months * 0.5) + (monthly_charges * 0.5);

--customer lifetime value
ALTER TABLE customer_features ADD COLUMN cltv FLOAT;

UPDATE customer_features
SET cltv = monthly_charges * tenure_months;

--high value customers
ALTER TABLE customer_features ADD COLUMN high_value INT;

UPDATE customer_features
SET high_value =
    CASE 
        WHEN cltv > 2000 THEN 1
        ELSE 0
    END;

--churn rate
select sum(case when churn_flag = 1 then 1 else 0 end)*100.0/count(*) as churn_rate
from customer_features

--churn by contract
SELECT contract, 
       AVG(churn_flag) AS churn_rate
FROM customer_features
GROUP BY contract
ORDER BY churn_rate DESC;

--revenue at risk
SELECT SUM(monthly_charges) AS revenue_at_risk
FROM customer_features
WHERE churn_flag = 1;

--high cltv and high churn
SELECT *
FROM customer_features
WHERE churn_flag = 1
AND cltv > 2000;