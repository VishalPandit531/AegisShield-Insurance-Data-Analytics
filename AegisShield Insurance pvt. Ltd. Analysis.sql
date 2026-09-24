                       -- PART A — PostgreSQL + pgAdmin 4 SETUP

CREATE DATABASE insurance_analysis;


                             -- PART B — CREATE THE FIVE TABLES 

DROP TABLE IF EXISTS insurance.customers;
CREATE TABLE insurance.customers (
    customer_id BIGINT PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    state VARCHAR(100),
    city VARCHAR(100),
    income_band VARCHAR(50),
    customer_segment VARCHAR(50),
    customer_since DATE
);

DROP TABLE IF EXISTS insurance.policies;
CREATE TABLE insurance.policies(
	policy_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    product VARCHAR(100),
    policy_start DATE,
    policy_end DATE,
    premium NUMERIC(15,2),
    sum_insured NUMERIC(15,2),
    channel VARCHAR(50),
    agent_id BIGINT,
    renewal_status VARCHAR(30)
);

DROP TABLE IF EXISTS insurance.claims;
CREATE TABLE insurance.claims (
    claim_id BIGINT PRIMARY KEY,
    policy_id BIGINT,
    customer_id BIGINT,
    claim_date DATE,
    claim_type VARCHAR(100),
    claim_amount NUMERIC(15,2),
    approved_amount NUMERIC(15,2),
    claim_status VARCHAR(50),
    settlement_date DATE,
    provider VARCHAR(150),
    fraud_score INTEGER,
    fraud_risk VARCHAR(30),
	Claim_TAT_Days INTEGER
);

DROP TABLE IF EXISTS insurance.agents;
CREATE TABLE insurance.agents (
    agent_id BIGINT PRIMARY KEY,
    agent_name VARCHAR(150),
    branch VARCHAR(100),
    state VARCHAR(100),
    joining_date DATE,
    policies_sold INTEGER,
    premium_generated NUMERIC(15,2)
);

DROP TABLE IF EXISTS insurance.complaints;
CREATE TABLE insurance.complaints (
    complaint_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    policy_id BIGINT,
    complaint_date DATE,
    complaint_type VARCHAR(100),
    channel VARCHAR(50),
    resolution_date DATE,
    resolution_status VARCHAR(50),
	Complaint_TAT_Days INTEGER
);

SELECT * FROM insurance.customers;
SELECT * FROM insurance.policies;
SELECT * FROM insurance.claims;
SELECT * FROM insurance.agents;
SELECT * FROM insurance.complaints;


                           -- PART C — IMPORT + VALIDATE
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'insurance'
ORDER BY table_name;


-- Check row counts

-- Instead of running five separate queries, PostgreSQL lets us do this:

SELECT 'Customers' AS table_name, COUNT(*) AS row_count
FROM insurance.customers

UNION ALL

SELECT 'Policies', COUNT(*)
FROM insurance.policies

UNION ALL

SELECT 'Claims', COUNT(*)
FROM insurance.claims

UNION ALL

SELECT 'Agents', COUNT(*)
FROM insurance.agents

UNION ALL

SELECT 'Complaints', COUNT(*)
FROM insurance.complaints;


                             -- PART D — DATA VALIDATION

-- Check duplicate Customers
SELECT customer_id, COUNT(*) AS duplicate_count
FROM insurance.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check duplicate Policies
SELECT policy_id, COUNT (*) AS duplicate_count
FROM insurance.policies
GROUP BY policy_id
HAVING COUNT (*) > 1;

-- Check duplicate Claims
SELECT claim_id, COUNT(*) AS duplicate_count
FROM insurance.claims
GROUP BY claim_id
HAVING COUNT(*) > 1;

-- Check duplicate Complaints
SELECT complaint_id, COUNT(*) AS duplicate_count
FROM insurance.complaints
GROUP BY complaint_id
HAVING COUNT(*) > 1;

-- Check customer age
-- For our project validation rule :- 18–75 years:
SELECT * FROM insurance.customers
WHERE age >= 18
	AND age <= 75;

SELECT * FROM insurance.customers WHERE age < 18 OR age > 75;


-- Check missing Customer IDs
SELECT COUNT(*) AS missing_customer_id_
FROM insurance.customers
WHERE customer_id = Null;


