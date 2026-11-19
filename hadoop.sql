SELECT countIf(creation_source != '') AS with_creation_source,
       countIf(m360_ntlogin_rls != '') AS with_rls,
       count() AS total
FROM gamma.crm_interactions_gold;





WITH
  (SELECT JSONExtractKeys(formatRow('JSONEachRow', *))
   FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
   WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%' LIMIT 1) AS n,
  (SELECT JSONExtractKeys(formatRow('JSONEachRow', *)) FROM gamma.crm_interactions_gold LIMIT 1) AS c
SELECT length(n) AS nucleus_cols, length(c) AS core_cols,
       arrayFilter(x -> NOT has(c, x), n) AS nucleus_only,
       arrayFilter(x -> NOT has(n, x), c) AS core_only;
