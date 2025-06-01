create materialized view section_liabilities as with liabilities_union as(
  select *,
    1 order _process
  from account_loan
  union all
  select date_part('year', calendar_at) as period_year,
    'Liabilities' as account,
    0 as total_amount,
    999 as order_process
  from calendar
  group by date_part('year', calendar_at)
)
select * period_year,
  'Libailities' as section_bs,
  account,
  case
    when order_process = 999 then sum(total_amount) over(
      partition by period_year
      order by order_process
    )
    else total_amount
  end as total_amount
from liabilities_union