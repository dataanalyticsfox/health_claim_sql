# health_claim_sql
A recent SQL health claim challenge data set and questionaire 

**Part I (Question 1)**
You’ve just received an extract of medical claims data from a new health plan and are trying to make
sense of it. Your understanding is that this dataset is transactional – that is, each record in the file
represents a transaction, not the final action status of the record.
Several months of these medical claims data files have been loaded into a database table
(raw_claim_trx) and you’re looking through it. Knowing that the data are transactional, one of the
first things you often look for is a column describing the type of transaction – e.g., “reversal”
transactions (which undo a previous transaction) might be represented with an “R”, and
“adjustment” transactions (which update the claim with new information, typically following a
reversal) might be represented with an “A”. But no such column seems to exist here.

However, you do see certain claim numbers – e.g., 290E2942842R1 – that stick out, because they’re
two characters longer than all the other claim numbers onscreen. The majority of the records have
only eleven digits, and the only two-digit “suﬃxes” you see on the thirteen-digit claim numbers are
R[x] and A[x], which might mean something like “the [x]th reversal” and “the [x]th adjustment”.
So you search for records whose claim_num value starts with 290E2942842:

member_num, servdt, proc_cd, claim_num, line_num, trxdt, paid_amt \
345983, 20210215, G0463, 290E2942842, 1, 20210302, 334.00 \
345983, 20210215, G0463, 290E2942842R1, 1, 20210516, -334.00

This makes sense! It’s a little weird that the data source is appending a 2-character substring
representing the type of transaction to the end of the claim identifier and calling that the “claim
number”, but it’s clear enough what’s happening on this claim: there was an original claim (with
claim number 290E2942842), with one line item, for one procedure (with code G0463) provided on a
single day (February 15, 2021) and originally paid in a couple of weeks (on or around the transaction
date of March 2, 2021); the plan decided later that it wasn’t going to pay for it, and reversed it
(eﬀective May 16, 2021). Maybe the claim was a clerical error, or maybe they discovered that the
patient’s primary insurance had already paid for it, we’re not going to know. But we can just add up
the paid amounts on the two transactions to yield the “final action” net paid amount, which is $0.
You look for another one of these two-extra-digit claim numbers, and find one with claim_num value
of 2239G230928A1, and so you search for records whose claim_num starts with 2239G230928 and
get the following:

**See raw_claim_trx.csv**

Generally, this looks like a case where the original claim was amended via a reversal (to back out the
original payments) and then was adjusted to apply the updated details. But it also looks like some of
the records for this claim have duplicates, which will need to be dealt with.

**Question 1:** What do you think the “final action” paid amount for this claim is?\
**See raw_claim_trx.sql**

**Part II (Question 2)**
Next, let’s write a query that will produce the correct final action results for the full dataset.
First, we need to do something to about the duplicative data, which we’ve confirmed appears
throughout the dataset (so we’ll probably have to assume it may happen in future files as well). One
general approach to deal with duplicative transactional claims data is to identify (or construct, if
necessary) a Transaction ID, and then keep only one record per Transaction ID.

After removing the duplicates, we want to further collapse the (now-de-duplicated) transactional
data down to a “final action” grain size of one record per claim service line item. To do this we will
want to identify (or construct) a Claim Service Line Item ID, and then use that to aggregate the
transactional data associated with each line item.

Lastly, we will want to identify (or construct) a Claim Header ID, which we might later use to generate
aggregate (header-level) financial figures from the service line items on the claim.

**Question 2:** Based on what you’ve seen so far, write a SELECT query against the raw_claim_trx table that
returns one record per claim service line item, and includes columns for (1) Transaction ID; 
(2) Claim Service Line Item ID; (3) Claim Header ID; and (4) Service Line Item Paid Amount (with the final action paid
amount for that service line item).\
**See raw_claim_trx.sql**

Bad news! You just found a bunch of records that seem to be missing line numbers. For example: *see claims_data.csv*
(For records like this, consider the line_num column to contain NULL.)
This sort of heterogeneity within a single extract isn’t all that uncommon. For example, the single file
you receive may actually be populated by two diﬀerent administrative systems with diﬀerent
original structure and behavior but shoehorned into a single extract format.

**Question 3:** You still need to generate the three identifiers described earlier (i.e., Transaction ID, Claim
Service Line Item ID, and Claim Header ID). How would you generate those values for rows with missing
line numbers?\
**See claims_data.sql**

**Question 4:** Generally speaking, to what extent, if any, is the integrity of your resulting dataset harmed by
the absence of line number values? (For example, are there any scenarios where you could imagine the
absence of line numbers would lead to your logic generating inaccurate final action paid amount values?)

**Answer Q4:**
Any missing field that is required for any match key from claims data can contribute to lower data integrity. 
While we can, with some confidence, generate line numbers based on additional data to generate a match key 
(such as assigning a line number per distinct procedure code and service date), there is still the risk
of misrepresenting the final claims amount through mis-match and duplicates, along with potential aggregate errors. 

**Question 5:** A solution to deal with the missing line numbers might be more straightforward if we could
prove that a single claim was always uniformly either missing all line numbers or not missing any line
numbers at all. Write a SQL query that checks this.\
**See claims_data.sql**

**Part IV (Question 6)**
Let’s say that you are able to confirm with this query that claims can always be sorted cleanly into
the two categories, i.e., claims either have all transactions with populated line_num values or have
all transactions with a line_num value of NULL.

Furthermore, after looking closely at the data and running some additional diagnostic queries you
determine that the duplicate record problem is limited to claims with populated line numbers, i.e.,
that transactions with a missing line number are never duplicated, and you feel confident that they
will not be duplicated in future received files. (OK, this isn’t very realistic, because you could never be
sure that a future file wouldn’t have duplicate transactions with missing line numbers, but it’s just a
simplifying assumption we’re making for the purpose of the next question.)

**Question 6:** Update your earlier Question 2 query to produce the desired results (as outlined in Question 2\
**See raw_claim_trx.sql**

