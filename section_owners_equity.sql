create materialized view section_owners_equity as with oe_union as(
  SELECT period_year,
    tranaction_type as account,
    total_amount,
    1 as order_process
  from account_retained_earnings_details
  where transaction_type = 'Retained Earnings'
  union ALL
  select distinct date_parts('year', calendar_at) as period_year,
    'Owners Equity' as account,
    0 as total_amount,
    999 as order_process
  from calendar
)
SELECT period_year,
  'Owners Equity' as section_bs,
  account,
  case
    when order_process = 999 then sum(total_amount) over(
      partition by period_year
      order by order_process
    )
    else total_amount
  end as total_amount
from oe_union