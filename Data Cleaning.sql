# Data Cleaning
# Identifying and deleting duplicates if any

SELECT *
FROM borrower_profiles;

SELECT borrower_id, COUNT(*)
FROM borrower_profiles 
GROUP BY borrower_id
HAVING COUNT(*) >1 ;

SELECT loan_id, COUNT(*)
FROM loan_applications 
GROUP BY loan_id
HAVING COUNT(*) >1 ;

#Finding Duplicates
SELECT borrower_id
FROM 
(SELECT borrower_id, ROW_NUMBER() OVER(PARTITION BY borrower_id ORDER BY borrower_id) AS duplicates
FROM borrower_profiles) AS subquery1
WHERE duplicates > 1
;

SELECT *
FROM 
(SELECT loan_id, ROW_NUMBER() OVER(PARTITION BY loan_id ORDER BY loan_id) duplicates
FROM loan_applications) AS subquery
WHERE duplicates > 1
; 

#No duplicates found. If they existed we could: 

SET SQL_SAFE_UPDATES = 0 ;
DELETE FROM borrower_profiles
WHERE borrower_id IN (SELECT borrower_id
					 FROM 
					 (SELECT borrower_id, ROW_NUMBER() OVER(PARTITION BY borrower_id ORDER BY borrower_id) AS duplicates
					 FROM borrower_profiles) AS subquery1
					 WHERE duplicates <> 1 )
;
SET SQL_SAFE_UPDATES = 1;

#There's one catch: It'll delete ALL borrower ID which has duplicates, even the ID itself. 
#Solution? Copy only DISTINCT values from this table, empty the table and fill it back in with these distinct values. 
----- CREATE TABLE temp_borrower_profiles AS
----- SELECT DISTINCT * FROM borrower_profiles;

----- Delete table:  TRUNCATE TABLE borrower_profiles;
----- INSERT INTO borrower_profiles SELECT * FROM temp_borrower_profiles;
----- DROP TABLE temp_borrower_profiles;

#Identifying identical twin duplicates with multiple factors Using Window Functions: 
SELECT * 
FROM 
	   (SELECT *,
			   COUNT(*) OVER(PARTITION BY borrower_id, application_date, loan_purpose, loan_amount ORDER BY borrower_id) count
		FROM loan_default_risk_analysis.loan_applications) AS subquery1
WHERE count > 1
ORDER BY borrower_id, application_date
;

#Identifying out of normal items
SELECT *
FROM borrower_profiles
WHERE age >= 100 ;

SELECT *
FROM borrower_profiles
WHERE home_ownership NOT IN ('Rent','Own','Mortgage');

SELECT *
FROM borrower_profiles
WHERE dependents >= 4;

SELECT borrower_id, COUNT(*) AS Loan_Count
FROM loan_applications
WHERE loan_status LIKE 'Active'
GROUP BY borrower_id
HAVING Loan_Count >= 3
;

SELECT *
FROM loan_applications
WHERE borrower_id IS NULL;

SELECT COUNT(*)
FROM loan_applications;

SELECT COUNT(DISTINCT borrower_id)
FROM loan_applications;


