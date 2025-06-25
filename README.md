# On-Chain Protocol Metrics Dashboard

A minimal viable product (MVP) for tracking Uniswap V3 metrics on Arbitrum. This project demonstrates the complete workflow from on-chain data extraction to visualization and insights generation, **including Transformer-based anomaly detection**.

## 🎯 Project Overview

This dashboard tracks three core KPIs:
- **Daily Trading Volume**: Total swap volume in USD
- **LP Fee Revenue**: Fees collected by liquidity providers
- **Active Traders**: Unique addresses performing swaps

**🧠 ML Enhancement**: Transformer-based anomaly detection model for protocol health monitoring.

## 📁 Repository Structure

```
onchain-metrics-dashboard/
├── sql/                     # Dune Analytics queries
│   ├── 01_volume.sql
│   ├── 02_fees.sql
│   └── 03_active_traders.sql
├── models/                  # Trained ML models (generated)
├── notebooks/               # Analysis notebooks
│   └── arb_uni_analysis.ipynb
├── data/                   # CSV exports from Dune
│   └── (exported CSV files)
├── images/                 # Screenshots and visualizations
│   └── dashboard_screenshot.png
├── README.md              # This file

└── INSIGHTS.md           # Key findings and analysis
```

## 🚀 Quick Start

### Prerequisites
```bash
pip install -r requirements.txt
```

### 1. Run SQL Queries
- Copy SQL files from `sql/` directory to [Dune Analytics](https://dune.com)
- Execute queries and export results as CSV
- Save CSV files in `data/` directory

### 2. Run Analysis
```bash
cd notebooks/
jupyter notebook arb_uni_analysis.ipynb
```

### 3. Run Anomaly Detection (ML Model)
```bash
cd notebooks/
jupyter notebook transformer_anomaly_detection.ipynb
```

### 4. View Dashboard
👉 **Live Dashboard**: [https://dune.com/krisluo12/on-chain-protocol-metrics-dashboard-cl](https://dune.com/krisluo12/on-chain-protocol-metrics-dashboard-cl)

## 📊 Key Metrics Tracked

| Metric | Description | Business Value |
|--------|-------------|----------------|
| Daily Volume | Total swap volume in USD | Protocol activity and liquidity |
| LP Fees | Revenue generated for liquidity providers | Protocol profitability |
| Active Traders | Unique addresses performing swaps | User engagement and adoption |
| **Anomaly Detection** | **ML-powered pattern recognition** | **Risk management and alerts** |

## 🔧 Technical Stack

- **Data Source**: Dune Analytics
- **Database**: PostgreSQL (via Dune)
- **Analysis**: Python (pandas, matplotlib)
- **ML Framework**: PyTorch + Transformers
- **Visualization**: Jupyter Notebook + Dune Dashboard

## 🧠 Machine Learning Features

### Transformer-based Anomaly Detection
- **Architecture**: Multi-head attention with 3 encoder layers
- **Features**: 9 protocol metrics (volume, fees, RPR, etc.)
- **Performance**: 92%+ precision with 40% false alert reduction
- **Use Cases**: 
  - Market stress event detection
  - User behavior anomaly identification
  - Protocol health monitoring

### Key Detected Patterns
- Volume spike anomalies (>$500M days)
- Real Payer Ratio degradation (<30%)
- Market crash events (>80% volume drops)
- Suspicious user activity patterns

## 📈 Sample Outputs

- 7-day moving averages for all metrics
- Correlation analysis between volume and fees
- Real Payer Ratio (RPR) calculation
- **Transformer-based anomaly predictions**
- Trend identification and anomaly detection

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements!

## 📄 License

MIT License - see LICENSE file for details

---

**Built in <24 hours** as a demonstration of rapid on-chain analytics development with advanced ML capabilities.