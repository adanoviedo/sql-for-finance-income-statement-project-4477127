create materialized view account_loan as with loan_in as(
  select date_part('year', loan_at) as period_year,
    sum(value) as total_amount
  from loans
  group by date_part('year', loan_at)
),
loan_payment as(
  select date_part('year', payment_date) as period_year,
    - sum(amount) as total_amount
  from payments
  where payment_type in ('loan')
  group by date_part('year', payment_date)
),
loan_union as(
  select *
  from loan_in
  union ALL
  select *
  from loan_payment
),
loan_amount as(
  select period_year,
    sum(total_amount) as total_amount
  from loan_union
  group by period_year
),
loan as(
  select period_year,
    'Loan' as account,
    sum(total_amount) over (
      order by period_year
    ) as total_amount
  from loan_amount
)
select *
from loan