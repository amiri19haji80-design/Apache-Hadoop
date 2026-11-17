### 1. Summary




SELECT 'nucleus' AS side, max(_time) AS last_file_written, max(toDate(interaction_date)) AS latest_interaction, any(file_date) AS file_date
FROM s3(factory, url='https://ecs-s3-uk-direct.uk.net.intra/uk-prd-s3-v2-dfactory-p/production/gold/crm_interactions/**', format='Parquet')
WHERE _path NOT LIKE '%spark-staging%' AND _path NOT LIKE '%_temporary%'
UNION ALL
SELECT 'core', NULL, max(toDate(interaction_date)), any(file_date)
FROM gamma.crm_interactions_gold;