-- Check invalid premiums
SELECT * FROM insurance.policies
WHERE premium <= 0;


-- Check invalid sum insured
SELECT * FROM insurance.policies
WHERE sum_insured <= 0;


-- Check policy date errors
SELECT * FROM insurance.policies
WHERE policy_start > policy_end;


-- Check invalid claim amounts
SELECT * FROM insurance.claims
WHERE claim_amount <= 0;


--  Check approved amount > claim amount
SELECT * FROM insurance.claims
WHERE approved_amount > claim_amount;


-- Check fraud score
SELECT * FROM insurance.claims
WHERE fraud_score < 0 AND fraud_score < 100;


                          -- PART E — RELATIONSHIP VALIDATION + FOREIGN KEYS

-- Policies with missing customers
SELECT p.*
FROM insurance.policies p
LEFT JOIN
insurance.customers c
ON p.customer_id = c.customer_id
WHERE c.customer_id = NULL;


-- Claims with missing policies
SELECT c.*
FROM insurance.claims c
LEFT JOIN
insurance.policies p
ON c.policy_id = p.policy_id
WHERE p.policy_id = Null;


-- Claims with missing customers
SELECT c.*
FROM insurance.claims c
LEFT JOIN
insurance.customers cu
ON c.customer_id = cu.customer_id
WHERE cu.customer_id = Null;


-- Policies with missing agents
SELECT p.*
FROM insurance.policies p
LEFT JOIN
insurance.agents a
ON p.agent_id = a.agent_id
WHERE a.agent_id = Null;


-- Once you've confirmed the data is valid, create foreign keys.

-- Policies → Customers
ALTER TABLE insurance.policies
ADD CONSTRAINT fk_policy_customer
FOREIGN KEY (customer_id)
REFERENCES insurance.customers(customer_id);


-- Claims → Policies
ALTER TABLE insurance.claims
ADD CONSTRAINT fk_claim_policy
FOREIGN KEY (policy_id)
REFERENCES insurance.policies(policy_id);


-- Policies → Agents
ALTER TABLE insurance.policies
ADD CONSTRAINT fk_policy_agent
FOREIGN KEY (agent_id)
REFERENCES insurance.agents(agent_id);


			-- Database Model
-- Your PostgreSQL database will now represent:

    --                 CUSTOMERS
    --               Customer_ID
    --                    │
    --          ┌─────────┴─────────┐
    --          │                   │
    --          ▼                   ▼
    --      POLICIES            COMPLAINTS
    --    Policy_ID             Complaint_ID
    --          │
    --     ┌────┴─────┐
    --     │          │
    --     ▼          ▼
    --  CLAIMS      AGENTS
    -- Claim_ID    Agent_ID


	-- This is the foundation for your Power BI model later.


						-- PART F — BASIC INSURANCE BUSINESS QUESTIONS
-- Now we start the actual analysis.


 -- Q1. How many customers are in the database?
 SELECT COUNT(*) AS total_customer
 FROM insurance.customers;
-- Business meaning: Measures the customer base.


-- Q2. How many policies exist?
SELECT COUNT(*) AS total_policies
FROM insurance.policies;
-- Business meaning: Measures policy volume.


-- Q3.  What is the total premium?
SELECT ROUND(SUM(premium),2) AS total_premium
FROM insurance.policies;
-- Business meaning: Shows total premium represented by the portfolio.


-- Q4. What is the average premium?
SELECT ROUND(AVG(premium),2) AS Avg_premium
FROM insurance.policies;
-- Business meaning: Shows the typical policy premium.


-- Q5. Which products have the most policies?
SELECT product, COUNT(*) AS policy_count
FROM insurance.policies
GROUP BY product
ORDER BY policy_count DESC;
-- Business meaning: Identifies high-volume products.


-- Q6. Which products generate the most premium?
SELECT product, ROUND(SUM(premium),2) AS Highest_premium
FROM insurance.policies
GROUP BY product
ORDER BY Highest_premium DESC;
-- Business meaning: Identifies products contributing most premium.


-- Q7. Which states have the most customers?
SELECT state, COUNT(*) AS Total_customer
FROM insurance.customers
GROUP BY state
ORDER BY Total_customer DESC;
-- Business meaning: Highlights geographic concentration.


