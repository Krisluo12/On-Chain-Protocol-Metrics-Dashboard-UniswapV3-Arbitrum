-- Daily LP Fees for Uniswap V3 on Arbitrum
-- This query estimates fees from trading volume using typical fee rates

WITH daily_fees AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS day,
        -- Estimate fees as percentage of volume (typical Uniswap V3 fee is 0.05-1%)
        SUM(amount_usd * 0.003) AS estimated_fees_usd,  -- Using 0.3% average fee
        SUM(amount_usd) AS total_volume_usd,
        COUNT(*) AS trade_count,
        COUNT(DISTINCT taker) AS unique_traders
    FROM dex.trades
    WHERE blockchain = 'arbitrum'
        AND project = 'uniswap'
        AND version = '3'
        AND block_time >= CURRENT_DATE - INTERVAL '90' DAY
        AND amount_usd > 0
    GROUP BY 1
),

fees_with_metrics AS (
    SELECT 
        day,
        estimated_fees_usd,
        total_volume_usd,
        trade_count,
        unique_traders,
        estimated_fees_usd / total_volume_usd * 100 AS fee_percentage,
        -- 7-day moving average
        AVG(estimated_fees_usd) OVER (
            ORDER BY day 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS fees_7d_ma,
        -- Growth rate calculation
        LAG(estimated_fees_usd, 1) OVER (ORDER BY day) AS prev_day_fees
    FROM daily_fees
)

SELECT 
    day,
    estimated_fees_usd,
    total_volume_usd,
    trade_count,
    unique_traders,
    fee_percentage,
    fees_7d_ma,
    CASE 
        WHEN prev_day_fees > 0 
        THEN (estimated_fees_usd - prev_day_fees) / prev_day_fees * 100
        ELSE NULL 
    END AS fees_growth_pct
FROM fees_with_metrics
ORDER BY day DESC

