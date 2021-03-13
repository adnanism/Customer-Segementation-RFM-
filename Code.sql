/*First we are finding the details of Customers*/


select td.customer_id,
month(max(td.order_date_time)) as Last_order_month,
count(*) as Count_order,
avg(td.value) as avg_amount
from transaction_dimensions td
where year(td.order_date_time)=2019
group by td.customer_id;

/*Next we are using percentiles to score the customers along each of the dimensions namely
Recency,Frequeny and Monetary*/

select customer_id,
ntile(4) over (order by last_order_month) as rfm_recency,
ntile(4) over (order by count_order) as rfm_frequency,
ntile(4) over (order by avg_amount) as rfm_monetary
from (select td.customer_id,
month(max(td.order_date_time)) as Last_order_month,
count(*) as Count_order,
avg(td.value) as avg_amount
from transaction_dimensions td
where year(td.order_date_time)=2019
group by td.customer_id) as tt;

/*This resulting table will assign a RFM segment in which we are asigning user friendy names
and a score between 1 and 4 for each quantiles (Recency,Frequency,Monetary)
and the discription of the score of the customer*/

select customer_id ,rfm_recency*100+rfm_frequency*10+rfm_monetary as rfm_combined,
rfm_recency+rfm_frequency+rfm_monetary as rfm_score,
case 
when (rfm_recency = 4) and (rfm_frequency  =4 ) and ( rfm_monetary  = 4) 
then 'Champions'
when (rfm_recency between 3 and 4) and (rfm_frequency between 3 and 4 ) and ( rfm_monetary between 2 and 4) 
then 'Loyal Customers'
when (rfm_recency between 3 and 4) and (rfm_frequency between 1 and 4) and ( rfm_monetary between 1 and 4) 
then 'Potential Loyalists'
when (rfm_recency = 4) and (rfm_frequency =1 ) and ( rfm_monetary =1) 
then 'New Customers'
when (rfm_recency = 3) and (rfm_frequency between 1 and 3) and ( rfm_monetary between 1 and 3) 
then 'Promising'
when (rfm_recency between 2 and 3) and (rfm_frequency between 1 and 4 ) and ( rfm_monetary between 1 and 4) 
then 'Need Attention'
when (rfm_recency=2) and (rfm_frequency =1 ) and ( rfm_monetary =2) 
then 'About to sleep'
when (rfm_recency <=2) and (rfm_frequency between 1 and 4 ) and ( rfm_monetary between 1 and 4 ) 
then 'At risk'
when (rfm_recency <=2) and (rfm_frequency between 3 and 4) and ( rfm_monetary between 2 and 4) 
then 'Cannot lose them '
when (rfm_recency =1) and (rfm_frequency =4 ) and ( rfm_monetary  =1) 
then 'Hibernating'
when (rfm_recency =1) and (rfm_frequency =1 ) and ( rfm_monetary =1) 
then 'Lost'
end as rfm_segment,
case when (rfm_recency+rfm_frequency+rfm_monetary) between 3 and 5 then 'Copper'
     when(rfm_recency+rfm_frequency+rfm_monetary) between 6 and 8 then  'Bronze'
	 when(rfm_recency+rfm_frequency+rfm_monetary) between 9 and 10 then  'Silver'
	else 'Gold'
	end as Score
from (select customer_id,
ntile(4) over (order by last_order_month) as rfm_recency,
ntile(4) over (order by count_order) as rfm_frequency,
ntile(4) over (order by avg_amount) as rfm_monetary
from (select td.customer_id,
month(max(td.order_date_time)) as Last_order_month,
count(*) as Count_order,
avg(case
when td.currency = 'EUR' then (td.value/100.0)*1.0
		 when td.currency = 'PLN' then (td.value/100)*0.241057
		 when td.currency = 'CHF' then (td.value/100)*0.871317
		 else null
		 end) as avg_amount
from transaction_dimensions td
where year(td.order_date_time)=2019
group by td.customer_id) as tt) as ts;