-- Q8. How are customers distributed by segment?
SELECT customer_segment, COUNT(*) AS Customer_count
FROM insurance.customers
GROUP BY customer_segment
ORDER BY Customer_count DESC;
-- Business meaning: Shows customer-segment mix.


-- Q9. Which customer segment generates the most premium?
SELECT c.customer_segment, ROUND(SUM(p.premium),2) AS Total_premium
FROM insurance.customers c
JOIN
insurance.policies p
ON c.customer_id = p.customer_id
GROUP BY c.customer_segment
ORDER BY Total_premium DESC;
-- Business meaning: Links customer characteristics to premium.


					-- PART G — CLAIMS + FRAUD ANALYSIS

-- Q10. How many claims have been filed?
SELECT COUNT(*) AS Total_claim
FROM insurance.claims;
-- Business meaning: Measures claim volume.


-- Q11. What is the total claim amount?
SELECT ROUND(SUM(claim_amount),2) AS Total_claim_amt
FROM insurance.claims;
-- Business meaning: Measures total reported claim exposure.


-- Q12. What is the total approved amount?
SELECT ROUND(SUM(approved_amount),2) AS Total_approved_amt
FROM insurance.claims;
-- Business meaning: Measures approved claim value.


-- Q13. What is the average claim amount?
SELECT ROUND(AVG(claim_amount),2) AS Avg_claim_amt
FROM insurance.claims;
-- Business meaning: Measures claim severity.


-- Q14. How many claims exist by status?
SELECT claim_status, COUNT(*) AS claim_count
FROM insurance.claims
GROUP BY claim_status
ORDER BY claim_count DESC;
-- Business meaning: Shows settled, rejected, pending and investigation workload.


-- Q15.  Which claim types have the highest claim value?
SELECT claim_type, COUNT(*) AS claim_count,
		ROUND(SUM(claim_amount),2) AS Total_claim_amt
FROM insurance.claims
GROUP BY claim_type
ORDER BY Total_claim_amt DESC;
-- Business meaning: Highlights costly claim categories.


-- Q16. Which products have the highest claim amounts?
SELECT p.product, COUNT(c.claim_id) AS Claim_count,
		ROUND(SUM(c.claim_amount),2) AS Total_claim_amt
FROM insurance.policies p
JOIN 
insurance.claims c 
ON c.policy_id = p.policy_id
GROUP BY p.product
ORDER BY Total_claim_amt DESC;
-- Business meaning: Links claims to products.


-- Q17. What is the fraud-risk distribution?
SELECT fraud_risk, COUNT(*) AS Claim_count
FROM insurance.claims
GROUP BY fraud_risk
ORDER BY Claim_count DESC;
-- Business meaning: Shows the fraud-risk mix.


-- Q18. Which claims are high risk?
SELECT claim_id, policy_id, customer_id, claim_amount, 
claim_status, fraud_score, fraud_risk 
FROM insurance.claims
WHERE fraud_risk = 'High Risk'
ORDER BY fraud_score DESC;
-- Business meaning: Creates an investigation-priority list.


-- Q19. What is the total value of high-risk claims?
SELECT ROUND(SUM(claim_amount),2) AS High_risk_claims_amt
FROM insurance.claims
WHERE fraud_risk = 'High Risk';
-- Business meaning: Estimates exposure among high-risk claims.


-- Q20. Which providers have the most claims?
SELECT provider, COUNT(*) AS claim_count
FROM insurance.claims
GROUP BY provider
ORDER BY claim_count DESC;
-- Business meaning: Identifies providers with high claim activity.


-- Q21. Which providers have the highest claim amount?
SELECT provider, ROUND(SUM(claim_amount),2) AS Total_claim_amt
FROM insurance.claims
GROUP BY provider
ORDER BY Total_claim_amt DESC LIMIT 3;
-- Business meaning: Highlights provider-level claim exposure.


-- Q22. What is average claim settlement time?
SELECT ROUND(AVG(settlement_date - claim_date),2) AS Avg_Settlement_Days
FROM insurance.claims
ORDER BY Avg_Settlement_Days;

SELECT ROUND(AVG(settlement_date - claim_date),2) AS avg_settlement_days
FROM insurance.claims
WHERE settlement_date IS NOT NULL;
-- Business meaning: Measures claims-service speed.


