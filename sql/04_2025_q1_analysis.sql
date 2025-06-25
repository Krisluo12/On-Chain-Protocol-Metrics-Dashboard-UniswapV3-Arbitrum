-- Uniswap V3 Arbitrum Analysis: 2025 Q1 (January - April)
-- Comprehensive metrics for the first quarter of 2025

WITH daily_metrics AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS day,
        -- Volume metrics
        SUM(amount_usd) AS volume_usd,
        COUNT(*) AS trade_count,
        COUNT(DISTINCT taker) AS unique_traders,
        AVG(amount_usd) AS avg_trade_size_usd,
        
        -- Fee calculations (assuming 0.3% average fee)
        SUM(amount_usd * 0.003) AS estimated_fees_usd,
        
        -- Real payers (users paying >= $1 in fees)
        COUNT(DISTINCT CASE WHEN amount_usd * 0.003 >= 1.0 THEN taker END) AS real_payers,
        
        -- High value traders
        COUNT(DISTINCT CASE WHEN amount_usd >= 1000 THEN taker END) AS high_value_traders
        
    FROM dex.trades
    WHERE blockchain = 'arbitrum'
        AND project = 'uniswap'
        AND version = '3'
        AND block_time >= DATE '2025-01-01'
        AND block_time < DATE '2025-05-01'  -- Up to but not including May 1st
        AND amount_usd > 0
    GROUP BY DATE_TRUNC('day', block_time)
),

monthly_summary AS (
    SELECT 
        DATE_TRUNC('month', day) AS month,
        SUM(volume_usd) AS monthly_volume,
        SUM(estimated_fees_usd) AS monthly_fees,
        AVG(unique_traders) AS avg_daily_traders,
        SUM(trade_count) AS monthly_trades,
        MAX(unique_traders) AS peak_daily_traders,
        AVG(real_payers * 1.0 / NULLIF(unique_traders, 0)) AS avg_real_payer_ratio
    FROM daily_metrics
    GROUP BY DATE_TRUNC('month', day)
),

weekly_trends AS (
    SELECT 
        DATE_TRUNC('week', day) AS week,
        SUM(volume_usd) AS weekly_volume,
        SUM(estimated_fees_usd) AS weekly_fees,
        AVG(unique_traders) AS avg_weekly_traders,
        SUM(trade_count) AS weekly_trades
    FROM daily_metrics
    GROUP BY DATE_TRUNC('week', day)
)

-- Main query: Daily metrics with moving averages and growth rates
SELECT 
    dm.day,
    EXTRACT(month FROM dm.day) AS month_num,
    CASE EXTRACT(month FROM dm.day)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February' 
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
    END AS month_name,
    
    -- Daily metrics
    dm.volume_usd,
    dm.trade_count,
    dm.unique_traders,
    dm.avg_trade_size_usd,
    dm.estimated_fees_usd,
    dm.real_payers,
    dm.high_value_traders,
    
    -- Ratios
    dm.estimated_fees_usd * 1.0 / NULLIF(dm.volume_usd, 0) AS fee_percentage,
    dm.real_payers * 1.0 / NULLIF(dm.unique_traders, 0) AS real_payer_ratio,
    dm.high_value_traders * 1.0 / NULLIF(dm.unique_traders, 0) AS high_value_ratio,
    dm.trade_count * 1.0 / NULLIF(dm.unique_traders, 0) AS trades_per_user,
    dm.volume_usd * 1.0 / NULLIF(dm.unique_traders, 0) AS volume_per_user,
    
    -- 7-day moving averages
    AVG(dm.volume_usd) OVER (
        ORDER BY dm.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_usd_7d_ma,
    
    AVG(dm.estimated_fees_usd) OVER (
        ORDER BY dm.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS fees_7d_ma,
    
    AVG(dm.unique_traders) OVER (
        ORDER BY dm.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS traders_7d_ma,
    
    AVG(dm.real_payers * 1.0 / NULLIF(dm.unique_traders, 0)) OVER (
        ORDER BY dm.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rpr_7d_ma,
    
    -- Growth rates (day-over-day)
    (dm.volume_usd - LAG(dm.volume_usd, 1) OVER (ORDER BY dm.day)) * 100.0 / 
        NULLIF(LAG(dm.volume_usd, 1) OVER (ORDER BY dm.day), 0) AS volume_growth_pct,
        
    (dm.estimated_fees_usd - LAG(dm.estimated_fees_usd, 1) OVER (ORDER BY dm.day)) * 100.0 / 
        NULLIF(LAG(dm.estimated_fees_usd, 1) OVER (ORDER BY dm.day), 0) AS fees_growth_pct,
    
    -- Week-over-week growth (7 days ago)
    (dm.volume_usd - LAG(dm.volume_usd, 7) OVER (ORDER BY dm.day)) * 100.0 / 
        NULLIF(LAG(dm.volume_usd, 7) OVER (ORDER BY dm.day), 0) AS volume_wow_growth_pct

FROM daily_metrics dm
ORDER BY dm.day;

-- Additional query for monthly summary
/*
SELECT 
    month,
    TO_CHAR(month, 'Month YYYY') AS month_display,
    monthly_volume,
    monthly_fees,
    monthly_trades,
    avg_daily_traders,
    peak_daily_traders,
    avg_real_payer_ratio,
    monthly_fees * 1.0 / NULLIF(monthly_volume, 0) AS monthly_fee_rate,
    
    -- Month-over-month growth
    (monthly_volume - LAG(monthly_volume, 1) OVER (ORDER BY month)) * 100.0 / 
        NULLIF(LAG(monthly_volume, 1) OVER (ORDER BY month), 0) AS volume_mom_growth_pct,
        
    (monthly_fees - LAG(monthly_fees, 1) OVER (ORDER BY month)) * 100.0 / 
        NULLIF(LAG(monthly_fees, 1) OVER (ORDER BY month), 0) AS fees_mom_growth_pct

FROM monthly_summary
ORDER BY month;
*/ 