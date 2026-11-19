Selecet count(*) From Hadoop




select
    ifNull(src, 'TOTAL') as source,
    countIf(side = 'nucleus') as nucleus_rows,
    countIf(side = 'core') as core_rows,
    round(core_rows / nucleus_rows * 100, 2) as rows_pct,
    uniqExactIf(call_id, side = 'nucleus') as nucleus_calls,
    uniqExactIf(call_id, side = 'core') as core_calls,
    round(core_calls / nucleus_calls * 100, 2) as calls_pct
from (
    select 'nucleus' as side, interaction_source as src, call_id
    from s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
    where _path not like '%spark-staging%' and _path not like '%_temporary%'
      and toDate(interaction_date) < '2026-11-01'
    union all
    select 'core', interaction_source, call_id
    from gamma.crm_interactions_gold
    where toDate(interaction_date) < '2026-11-01'
)
group by src with rollup
order by source = 'TOTAL', source;
