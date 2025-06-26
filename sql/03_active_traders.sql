-- Daily Active Traders for Uniswap V3 on Arbitrum
-- This query tracks unique addresses performing swaps and calculates Real Payer Ratio

WITH daily_traders AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS day,
        COUNT(DISTINCT tx_from) AS active_traders,
        COUNT(*) AS total_trades,
        SUM(amount_usd) AS total_volume_usd,
        AVG(amount_usd) AS avg_trade_size,
        MIN(amount_usd) AS min_trade_size,
        MAX(amount_usd) AS max_trade_size
    FROM dex.trades
    WHERE blockchain = 'arbitrum'
        AND project = 'uniswap'
        AND version = '3'
        AND block_time >= CURRENT_DATE - INTERVAL '90' DAY
        AND amount_usd > 0
    GROUP BY 1
),

-- Calculate traders who paid significant fees (>= $1 USD)
real_payers AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS day,
        COUNT(DISTINCT CASE WHEN amount_usd * 0.003 >= 1.0 THEN tx_from END) AS real_payers,
        COUNT(DISTINCT CASE WHEN amount_usd >= 100 THEN tx_from END) AS high_value_traders,
        COUNT(DISTINCT CASE WHEN amount_usd >= 1000 THEN tx_from END) AS whale_traders
    FROM dex.trades
    WHERE blockchain = 'arbitrum'
        AND project = 'uniswap'
        AND version = '3'
        AND block_time >= CURRENT_DATE - INTERVAL '90' DAY
        AND amount_usd > 0
    GROUP BY 1
)

SELECT 
    dt.day,
    dt.active_traders,
    dt.total_trades,
    dt.total_volume_usd,
    dt.avg_trade_size,
    dt.min_trade_size,
    dt.max_trade_size,
    COALESCE(rp.real_payers, 0) AS real_payers,
    COALESCE(rp.high_value_traders, 0) AS high_value_traders,
    COALESCE(rp.whale_traders, 0) AS whale_traders,
    
    -- Key ratios
    CASE 
        WHEN dt.active_traders > 0 
        THEN COALESCE(rp.real_payers, 0) * 1.0 / dt.active_traders 
        ELSE 0 
    END AS real_payer_ratio,
    
    CASE 
        WHEN dt.active_traders > 0 
        THEN COALESCE(rp.high_value_traders, 0) * 1.0 / dt.active_traders 
        ELSE 0 
    END AS high_value_ratio,
    
    dt.total_trades * 1.0 / dt.active_traders AS avg_trades_per_user,
    dt.total_volume_usd / dt.active_traders AS avg_volume_per_user,
    
    -- 7-day moving averages
    AVG(dt.active_traders) OVER (
        ORDER BY dt.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS active_traders_7d_ma,
    
    AVG(dt.total_volume_usd) OVER (
        ORDER BY dt.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_7d_ma,
    
    AVG(CASE 
        WHEN dt.active_traders > 0 
        THEN COALESCE(rp.real_payers, 0) * 1.0 / dt.active_traders 
        ELSE 0 
    END) OVER (
        ORDER BY dt.day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS real_payer_ratio_7d_ma

FROM daily_traders dt
LEFT JOIN real_payers rp ON dt.day = rp.day
ORDER BY dt.day DESC

