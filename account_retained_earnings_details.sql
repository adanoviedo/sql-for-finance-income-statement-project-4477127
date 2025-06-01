CREATE materialized view account_retained_earnings_details as WITH revenue as(
  SELECT date_part('year', payment_at) as period_year,
    'Revenue' as transaction_type,
    1 as order_process,
    sum(quantity * price) as total_amount
  from sales
  group by date_part('year', payment_at)
),
product_price as(
  select distinct product_name,
    amount
  from purchases
),
cogs as(
  select date_part('year', payment_at) as period_year,
    'Costs of Good Sold' as transaction_type,
    2 as order_process,
    - sum(s.quantity * p.amount) as total_amount
  from sales s
    left join product_price p on s.product_name = p.product_name
  group by date_part('year', payment_at)
),
depreciation_dates as(
  select id,
    calendar_at,
    year as period_year,
    case
      when year = date_part('year', payment_date + interval '10 years')
      and month = date_part('month', payment_date) then 1
      when month = 12 then 1
      else 0
    end as flag_1_year,
    amount / count(*) over(partition by id) as installments
  from calendar
    cross join payments
  where calendar_at >= payment_date
    and calendar_at <= payment_date + interval '10 years'
    and payment_type = 'equipment'
    and id = 66
),
depreciation_sum as(
  select *,
    sum(installments) over(
      partition by id
      order by calendar_at
    ) as depreciation_amount
  from depreciation_dates
),
depreciation as(
  select period_year,
    'Depreciation' as transaction_type,
    3 as order_process,
    sum(depreciation_amount_amount) as total_amount
  from depreciation_sum
  group by period_year
),
expenses as(
  select date_part('year', payment_date) as period_year,
    case
      when payment_type = 'tax' then 'Tax Expenses'
      when payment_type = 'interest' then 'Interest Expenses'
      when payment_type = 'wage' then 'Wage Expenses'
      when payment_type = in ('rent', 'utility') then 'Operational Expenses'
    end as transaction_type,
    case
      when payment_type = 'tax' then 4
      when payment_type = 'interest' then 5
      when payment_type = 'wage' then 6
      when payment_type = in ('rent', 'utility') then 7
    end as order_process,
    - sum(amount) as total_amount
  from payments
  where payment_type in (
      'wage',
      'rent',
      'utility',
      'tax',
      'interest'
    )
  group by date_part('year', payment_date),
    case
      when payment_type = 'tax' then 'Tax Expenses'
      when payment_type = 'interest' then 'Interest Expenses'
      when payment_type = 'wage' then 'Wage Expenses'
      when payment_type = in ('rent', 'utility') then 'Operational Expenses'
    end,
    case
      when payment_type = 'tax' then 4
      when payment_type = 'interest' then 5
      when payment_type = 'wage' then 6
      when payment_type = in ('rent', 'utility') then 7
    end
),
re_union as(
  select *
  from revenue
  union all
  select *
  from cogs
  union all
  select *
  from depreciation
  union all
  select *
  from expenses
  union all
  select distinct date_part('year', calendar_at) as period_year,
    'Retained Earnings - Beginning Balanace' as transaction_type,
    0 as order_process,
    0 as total_amount
  from calendar
  union all
  select distinct date_part('year', calendar_at) as period_year,
    'Retained Earnings' as transaction_type,
    999 as order_process,
    0 as total_amount
  from calendar
),
re_details as(
  select period_year,
    transaction_type,
    round(
      case
        when order_process = 0
        or order_process = 999 then sum(total_amount) over(
          order by order_process
        )
        else total_amount
      end,
      2
    ) as total_amount
  from re_union
)
select *
from depreciation_dates