-- Q23. Which claim types take longest to settle?
SELECT claim_type, ROUND(AVG(settlement_date - claim_date),2) AS Avg_settlement_Days
FROM insurance.claims
WHERE settlement_date IS NOT NULL
GROUP BY claim_type
ORDER BY Avg_settlement_Days DESC;
-- Business meaning: Identifies slow claim categories.


-- Q24. Which customers have multiple claims?
SELECT customer_id, COUNT(*) AS Claim_count
FROM insurance.claims
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY Claim_count DESC;
-- Business meaning: Finds repeat claimants for risk review.


-- Q25. Which claims occurred within 30 days of policy start?
SELECT c.customer_id, c.policy_id, c.claim_id, c.claim_type, c.claim_date,
		p.policy_start, (c.claim_date - p.policy_start) AS Days_after_start
FROM insurance.claims c
JOIN
insurance.policies p
ON c.policy_id = p.policy_id
WHERE (claim_date - policy_start) <= 30
ORDER BY Days_after_start LI;
-- Business meaning: Flags cases for investigation; it does not prove fraud.


										-- PART H — RENEWAL + CHANNEL ANALYSIS

-- Q26. What is the renewal distribution?
SELECT renewal_status, COUNT(*) AS policy_count
FROM insurance.policies
GROUP BY renewal_status
ORDER BY policy_count;
-- Business meaning: Shows renewed vs not renewed policies.


-- 	Q27. What is the overall renewal rate?
SELECT ROUND(
    100.0 * COUNT(*) FILTER (WHERE renewal_status = 'Renewed') / COUNT(*), 2
) AS renewal_rate
FROM insurance.policies;

SELECT ROUND(
    100.0 * SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) / COUNT(*),
    2
) AS renewal_rate
FROM insurance.policies;

--                  Renewed policies
-- Renewal Rate = ---------------------- × 100
--                  Total policies

-- Business meaning: Measures customer retention at policy level.


-- Q28. What is renewal rate by product?
SELECT product, ROUND(
		100.0 * SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) / COUNT(*),2
) AS renewal_rate
FROM insurance.policies
GROUP BY product
ORDER BY renewal_rate DESC;
-- ┌─────────────────────────────────────────────┐
-- │          RENEWAL RATE BY PRODUCT            │
-- ├─────────────────────────────────────────────┤
-- │                                             │
-- │                  Renewed Policies           │
-- │ Renewal Rate = ───────────────── × 100      │
-- │                   Total Policies            │
-- │                                             │
-- │ CASE WHEN Renewed → 1                       │
-- │              Else → 0                       │
-- │                                             │
-- │ SUM(1s) = Renewed Policies                  │
-- │ COUNT(*) = Total Policies                   │
-- │                                             │
-- │ GROUP BY product → Each product separately  │
-- │ ROUND(...,2)    → 2 decimal places          │
-- │ ORDER BY DESC   → Highest → Lowest          │
-- │                                             │
-- └─────────────────────────────────────────────┘
-- Business meaning: Identifies products with stronger retention.


-- Q29. What is renewal rate by channel?
SELECT channel, 
		ROUND(100.0 * SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) / COUNT(*),2)
AS renewal_rate
FROM insurance.policies
GROUP BY channel
ORDER BY renewal_rate DESC;
-- Business meaning: Compares retention across acquisition/service channels.


-- Q30. Which channels have the most policies?
SELECT channel, COUNT(*) AS policy_count
FROM insurance.policies
GROUP BY channel
ORDER BY policy_count DESC;
-- Business meaning: Shows channel volume.


									-- PART I — AGENT PERFORMANCE

-- Q31. Which agents generate the most premium?
SELECT agent_id, agent_name, 
		ROUND(SUM(premium_generated),2) AS Total_premium
FROM insurance.agents
GROUP BY agent_id, agent_name
ORDER BY Total_premium DESC LIMIT 5;

SELECT agent_id, ROUND(SUM(premium),2) AS total_premium
FROM insurance.policies
GROUP BY agent_id
ORDER BY total_premium DESC
LIMIT 5;
-- Business meaning: Identifies top premium-producing agents.


