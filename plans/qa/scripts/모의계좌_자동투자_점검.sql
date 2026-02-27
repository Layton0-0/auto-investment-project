-- 모의계좌 자동투자 준비 점검용 SQL (SELECT 전용)
-- 실행: psql -U local_pg -d investment_portfolio -f 모의계좌_자동투자_점검.sql
-- 또는 Docker: docker exec -i investment-timescaledb psql -U local_pg -d investment_portfolio -f - < 모의계좌_자동투자_점검.sql

-- (1) 자동투자 ON인 거래설정
\echo '=== TB_TRADING_SETTINGS (AUTO_TRADING_ENABLED=true) ==='
SELECT TB_TRADING_SETTINGS_UID, ACCOUNT_NO, USER_ID,
       MAX_INVESTMENT_AMOUNT, MIN_INVESTMENT_AMOUNT,
       AUTO_TRADING_ENABLED, ROBO_ADVISOR_ENABLED,
       PIPELINE_AUTO_EXECUTE, PIPELINE_ALLOW_REAL_EXECUTION,
       CREATED_AT, UPDATED_AT
  FROM TB_TRADING_SETTINGS
 WHERE AUTO_TRADING_ENABLED = true
 ORDER BY ACCOUNT_NO;

-- (2) 모의계좌(SERVER_TYPE=1) 수 및 USER_ID
\echo '=== TB_USER_ACCOUNTS (SERVER_TYPE=1, IS_ACTIVE=true) ==='
SELECT SERVER_TYPE, USER_ID, COUNT(*) AS account_count
  FROM TB_USER_ACCOUNTS
 WHERE SERVER_TYPE = '1'
   AND IS_ACTIVE = true
 GROUP BY SERVER_TYPE, USER_ID
 ORDER BY USER_ID;
