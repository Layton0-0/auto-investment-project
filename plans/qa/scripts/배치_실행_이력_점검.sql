-- 배치 실행 이력 점검 (SELECT 전용)
-- 목적: auto-buy, krx-daily-collector, us-daily-collector 의 당일/전일 실행 여부 확인.
-- 실행: psql -U local_pg -d investment_portfolio -f 배치_실행_이력_점검.sql
-- 또는 Docker: docker exec -i investment-timescaledb psql -U local_pg -d investment_portfolio -f - < plans/qa/scripts/배치_실행_이력_점검.sql

\echo '=== BATCH_JOB_EXECUTION (auto-buy, krx-daily-collector, us-daily-collector) 최근 20건 ==='
SELECT i.JOB_NAME,
       e.START_TIME,
       e.END_TIME,
       e.STATUS,
       LEFT(e.EXIT_MESSAGE, 200) AS EXIT_MESSAGE_PREVIEW
  FROM BATCH_JOB_EXECUTION e
  JOIN BATCH_JOB_INSTANCE i ON e.JOB_INSTANCE_ID = i.JOB_INSTANCE_ID
 WHERE i.JOB_NAME IN ('auto-buy', 'krx-daily-collector', 'us-daily-collector')
 ORDER BY e.START_TIME DESC
 LIMIT 20;

\echo '=== JOB_NAME별 마지막 실행 시각·상태 ==='
SELECT DISTINCT ON (i.JOB_NAME)
       i.JOB_NAME,
       e.END_TIME AS last_end_time,
       e.STATUS   AS last_status
  FROM BATCH_JOB_EXECUTION e
  JOIN BATCH_JOB_INSTANCE i ON e.JOB_INSTANCE_ID = i.JOB_INSTANCE_ID
 WHERE i.JOB_NAME IN ('auto-buy', 'krx-daily-collector', 'us-daily-collector')
 ORDER BY i.JOB_NAME, e.START_TIME DESC;
