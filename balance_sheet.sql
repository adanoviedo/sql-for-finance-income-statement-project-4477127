create materialized view balance_sheet as WITH balance_sheet as(
  SELECT *
  from section_assets
  union all
  select *
  from section_liabilities
  union all
  select *
  from section_owners_equity
)
select *
from balance_sheet