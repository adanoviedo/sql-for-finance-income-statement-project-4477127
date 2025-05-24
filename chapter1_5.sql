with purchase_dates as(
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
)
select *
from purchase