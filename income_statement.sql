create materialized view income_statement as
select period_year,
  case
    when transaction_type = 'Retained Earnings' then 'Net Income'
    else transaction_type
  end as transaction_type,
  total_amount
from account_earnings_details