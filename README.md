# 🗄️ SQL Data Analytics Project

A end-to-end SQL analytics project built on PostgreSQL, featuring a layered data warehouse architecture with customer and product reporting views.

---

## 📁 Project Structure
```
sql-data-analytics-project/
│
├── datasets/                  # Source data (flat files)
│   ├── dim_customers.csv
│   ├── dim_products.csv
│   └── fact_sales.csv
│
├── reports/                   # Gold layer analytical views
│   ├── customer_report.sql
│   └── Product_Report.sql
│
└── README.md
```

---

## 📊 Reports

### 👥 Customer Report (`gold.report_customers`)
Consolidates key customer metrics and behaviors including:
- Customer segmentation: **VIP**, **Regular**, **New**
- Age group banding: Under 20, 20–29, 30–39, 40–49, 50+
- KPIs: Recency, Average Order Value (AOV), Average Monthly Spend (AMS)

### 📦 Product Report (`gold.report_products`)
Consolidates key product metrics and behaviors including:
- Product segmentation: **High-Performer**, **Mid-Range**, **Low-Performer**
- KPIs: Recency, Average Order Revenue (AOR), Average Monthly Revenue (AMR)

---

## 🛠️ Tech Stack

| Tool | Usage |
|------|-------|
| PostgreSQL | Database & query engine |
| SQL (CTEs, Window Functions) | Data transformation & reporting |
| VS Code | Development environment |

---

## 🗃️ Data Sources

| Table | Description |
|-------|-------------|
| `fact_sales` | Transactional sales data |
| `dim_customers` | Customer dimension (demographics, keys) |
| `dim_products` | Product dimension (category, cost, name) |

---

## 👤 Author

**Javar Scott** · [LinkedIn](https://linkedin.com/in/javarscott) · [GitHub](https://github.com/JavarBS)
