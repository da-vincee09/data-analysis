# Global CO2 Emissions — SQL Analysis

An exploratory SQL analysis of global CO2 emissions from **2002–2021**, examining total emissions, per-capita emissions, emissions by source, historical trends, country rankings, and differences between major emitters.

The project uses PostgreSQL to transform raw emissions data into analytical insights that highlight how total emissions and per-capita emissions can tell very different stories.

**Author:** Rodini Vince B. Rosario

## Overview

The analysis explores global CO2 emissions at both the country and global level, with a focus on understanding:

* Which countries have the highest total emissions
* Which countries have the highest emissions per capita
* How total and per-capita rankings differ
* How global emissions have changed over time
* Which countries have increased or reduced their emissions
* How concentrated global emissions are among the largest emitters
* How emissions trends differ between the United States and India

The project also includes data cleaning and validation checks before performing the analysis.

## Tools & Data

* **PostgreSQL**
* **pgAdmin**
* **SQL**
* **Kaggle Dataset:** [Global Fossil CO2 Emissions by Country 2002–2022](https://www.kaggle.com/datasets/thedevastator/global-fossil-co2-emissions-by-country-2002-2022)

### Tables Used

The analysis uses two primary tables:

* `mtco2_flat` — Total CO2 emissions measured in million tonnes
* `percapita_flat` — CO2 emissions per person

The tables are joined using:

```sql
country + year
```

## Data Cleaning & Validation

Before performing the analysis, several validation checks were conducted to assess data quality and consistency.

Checks included:

* Duplicate `country` + `year` combinations
* Row count comparison between the two tables
* Non-country aggregate entities such as `Global`
* Negative or invalid emissions values
* Missing or blank ISO codes
* Missing emissions values in recent years

These checks help ensure that country-level comparisons and rankings are based on valid and consistent records.

## SQL Techniques Used

* SELECT statements
* Filtering and sorting
* Aggregate functions
* GROUP BY and HAVING
* JOINs
* Self-joins
* Subqueries
* Common Table Expressions (CTEs)
* CASE statements
* Conditional aggregation
* `FILTER`
* Window functions
* `DENSE_RANK()`
* `LAG()`
* `MAX()` and `SUM()`
* Percentage calculations
* Comparative analysis

## Analysis Questions

The project contains 13 analysis questions grouped into several areas:

### Total & Per-Capita Emissions

* Which countries have the highest total emissions?
* Which countries have the highest per-capita emissions?
* How do total-emissions rankings differ from per-capita rankings?
* Which countries have high total emissions but relatively low per-capita emissions?

### Emissions Sources

* What percentage of global emissions comes from coal, oil, gas, cement, and flaring?
* Which emission source contributes the largest share?

### Time Trends

* How have global emissions changed over time?
* Which countries have increased their emissions the most since 2002?
* Which countries have reduced their emissions?
* How have annual emissions changed for major emitters?

### Impact & Comparisons

* Which countries have reduced per-capita emissions from their historical peak?
* How concentrated are global emissions among the top 10 emitters?
* How have the United States and India's emissions changed since 2002?

## Key Insights

### 1. Total Emissions and Per-Capita Emissions Tell Different Stories

The countries with the highest total emissions are not necessarily the countries with the highest emissions per person.

| Country       | Total Emissions Rank | Per-Capita Rank |
| ------------- | -------------------: | --------------: |
| China         |                    1 |              38 |
| United States |                    2 |              12 |
| India         |                    3 |             138 |
| Saudi Arabia  |                    8 |               8 |

India provides the clearest example. Although it ranks among the world's largest total emitters, its per-capita ranking is substantially lower because its emissions are distributed across a very large population.

Saudi Arabia shows the opposite pattern, ranking highly on both total and per-capita emissions.

**Key takeaway:** Total emissions reflect the scale of a country's economy and population, while per-capita emissions provide a different perspective on emissions intensity at the individual level.

---

### 2. Percentage Reductions Need Context

Comparing each country's latest per-capita emissions with its historical peak can reveal substantial reductions.

However, a simple percentage-drop ranking can be misleading. Small territories such as Sint Maarten, Curaçao, and the Bahamas can appear among the largest percentage improvers because of unusually high historical per-capita values relative to their small populations and the nature of emissions reporting.

Applying a minimum peak-emissions threshold helps reduce the influence of extreme low-baseline cases.

Countries such as Moldova and North Korea then emerge among the more significant percentage declines in the filtered results.

**Key takeaway:** Percentage-based rankings should be interpreted alongside baseline values, population size, and the underlying characteristics of the data.

---

### 3. Global Emissions Have Become More Concentrated

The analysis compared the share of global emissions produced by the top 10 emitting countries in 2002 and 2021.

| Year | Global Emissions | Top 10 Emissions | Top 10 Share |
| ---- | ---------------: | ---------------: | -----------: |
| 2002 |        26,281 Mt |        17,171 Mt |       65.34% |
| 2021 |        37,124 Mt |        25,749 Mt |       69.36% |

The top 10 emitters accounted for approximately **65% of global emissions in 2002**, increasing to approximately **69% in 2021**.

At the same time, total global emissions increased substantially.

**Key takeaway:** Global emissions became more concentrated among the largest emitting countries between 2002 and 2021, with the top 10 increasing their share by approximately 4 percentage points.

---

### 4. The United States and India Are Converging, but Remain Far Apart

The comparison between the United States and India shows two very different emissions trajectories.

| Metric                     |       2002 |       2021 | Change |
| -------------------------- | ---------: | ---------: | -----: |
| US Total Emissions         | 5,952.7 Mt | 5,007.3 Mt | -15.9% |
| India Total Emissions      | 1,022.2 Mt | 2,709.7 Mt |  +165% |
| US Per-Capita Emissions    |    20.64 t |    14.86 t |   -28% |
| India Per-Capita Emissions |     0.93 t |     1.93 t |  +107% |

Between 2002 and 2021, US total emissions declined while India's increased significantly.

As a result, the total-emissions gap narrowed from approximately **5.8× to 1.8×**.

The per-capita gap also narrowed, from approximately **22× to 7.7×**.

Despite this convergence, per-capita emissions remained substantially higher in the United States in 2021.

**Key takeaway:** The two countries moved toward each other in both total and per-capita emissions, but their per-person emissions levels remained significantly different.

## Repository Structure

```text
sql/
└── global-co2-emissions-analysis/
    ├── README.md
    └── global-co2-emissions-analysis.sql
```

The SQL file contains the complete analysis, including data validation and the 13 analytical questions.

## Notes

* The analysis uses **2002 as the baseline year** for long-term comparisons.
* The analysis covers data through **2021**, based on the years used in the SQL queries.
* `Global` rows are excluded from country-level rankings and used separately when calculating global totals.
* Country names follow the exact labels provided in the dataset.
* The two tables are joined using `country` and `year`.
* Percentage changes are calculated from the available values in the dataset.
* Per-capita rankings should be interpreted alongside population size and the characteristics of emissions reporting.

## Data Source

Dataset: **Global Fossil CO2 Emissions by Country 2002–2022**

[Kaggle Dataset](https://www.kaggle.com/datasets/thedevastator/global-fossil-co2-emissions-by-country-2002-2022)

---

Thank you for exploring this project. Feel free to review the SQL queries and analysis, and reach out with any feedback or questions.
