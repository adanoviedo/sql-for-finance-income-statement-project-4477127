with 
purchase_dates as(
  select case
      when payment_method = 'cash' then payment_at
      else payment_at + interval '1 month'
    end as actual_payment_at,
    - sum(quantity * amount) as total_amount
  from purchases
  group by case
      when payment_method = 'cash' then payment_at
      else payment_at + interval '1 month'
    end
),
purchase as(
  select date_part('year', actual_payment_at) as period_year,
    sum(total_amount) as total_amount
  from purchase_dates
  GROUP BY date_part('year', actual_payment_at)
),
revenue_dates as(
  select case
      when payment_method = 'cash' then payment_at
      else payment_at + interval '1 month'
    end as actual_payment_at,
    sum(quantity * price) as total_amount
  from sales
  group by case
      when payment_method = 'cash' then payment_at
      else payment_at + interval '1 month'
    end
),
revenue as(
  select date_part('year', actual_payment_at) as period_year,
    sum(total_amount) as total_amount
  from revenue_dates
  GROUP BY date_part('year', actual_payment_at)
),
loan_in as(
  select date_part('year', loan_at) as period_year,
        sum(value) as total_amount
  from loans
  group by date_part('year', loan_at)
),
expenses as(
select date_part('year', payment_date) as period_year,
        - sum(amount) as total_amount
  from payments
  where payment_type in ('equipment', 'wage', 'rent', 'utility', 'tax', 'loan', 'interest')
  group by date_part('year', payment_date)
)


select * from expenses
