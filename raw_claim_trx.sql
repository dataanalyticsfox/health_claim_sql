-- Q1
-- dedup with final claim amount. 
-- Final action for this claim is $266.70
WITH dedup_claim AS (
    SELECT *
    FROM (
        SELECT *
               ,ROW_NUMBER() OVER (
                   PARTITION BY member_num, claim_num, line_num, proc_cd
                   ORDER BY trxdt
               ) AS rn
        FROM raw_claim_trx
    )
    WHERE rn = 1
)
SELECT SUM(paid_amt) as final_amount
FROM dedup_claim
;

-- Dedup claim with total final action for each service line
WITH dedup_claim AS (
    SELECT *
    FROM (
        SELECT *
               ,ROW_NUMBER() OVER (
                   PARTITION BY member_num, claim_num, line_num, proc_cd
                   ORDER BY trxdt
               ) AS rn
        FROM raw_claim_trx
    )
    WHERE rn = 1
)
SELECT 
  line_num
  ,SUM(paid_amt) AS final_paid_amt
FROM dedup_claim
GROUP BY line_num
ORDER BY line_num;
;

-- Q2
-- Transaction ID is unique to every row in a claim to record the original, reverse, and amended claim numbers.
-- Claim service line ID is identifying what line numbers (or services) are the same in a claim. Add "L" for Line.
-- Claim Header is matching the member to the claim for aggregate header level data.
WITH dedup_claim AS (
    SELECT *
    FROM (
        SELECT *
               ,ROW_NUMBER() OVER (
                   PARTITION BY member_num, claim_num, line_num, proc_cd
                   ORDER BY trxdt
               ) AS rn
        FROM raw_claim_trx
    )
    WHERE rn = 1
)
SELECT 
     member_num || '_' || claim_num || '_L' || line_num AS transaction_id
    ,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '') || '_L' || line_num AS claim_service_line_item_id
    ,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '')  AS claim_header_id
    ,paid_amt as service_line_item_paid_amount
FROM dedup_claim
ORDER BY claim_service_line_item_id;


--Q6
-- if line missing, no dupes
-- if line num not null, has dupes
WITH null_line AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY member_num, claim_num, proc_cd
            ORDER BY trxdt
        ) || 'u' AS new_line_num
    FROM raw_claim_data
    --FROM raw_claim_trx
    WHERE line_num IS NULL
),
non_null_deduped AS (
    SELECT *
    FROM (
        SELECT *
               ,ROW_NUMBER() OVER (
                   PARTITION BY member_num, claim_num, proc_cd, line_num
                   ORDER BY trxdt
               ) AS rn
        FROM raw_claim_data
        --FROM raw_claim_trx
        WHERE line_num IS NOT NULL
    )
    WHERE rn = 1
)
SELECT 
     member_num || '_' || claim_num || '_L' || new_line_num AS transaction_id
    ,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '') || '_L' || new_line_num AS claim_service_line_item_id
    ,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '')  AS claim_header_id
    ,paid_amt as service_line_item_paid_amount
FROM null_line
UNION ALL
SELECT 
     member_num || '_' || claim_num || '_L' || line_num AS transaction_id
    ,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '') || '_L' || line_num AS claim_service_line_item_id
    ,member_num || '_' || REPLACE(REPLACE(claim_num, 'R1', ''), 'A1', '')  AS claim_header_id
    ,paid_amt as service_line_item_paid_amount
FROM non_null_deduped
;



