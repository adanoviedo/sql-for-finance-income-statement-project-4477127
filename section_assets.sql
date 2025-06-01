CREATE materialized view section_assets as with assests_union as(
  select *,
    1 as order_process
  from account_cash
  union all
  select *,
    2 order_process
  from account_accounts_receivable
  union all
  select *,
    3 order_process
  from account_inventory
  union all
  select *,
    4 order_process
  from account_property_equipment
  union ALL
  select date_part('year', calendar_at) as period_year 'Assets' as aaccount,
    0 as total_amount,
    999 as order_process
  from calendar date_part('year', calendar_at)
  GROUP BY date_part('year', calendar_at)
)
select period_year,
  'Assests' as section_bs,
  account,
  case
    when order_process = 999 then sum(total_amount) over(
      PARTITION BY period_year
      order by order_process
    )
    else total_amount
  end as total_amount
from assests_union