-- 2025年1-4月 Uniswap V3 Arbitrum 月度汇总
-- Monthly Summary for Q1 2025

SELECT 
    DATE_TRUNC('month', block_time) AS month,
    EXTRACT(month FROM block_time) AS month_number,
    CASE EXTRACT(month FROM block_time)
        WHEN 1 THEN '2025年1月'
        WHEN 2 THEN '2025年2月'
        WHEN 3 THEN '2025年3月'
        WHEN 4 THEN '2025年4月'
    END AS month_display,
    
    -- 交易量指标
    SUM(amount_usd) AS total_volume_usd,
    COUNT(*) AS total_trade_count,
    COUNT(DISTINCT taker) AS unique_traders,
    AVG(amount_usd) AS avg_trade_size_usd,
    
    -- 费用指标
    SUM(amount_usd * 0.003) AS estimated_fees_usd,
    (SUM(amount_usd * 0.003) * 1.0 / SUM(amount_usd)) * 100 AS avg_fee_percentage,
    
    -- 用户分析
    COUNT(DISTINCT CASE WHEN amount_usd * 0.003 >= 1.0 THEN taker END) AS real_payers,
    COUNT(DISTINCT CASE WHEN amount_usd >= 1000 THEN taker END) AS high_value_traders,
    COUNT(DISTINCT CASE WHEN amount_usd >= 10000 THEN taker END) AS whale_traders,
    
    -- 比率计算
    COUNT(DISTINCT CASE WHEN amount_usd * 0.003 >= 1.0 THEN taker END) * 1.0 / 
        COUNT(DISTINCT taker) AS real_payer_ratio,
    COUNT(DISTINCT CASE WHEN amount_usd >= 1000 THEN taker END) * 1.0 / 
        COUNT(DISTINCT taker) AS high_value_ratio,
    
    -- 效率指标
    COUNT(*) * 1.0 / COUNT(DISTINCT taker) AS trades_per_user,
    SUM(amount_usd) * 1.0 / COUNT(DISTINCT taker) AS volume_per_user,
    
    -- 日均指标
    SUM(amount_usd) / COUNT(DISTINCT DATE_TRUNC('day', block_time)) AS avg_daily_volume,
    COUNT(*) * 1.0 / COUNT(DISTINCT DATE_TRUNC('day', block_time)) AS avg_daily_trades,
    COUNT(DISTINCT taker) * 1.0 / COUNT(DISTINCT DATE_TRUNC('day', block_time)) AS avg_daily_users

FROM dex.trades
WHERE blockchain = 'arbitrum'
    AND project = 'uniswap'
    AND version = '3'
    AND block_time >= DATE '2025-01-01'
    AND block_time < DATE '2025-05-01'
    AND amount_usd > 0
GROUP BY DATE_TRUNC('month', block_time), EXTRACT(month FROM block_time)
ORDER BY month;

-- 额外查询：每日峰值统计
/*
WITH daily_stats AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS day,
        EXTRACT(month FROM block_time) AS month_num,
        SUM(amount_usd) AS daily_volume,
        COUNT(*) AS daily_trades,
        COUNT(DISTINCT taker) AS daily_users
    FROM dex.trades
    WHERE blockchain = 'arbitrum'
        AND project = 'uniswap'
        AND version = '3'
        AND block_time >= DATE '2025-01-01'
        AND block_time < DATE '2025-05-01'
        AND amount_usd > 0
    GROUP BY DATE_TRUNC('day', block_time), EXTRACT(month FROM block_time)
)

SELECT 
    month_num,
    CASE month_num
        WHEN 1 THEN '1月'
        WHEN 2 THEN '2月'
        WHEN 3 THEN '3月'
        WHEN 4 THEN '4月'
    END AS month_name,
    MAX(daily_volume) AS peak_daily_volume,
    MAX(daily_trades) AS peak_daily_trades,
    MAX(daily_users) AS peak_daily_users,
    MIN(daily_volume) AS min_daily_volume,
    AVG(daily_volume) AS avg_daily_volume
FROM daily_stats
GROUP BY month_num
ORDER BY month_num;
*/ 