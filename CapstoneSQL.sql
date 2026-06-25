-- Checking out the Kaggle dataset --
-- First, making sure if each row is distinct --

select count(*) AS total_rows, count(DISTINCT CUSTOMER_ID) AS unique_customers
from dbo.insurance_data

-- Now checking what insurance types we're working with, and if there's any issues w/ claim status --

select distinct insurance_type from dbo.insurance_data
select distinct claim_status from dbo.insurance_data

-- Checking for Nulls -- 

select
	sum(case when premium_amount is null then 1 else 0 end) as null_premium,
	sum(case when claim_amount is null then 1 else 0 end) as null_claim,
	sum(case when tenure is null then 1 else 0 end) as null_tenure,
	sum(case when customer_id is null then 1 else 0 end) as null_customer_id
from dbo.insurance_data

-- Our sample size (Auto Claims) Is going to be 1574. --

Select count (*) insurance_type from dbo.insurance_data where insurance_type = 'motor'

--- Before I create a view, running some more checks. ---

-- TENURE is most likely in months, will be converting to years (b/t 0.5-9.9) --
select min(tenure), max(tenure) 
from dbo.insurance_data where insurance_type = 'motor'
-- AGE could be a limitation, minimum is 25, maximum is 64--
-- this leaves out age groups in my previous projects that had high claim frequency --
select min(age), Max(age)
from dbo.insurance_data where insurance_type = 'motor'
-- PREMIUM_AMOUNT is monthly. --
select min(PREMIUM_AMOUNT), Max(PREMIUM_AMOUNT)
from dbo.insurance_data where insurance_type = 'motor'
-- This dataset only includes policyholders who have filed a claim. --
select min(CLAIM_AMOUNT), Max(CLAIM_AMOUNT)
from dbo.insurance_data where insurance_type = 'motor'

-- creating a table to work with in the future, making some small tweaks for later analysis --

create view view_insurance_motor_clean as
select 
	transaction_id, customer_id, policy_number, policy_eff_dt, loss_dt, report_dt,
	datediff(day, Loss_dt,report_dt) as reporting_delay_days,premium_amount AS premium_monthly,
	premium_amount * 12 AS premium_yearly, claim_amount, claim_status,
	case when claim_status = 'A' then claim_amount else 0 end as claim_amount_paid,
	CAST(tenure / 12.0 as decimal(5,2)) AS tenure_years, incident_severity, tenure as tenure_months, 
	age, marital_status, no_of_family_members, risk_segmentation, social_class,
	customer_education_level, house_type, any_injury, police_report_available
from dbo.insurance_data
where insurance_type = 'motor'
