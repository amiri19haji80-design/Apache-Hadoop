SELECT n.name AS nucleus_only, c.name AS core_only
FROM (SELECT name FROM (DESCRIBE TABLE s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet'))) AS n
FULL OUTER JOIN (SELECT name FROM system.columns WHERE database = 'gamma' AND table = 'crm_interactions_gold') AS c
ON n.name = c.name
WHERE n.name = '' OR c.name = ''
ORDER BY nucleus_only, core_only;







SELECT src,
  countIf(side='core') AS core_rows, countIf(side='nucleus') AS nucleus_rows,
  round(100 * countIf(side='core') / countIf(side='nucleus'), 3) AS pct,
  uniqExactIf(call_id, side='core') AS core_calls, uniqExactIf(call_id, side='nucleus') AS nucleus_calls
FROM (
  SELECT 'nucleus' AS side, interaction_source AS src, call_id
  FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
  WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%' AND toDate(interaction_date) < '2026-11-01'
  UNION ALL
  SELECT 'core', interaction_source, call_id
  FROM gamma.crm_interactions_gold WHERE toDate(interaction_date) < '2026-11-01'
)
GROUP BY src ORDER BY src;

SELECT side,
  round(100 * countIf(toString(cvs_personal_coverage_permissions) != '') / count(), 2) AS pct_personal_perm,
  round(100 * countIf(toString(cvs_team_coverage_permissions) != '') / count(), 2)     AS pct_team_perm,
  round(100 * countIf(toString(cia_permission_username) != '') / count(), 2)          AS pct_cia_user
FROM (
  SELECT 'nucleus' AS side, cvs_personal_coverage_permissions, cvs_team_coverage_permissions, cia_permission_username
  FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
  WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%' AND toDate(interaction_date) < '2026-11-01'
  UNION ALL
  SELECT 'core', cvs_personal_coverage_permissions, cvs_team_coverage_permissions, cia_permission_username
  FROM gamma.crm_interactions_gold WHERE toDate(interaction_date) < '2026-11-01'
)
GROUP BY side;