-- Q32. Which agents sell the most policies?
SELECT agent_id, COUNT(*) AS Total_policies_sold
FROM insurance.policies
GROUP BY agent_id
ORDER BY Total_policies_sold DESC LIMIT 5;

SELECT agent_id, ROUND(
		SUM(policies_sold),0
) AS Total_policies_sold
FROM insurance.agents
GROUP BY agent_id
ORDER BY Total_policies_sold DESC LIMIT 5;

SELECT agent_id, policies_sold AS total_policies_sold
FROM insurance.agents
ORDER BY policies_sold DESC LIMIT 5;
-- Business meaning: Identifies high-volume agents.


-- Q33. Which agents have the best renewal rate?
SELECT agent_id, COUNT(*) AS Total_policies,
		SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) AS Renewed_policies,
	ROUND(100.0 * SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) / COUNT(*),2)
AS Renewal_rate
FROM insurance.policies
GROUP BY agent_id
HAVING COUNT(*) >= 50
ORDER BY Renewal_rate DESC;

SELECT agent_id,   																								
       COUNT(*) AS total_policies,
       COUNT(*) FILTER (WHERE renewal_status='Renewed') AS renewed_policies,
       ROUND(100.0 * COUNT(*) FILTER (WHERE renewal_status='Renewed') / COUNT(*),2) AS renewal_rate
FROM insurance.policies
GROUP BY agent_id
HAVING COUNT(*) >= 50
ORDER BY renewal_rate DESC LIMIT 5;

-- ┌─────────────────────────────────────────────────────────────┐  
-- │              RENEWAL RATE BY AGENT — MySQL                  │
-- ├─────────────────────────────────────────────────────────────┤
-- │                                                             │
-- │                    Renewed Policies                         │
-- │ Renewal Rate = ───────────────────── × 100                  │
-- │                     Total Policies                          │
-- │                                                             │
-- │ CASE WHEN renewal_status = 'Renewed' → 1                    │
-- │ ELSE → 0                                                    │
-- │                                                             │
-- │ SUM(1s)       = Renewed Policies                            │
-- │ COUNT(*)      = Total Policies                              │
-- │                                                             │
-- │ GROUP BY agent_id                                           │
-- │ → Calculate results for each agent separately               │
-- │                                                             │
-- │ HAVING COUNT(*) >= 50                                       │
-- │ → Only agents with at least 50 policies                     │
-- │                                                             │
-- │ ROUND(..., 2)                                               │
-- │ → Round renewal rate to 2 decimal places                    │
-- │                                                             │
-- │ ORDER BY renewal_rate DESC                                  │
-- │ → Highest renewal rate → Lowest renewal rate                │
-- │                                                             │
-- │ MySQL uses CASE WHEN instead of FILTER                      │
-- │                                                             │
-- └─────────────────────────────────────────────────────────────┘

-- ┌─────────────────────────────────────────────────────────────┐
-- │           RENEWAL RATE BY AGENT — PostgreSQL                │
-- ├─────────────────────────────────────────────────────────────┤
-- │                                                             │
-- │                    Renewed Policies                         │
-- │ Renewal Rate = ───────────────────── × 100                  │
-- │                     Total Policies                          │
-- │                                                             │
-- │ COUNT(*) FILTER                                             │
-- │ (WHERE renewal_status = 'Renewed')                          │
-- │                                                             │
-- │ → Count only policies where status = 'Renewed'              │
-- │                                                             │
-- │ COUNT(*)      = Total Policies                              │
-- │                                                             │
-- │ GROUP BY agent_id                                           │
-- │ → Calculate results for each agent separately               │
-- │                                                             │
-- │ HAVING COUNT(*) >= 50                                       │
-- │ → Only agents with at least 50 policies                     │
-- │                                                             │
-- │ ROUND(..., 2)                                               │
-- │ → Round renewal rate to 2 decimal places                    │
-- │                                                             │
-- │ ORDER BY renewal_rate DESC                                  │
-- │ → Highest renewal rate → Lowest renewal rate                │
-- │                                                             │
-- │ PostgreSQL uses FILTER to count conditional rows            │
-- │                                                             │
-- └─────────────────────────────────────────────────────────────┘
-- Business meaning: Controls for very small samples when ranking agents.


