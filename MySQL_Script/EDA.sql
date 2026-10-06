#Exploratory Data Analysis

SELECT ROUND(SUM(defaulted)/NULLIF(COUNT(*),0) * 100,2) AS Default_Rate
FROM loan_applications
;

SELECT 
		(SELECT COUNT(*) AS danger_profiles
		FROM loan_applications
		WHERE dti_ratio >= 100) / COUNT(*) * 100 AS Highly_Risky_Lending_Ratio
FROM loan_applications
;


SELECT Credit_Bucket, ROUND(SUM(defaulted)/NULLIF(COUNT(*),0) * 100,2) AS Default_Rate
FROM (
		SELECT loan_id, loan.borrower_id, defaulted,
			  CASE WHEN credit_score <= 579 THEN '300-579'
				   WHEN credit_score <= 669 THEN '580-669'
				   WHEN credit_score <= 739 THEN '670-739'
				   WHEN credit_score <= 799 THEN '740-799'
				   ELSE '800-850'
				   END AS Credit_Bucket
		FROM loan_applications loan
		JOIN borrower_profiles borr
		 ON loan.borrower_id = borr.borrower_id
         ) AS subquery
GROUP BY Credit_Bucket
ORDER BY Credit_Bucket
;

SELECT employment_status, ROUND(SUM(defaulted)/NULLIF(COUNT(*),0) * 100,2) AS Default_Rate
FROM loan_applications loan
JOIN borrower_profiles borr
     ON loan.borrower_id = borr.borrower_id
GROUP BY employment_status
ORDER BY Default_Rate DESC
;

SELECT loan_purpose, ROUND(SUM(defaulted)/NULLIF(COUNT(*),0) * 100,2) AS Default_Rate
FROM loan_applications loan
JOIN borrower_profiles 
GROUP BY loan_purpose
ORDER BY Default_Rate DESC
;

SELECT `Debt-to-Income Ratio`, ROUND(SUM(defaulted)/NULLIF(COUNT(*),0) * 100,2) AS Default_Rate
FROM 	(
            SELECT *, 
				   CASE WHEN `Debt-to-Income Ratio` = '20 & Below%' THEN 1
				   WHEN `Debt-to-Income Ratio` = '21-35%' THEN 2
				   WHEN `Debt-to-Income Ratio` = '36-43%' THEN 3
				   WHEN `Debt-to-Income Ratio` = '44-50%' THEN 4
				   WHEN `Debt-to-Income Ratio` = '51-100%' THEN 5
				   WHEN `Debt-to-Income Ratio` = '101-150%' THEN 6
				   ELSE 7
				   END AS bucket_order
				   
			FROM (          SELECT dti_ratio, defaulted ,
							CASE WHEN dti_ratio < 20 THEN '20 & Below%'
							WHEN dti_ratio <= 35 THEN '21-35%'
							WHEN dti_ratio <= 43 THEN '36-43%'
							WHEN dti_ratio <=50 THEN '44-50%'
							WHEN dti_ratio <= 100 THEN '51-100%'
							WHEN dti_ratio <= 150 THEN '101-150%'
							ELSE '151% & Above'
							END AS 'Debt-to-Income Ratio' 
						    FROM loan_applications     ) AS subquery1 
		    ) subquery2
GROUP BY `Debt-to-Income Ratio`
ORDER BY bucket_order
;

SELECT 
    CASE 
        WHEN interest_rate < 5 THEN 'Below 5%'
        WHEN interest_rate < 7 THEN '5-6%'       
        WHEN interest_rate < 9 THEN '7-8%'      
        WHEN interest_rate < 11 THEN '9-10%'
        WHEN interest_rate < 13 THEN '11-12%'
        WHEN interest_rate < 14 THEN '13-14%'
        WHEN interest_rate <= 15 THEN '14-15%'
        ELSE '15% & Above'
    END AS `Interest Rate Range`,
    
    ROUND(AVG(interest_rate_table.defaulted) * 100, 2) AS Default_Rate

FROM loan_applications AS interest_rate_table
WHERE interest_rate IS NOT NULL 
GROUP BY `Interest Rate Range`
ORDER BY 
    MIN(interest_rate) ASC;



