--Q3
-- add line numbers and amend "u" (for Ursa) to 
-- end to indicate that this was added internally.  
WITH line_numbers AS (
  SELECT *
         ,ROW_NUMBER() OVER (
           PARTITION BY claim_num
           ORDER BY proc_cd, trxdt
         ) || 'u' AS new_line_num
  FROM raw_claim_data
)
SELECT 
 member_num || '_' || claim_num AS transaction_id
,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '') || '_L' || new_line_num AS claim_service_line_item_id
,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '') AS claim_header_id
,paid_amt
FROM line_numbers
ORDER BY claim_service_line_item_id;


-- Q5
-- Link for example of using Python to loop through a list of claim numbers
-- https://github.com/dataanalyticsfox/Zombie_Eligibility/blob/main/zombie_eligibility.py
SELECT 
LEFT(TO_VARCHAR(claim_num), 11) AS claim_number
,COUNT(CASE WHEN line_num IS NULL THEN 1 END) AS null_count
,COUNT(CASE WHEN line_num IS NOT NULL THEN 1 END) AS non_null_count
FROM raw_claim_data
WHERE LEFT(claim_number, 11) IN ('7352E795832', '4835Y583761')
GROUP BY claim_number;



