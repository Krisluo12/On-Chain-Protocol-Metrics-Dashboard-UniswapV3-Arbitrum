-- Daily Trading Volume for Uniswap V3 on Arbitrum
-- This query uses Dune's standardized dex.trades table for reliable data

WITH daily_volume AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS day,
        SUM(amount_usd) AS volume_usd,
        COUNT(*) AS trade_count,
        COUNT(DISTINCT taker) AS unique_traders,
        AVG(amount_usd) AS avg_trade_size_usd
    FROM dex.trades
    WHERE blockchain = 'arbitrum'
        AND project = 'uniswap'
        AND version = '3'
        AND block_time >= CURRENT_DATE - INTERVAL '90' DAY
        AND amount_usd > 0  -- Filter out zero-value trades
    GROUP BY 1
),

daily_with_ma AS (
    SELECT 
        day,
        volume_usd,
        trade_count,
        unique_traders,
        avg_trade_size_usd,
        -- Calculate 7-day moving average
        AVG(volume_usd) OVER (
            ORDER BY day 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS volume_usd_7d_ma,
        -- Calculate growth rate
        LAG(volume_usd, 1) OVER (ORDER BY day) AS prev_day_volume
    FROM daily_volume
)

SELECT 
    day,
    volume_usd,
    trade_count,
    unique_traders,
    avg_trade_size_usd,
    volume_usd_7d_ma,
    CASE 
        WHEN prev_day_volume > 0 
        THEN (volume_usd - prev_day_volume) / prev_day_volume * 100
        ELSE NULL 
    END AS volume_growth_pct
FROM daily_with_ma
ORDER BY day DESC; 