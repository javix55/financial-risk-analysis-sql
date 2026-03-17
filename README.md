# Financial Risk Analysis with SQL

## Project Overview

This project analyzes the financial performance and credit risk of a services company using SQL.

The objective is to transform raw transactional data (clients, projects, invoices and payments) into a structured analytical dataset that allows monitoring:

- outstanding invoices
- overdue debt
- client risk concentration
- revenue trends
- average collection time (DSO)


The final result is a complete analytical pipeline implemented in SQL, ready to feed a business intelligence (BI) dashboard.

The project demonstrates how raw transactional data can be transformed into a structured analytical model for financial monitoring and decision-making.

## Project Architecture

The project is structured as a modular SQL pipeline that transforms raw transactional data into a clean analytical dataset.

```
financial-risk-analysis-sql
│
├── dataset
│   ├ empresa_servicios_raw.csv
│   └ empresa_analisis.db
│
├── sql
│   ├ 01_schema.sql
│   ├ 02_exploratory_analysis.sql
│   ├ 03_views_analysis.sql
│   ├ 04_financial_kpis.sql
│   ├ 05_final_dataset.sql
│   └ 06_validation_checks.sql
│
└── README.md
```

## Dataset

The project uses a simulated transactional dataset representing the operations of a services company. The dataset includes information about clients, projects, invoices, and payments and is stored in two formats:

- **empresa_servicios_raw.csv** – raw transactional data used as the source dataset.
- **empresa_analisis.db** – SQLite database containing the structured analytical model.

This dataset is used to simulate real-world financial operations and demonstrate how raw operational data can be transformed into an analytical model suitable for reporting and business intelligence.

### SQL Pipeline

The SQL scripts are organized to reflect the analytical workflow:

1. **Schema** – defines the relational data model.
2. **Exploratory analysis** – explores and validates the raw dataset.
3. **Analytical views** – builds reusable business logic.
4. **Financial KPIs** – calculates executive financial indicators.
5. **Final dataset** – produces the analytical dataset used for reporting.
6. **Validation checks** – ensures data consistency and model integrity.


## Data Model

The project is based on a relational data model representing the financial operations of a services company.

The core entities are:

- **Clients**
- **Projects**
- **Invoices**
- **Payments**

The relationships between them follow a hierarchical structure:

```
Clients
   │
   └── Projects
          │
          └── Invoices
                 │
                 └── Payments
```

Each client can have multiple projects, each project can generate multiple invoices, and each invoice can be paid through one or multiple payments.


This structure allows tracking the full lifecycle of revenue generation and collection.

## Key Analytical Views

The project includes several analytical views that transform transactional data into meaningful financial insights.

### v_facturas_pendientes
This view lists all invoices with outstanding balances. It calculates the amount paid, the remaining balance and the number of days an invoice is overdue, allowing prioritization of the most critical receivables.

### v_kpis_resumen
This view provides an executive summary of the financial situation, including total invoicing, total collected payments, outstanding balance, number of overdue invoices and the percentage of collected revenue.

### v_aging_global
This view groups outstanding debt by aging buckets (0–30, 31–60, 61–90, 90+ days). It is useful for assessing the overall credit risk and visualizing the distribution of overdue balances.

### v_dso_cobro
This view calculates the average number of days it takes for invoices to be paid (Days Sales Outstanding – DSO), providing a key indicator of the company’s cash collection efficiency.

## Dashboard & Visual Insights

To complement the SQL analysis, a set of visualizations has been created to represent key financial insights.

These dashboards provide a business-oriented view of the data and help stakeholders quickly understand performance and risk.

Key visualizations include:

- Monthly revenue trends
- Outstanding debt (aging analysis)
- Financial KPI summary (total invoiced, collected, and collection rate)

All visual examples can be found in the `/dashboard` folder.

## Example Business Questions

Using the analytical dataset and views created in this project, several real-world business questions can be answered, such as:

- Which invoices are currently overdue and require immediate collection action?
- What percentage of total revenue is still outstanding?
- Which clients concentrate the largest share of company revenue?
- How is outstanding debt distributed across aging buckets (0–30, 31–60, 61–90, 90+ days)?
- What is the company’s average Days Sales Outstanding (DSO)?

These questions illustrate how the SQL pipeline can support financial monitoring, credit risk management and operational decision-making.

## Technologies Used

- SQL (SQLite)
- DB Browser for SQLite
- Cursor (SQL development)
- Git & GitHub
- Google Sheets + Google Loocker Studio
- Power BI / Tableau

## How to Run the Project

1. Open the SQLite database using **DB Browser for SQLite**.
2. Execute the SQL scripts located in the `/sql` directory in order:

   - `01_schema.sql`
   - `02_exploratory_analysis.sql`
   - `03_views_analysis.sql`
   - `04_financial_kpis.sql`
   - `05_final_dataset.sql`
   - `06_validation_checks.sql`

3. The resulting analytical views and datasets can be queried directly in SQLite or connected to a BI tool such as **Power BI** or **Tableau** for visualization and dashboard creation.