-- Q34. Which agents have high premium but low renewal?
SELECT agent_id,
       ROUND(SUM(premium),2) AS total_premium,
       ROUND(100.0 * COUNT(*) FILTER (WHERE renewal_status='Renewed') / COUNT(*),2) AS renewal_rate
FROM insurance.policies
GROUP BY agent_id
HAVING SUM(premium) > 500000
   AND 100.0 * COUNT(*) FILTER (WHERE renewal_status='Renewed') / COUNT(*) < 75
ORDER BY total_premium DESC LIMIT 5;
-- ┌────────────────────────────────────────────────────┐
-- │           Q34 — HIGH PREMIUM, LOW RENEWAL          │
-- ├────────────────────────────────────────────────────┤
-- │                                                    │
-- │ For each agent:                                    │
-- │                                                    │
-- │ 1. Add all premiums                                │
-- │    SUM(premium) → Total Premium                    │
-- │                                                    │
-- │ 2. Calculate renewal rate                          │
-- │    Renewed Policies / Total Policies × 100         │
-- │                                                    │
-- │ 3. Keep only agents where:                         │
-- │    Total Premium > 500,000                         │
-- │    AND                                             │
-- │    Renewal Rate < 70%                              │
-- │                                                    │
-- │ 4. Sort by total premium                           │
-- │    Highest → Lowest                                │
-- │                                                    │
-- └────────────────────────────────────────────────────┘
-- Business meaning: Finds high-value agents needing retention support.


-- Q35. Which agents have high total premium and a high renewal rate?
SELECT agent_id,
	   ROUND(SUM(premium),2) AS Total_premium,
	   ROUND(100.0 * COUNT(*) FILTER (WHERE renewal_status='Renewed') / COUNT(*),2) AS Renewal_rate
FROM insurance.policies
GROUP BY agent_id
HAVING SUM(premium) > 1200000
	   AND 100.0 * COUNT(*) FILTER (WHERE renewal_status='Renewed') / COUNT(*) > 80
ORDER BY Total_premium DESC;
-- ┌─────────────────────────────────────────────────────┐
-- │          HIGH PREMIUM + HIGH RENEWAL                │
-- ├─────────────────────────────────────────────────────┤
-- │                                                     │
-- │                 For each agent                      │
-- │                       │                             │
-- │          ┌────────────┴────────────┐                │
-- │          ▼                         ▼                │
-- │    SUM(premium)              Renewal Rate           │
-- │          │                         │                │
-- │          ▼                         ▼                │
-- │      > 1,200,000                  > 80%             │
-- │          │                         │                │
-- │          └────────────┬────────────┘                │
-- │                       ▼                             │
-- │                 Both conditions                     │
-- │                       │                             │
-- │                       ▼                             │
-- │              High-performing agents                 │
-- │                                                     │
-- │ ORDER BY Total_premium DESC                         │
-- │ → Highest premium → Lowest premium                  │
-- │                                                     │
-- └─────────────────────────────────────────────────────┘


										-- PART J — COMPLAINT ANALYSIS

-- Q36. How many complaints exist?
SELECT COUNT(*) AS Total_complaints
FROM insurance.complaints;
-- Business meaning: Measures complaint volume.


-- Q37. Which complaint types are most common?
SELECT complaint_type, COUNT(*) AS Complaint_count
FROM insurance.complaints
GROUP BY complaint_type
ORDER BY Complaint_count DESC;
-- Business meaning: Identifies recurring customer-service issues.


-- Q38. Which channels generate the most complaints?
SELECT channel, COUNT(*) AS Complaint_count
FROM insurance.complaints
GROUP BY channel
ORDER BY Complaint_count DESC;
-- Business meaning: Shows where complaints are concentrated.


-- Q39. How many complaints are still open?
SELECT resolution_status, COUNT(*) AS Open_complaints
FROM insurance.complaints
GROUP BY resolution_status
HAVING resolution_status = 'Open'
ORDER BY Open_complaints;

SELECT COUNT(*) AS Open_complaints
FROM insurance.complaints
WHERE resolution_status = 'Open';
-- Business meaning: Measures unresolved service workload.