WITH correlation_data AS (
    SELECT 
        -- === Variables from borrower_profiles (bp) ===
        -- 1. Credit Score
        ROUND((COUNT(*) * SUM(bp.credit_score * la.defaulted) - SUM(bp.credit_score) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(bp.credit_score, 2)) - POW(SUM(bp.credit_score), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_credit_score,

        -- 2. Annual Income
        ROUND((COUNT(*) * SUM(bp.annual_income * la.defaulted) - SUM(bp.annual_income) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(bp.annual_income, 2)) - POW(SUM(bp.annual_income), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_annual_income,

        -- 3. Age
        ROUND((COUNT(*) * SUM(bp.age * la.defaulted) - SUM(bp.age) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(bp.age, 2)) - POW(SUM(bp.age), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_age,

        -- 4. Years Employed
        ROUND((COUNT(*) * SUM(bp.years_employed * la.defaulted) - SUM(bp.years_employed) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(bp.years_employed, 2)) - POW(SUM(bp.years_employed), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_years_employed,

        -- 5. Dependents
        ROUND((COUNT(*) * SUM(bp.dependents * la.defaulted) - SUM(bp.dependents) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(bp.dependents, 2)) - POW(SUM(bp.dependents), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_dependents,

        -- 6. Existing Monthly Debt
        ROUND((COUNT(*) * SUM(bp.existing_monthly_debt * la.defaulted) - SUM(bp.existing_monthly_debt) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(bp.existing_monthly_debt, 2)) - POW(SUM(bp.existing_monthly_debt), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_existing_monthly_debt,


        -- === Variables from loan_applications (la) ===
        -- 7. DTI Ratio
        ROUND((COUNT(*) * SUM(la.dti_ratio * la.defaulted) - SUM(la.dti_ratio) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(la.dti_ratio, 2)) - POW(SUM(la.dti_ratio), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_dti,

        -- 8. Loan Amount
        ROUND((COUNT(*) * SUM(la.loan_amount * la.defaulted) - SUM(la.loan_amount) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(la.loan_amount, 2)) - POW(SUM(la.loan_amount), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_loan_amount,

        -- 9. Interest Rate
        ROUND((COUNT(*) * SUM(la.interest_rate * la.defaulted) - SUM(la.interest_rate) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(la.interest_rate, 2)) - POW(SUM(la.interest_rate), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_interest_rate,

        -- 10. Term Months
        ROUND((COUNT(*) * SUM(la.term_months * la.defaulted) - SUM(la.term_months) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(la.term_months, 2)) - POW(SUM(la.term_months), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_term_months,

        -- 11. Monthly Payment
        ROUND((COUNT(*) * SUM(la.monthly_payment * la.defaulted) - SUM(la.monthly_payment) * SUM(la.defaulted)) /
        (SQRT(COUNT(*) * SUM(POW(la.monthly_payment, 2)) - POW(SUM(la.monthly_payment), 2)) * 
         SQRT(COUNT(*) * SUM(POW(la.defaulted, 2)) - POW(SUM(la.defaulted), 2))), 2) AS corr_monthly_payment

    FROM loan_applications la
    JOIN borrower_profiles bp ON la.borrower_id = bp.borrower_id
    -- Clears out incomplete records to ensure mathematical consistency
    WHERE la.defaulted IS NOT NULL
      AND bp.credit_score IS NOT NULL 
      AND bp.annual_income IS NOT NULL 
      AND bp.age IS NOT NULL
      AND bp.years_employed IS NOT NULL
      AND bp.dependents IS NOT NULL
      AND bp.existing_monthly_debt IS NOT NULL
      AND la.dti_ratio IS NOT NULL 
      AND la.loan_amount IS NOT NULL 
      AND la.interest_rate IS NOT NULL
      AND la.term_months IS NOT NULL
      AND la.monthly_payment IS NOT NULL
),
unpivoted_data AS (
    SELECT 'credit_score' AS metric, corr_credit_score AS correlation FROM correlation_data
    UNION ALL
    SELECT 'annual_income', corr_annual_income FROM correlation_data
    UNION ALL
    SELECT 'age', corr_age FROM correlation_data
    UNION ALL
    SELECT 'years_employed', corr_years_employed FROM correlation_data
    UNION ALL
    SELECT 'dependents', corr_dependents FROM correlation_data
    UNION ALL
    SELECT 'existing_monthly_debt', corr_existing_monthly_debt FROM correlation_data
    UNION ALL
    SELECT 'dti_ratio', corr_dti FROM correlation_data
    UNION ALL
    SELECT 'loan_amount', corr_loan_amount FROM correlation_data
    UNION ALL
    SELECT 'interest_rate', corr_interest_rate FROM correlation_data
    UNION ALL
    SELECT 'term_months', corr_term_months FROM correlation_data
    UNION ALL
    SELECT 'monthly_payment', corr_monthly_payment FROM correlation_data
)
SELECT 
    metric, 
    correlation,
    CASE 
        WHEN correlation > 0 THEN 'Positive'
        WHEN correlation < 0 THEN 'Negative'
        ELSE 'Zero'
    END AS correlation_type
FROM unpivoted_data
ORDER BY ABS(correlation) DESC;