-- Q40 What is average complaint resolution time?
SELECT ROUND(
	   AVG(resolution_date - complaint_date),2
) AS Avg_resolution_day
FROM insurance.complaints
WHERE resolution_date IS NOT NULL;
-- Business meaning: Measures complaint-handling speed.


-- Q41. Which complaint types take longest to resolve?
SELECT complaint_type,
	   ROUND(AVG(resolution_date - complaint_date),2) AS Avg_resolution_days
FROM insurance.complaints
WHERE resolution_date IS NOT NULL
GROUP BY complaint_type
ORDER BY Avg_resolution_days DESC;
-- Business meaning: Identifies slow complaint categories.


									-- PART K — ADVANCED POSTGRESQL
									
-- Q42. What is the monthly premium trend?
SELECT DATE_TRUNC('month', policy_start) :: DATE AS month,
	   ROUND(SUM(premium),2) AS total_premium
FROM insurance.policies
GROUP BY 1
ORDER BY 1;
-- ┌──────────────────────────────────────┐
-- │ SELECT → What do we want?            │
-- │ month + total_premium                │
-- ├──────────────────────────────────────┤
-- │ DATE_TRUNC → Get month               │
-- │ ::DATE → Convert to date             │
-- │ SUM → Add premiums                   │
-- │ ROUND → 2 decimal places             │
-- ├──────────────────────────────────────┤
-- │ FROM → Where?                        │
-- │ insurance.policies                   │
-- ├──────────────────────────────────────┤
-- │ GROUP BY 1 → Group by month          │
-- ├──────────────────────────────────────┤
-- │ ORDER BY 1 → Sort by month           │
-- └──────────────────────────────────────┘
-- Business meaning: Power BI-ready monthly premium trend.


-- Q43. What is the monthly claims trend?
SELECT DATE_TRUNC('month', claim_date) :: DATE AS month,
	   COUNT(*) AS claim_count,
	   ROUND(SUM(claim_amount),2) AS total_claim_amt
FROM insurance.claims
GROUP BY 1
ORDER BY 1;
-- Business meaning: Power BI-ready monthly claims trend.


-- Q44. Rank agents by premium
SELECT agent_id,
       ROUND(SUM(premium),2) AS total_premium,
       RANK() OVER (ORDER BY SUM(premium) DESC) AS premium_rank
FROM insurance.policies
GROUP BY agent_id
ORDER BY premium_rank;
-- Business meaning: Demonstrates a window function.


-- Q45. Highest claim in each product
SELECT p.product,
	   ROUND(SUM(c.claim_amount),2) AS total_claim_amt
FROM insurance.claims c
JOIN
insurance.policies p
ON c.policy_id = p.policy_id
GROUP BY p.product
ORDER BY total_claim_amt DESC;

WITH ranked_claims AS (
    SELECT p.product, cl.claim_id, cl.claim_amount,
           ROW_NUMBER() OVER (
               PARTITION BY p.product
               ORDER BY cl.claim_amount DESC
           ) AS rn
    FROM insurance.claims cl
    JOIN insurance.policies p ON cl.policy_id = p.policy_id
)
SELECT product, claim_id, claim_amount
FROM ranked_claims
WHERE rn = 1
ORDER BY claim_amount DESC;
-- Business meaning: Demonstrates CTE + JOIN + ROW_NUMBER.


-- Q46. High-value customers with multiple claims
SELECT c.customer_id,
       c.customer_segment,
       SUM(DISTINCT p.premium) AS total_premium,
       COUNT(DISTINCT cl.claim_id) AS claim_count
FROM insurance.customers c
JOIN insurance.policies p ON c.customer_id = p.customer_id
LEFT JOIN insurance.claims cl ON p.policy_id = cl.policy_id
GROUP BY c.customer_id, c.customer_segment
HAVING SUM(DISTINCT p.premium) > 100000
   AND COUNT(DISTINCT cl.claim_id) >= 2
ORDER BY total_premium DESC;
-- Business meaning: Identifies high-value customers with repeat claim activity.


-- Q47. Top customers by premium
SELECT c.customer_id, c.age, c.state,
       ROUND(SUM(p.premium),2) AS total_premium
FROM insurance.customers c
JOIN insurance.policies p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.age, c.state
ORDER BY total_premium DESC
LIMIT 10;
-- Business meaning: Creates a high-value customer list.
