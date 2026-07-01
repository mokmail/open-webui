---
name: Data Analysis
description: End-to-end structured data analysis from loading to reporting with charts
tags: [data, analysis, visualization, reports]
version: 1.0.0
---

# Data Analysis

## Workflow

### 1. Load & Validate Data
- Identify the data source: CSV, JSON, Excel, database, API.
- Read the data and display schema: columns, data types, row count.
- Validate against expected schema: missing columns, type mismatches, unexpected values.
- Report any validation issues before proceeding.

### 2. Clean the Data
- Handle missing values: identify which columns have nulls and what percentage.
- Decide strategy per column: drop, fill with mean/median/mode, interpolate, or mark explicitly.
- Remove or flag duplicate rows.
- Standardize formats: dates, currencies, categorical values (e.g., "USA" vs "US" vs "United States").
- Detect and handle outliers using IQR, z-score, or domain-specific thresholds.
- Report cleaning steps taken and how many rows/columns were affected.

### 3. Explore & Profile
- Compute summary statistics per column: count, mean, median, min, max, std, percentiles.
- For categorical columns: value counts, distribution.
- Identify correlations between numeric columns.
- Check for skewed distributions and log-transform if appropriate.

### 4. Analyze
Answer the specific questions that motivated the analysis:
- Compare groups using appropriate statistical tests.
- Compute trends over time (if temporal data exists).
- Segment the data by key dimensions.
- Identify patterns, anomalies, or actionable insights.

### 5. Visualize
Create clear, labeled charts:
- **Time series** → line charts
- **Distributions** → histograms, box plots
- **Comparisons** → bar charts, grouped bar charts
- **Relationships** → scatter plots, heatmaps
- **Composition** → stacked bar charts, treemaps
Each chart should have: title, labeled axes, legend (if multiple series), and a brief caption explaining the key takeaway.

### 6. Report

Produce a structured report:

```
# Data Analysis Report: {Title}
**Data source:** {source}
**Date:** {date}
**Rows/columns:** {N x M}

## Key Findings
{Bullet list of the most important insights}

## Methodology
{Cleaning steps, analysis methods used, assumptions made}

## Results
{Findings with supporting charts and tables}

## Limitations
{Data quality issues, methodology constraints, caveats}

## Appendix
{Full summary statistics, data dictionary, code snippets}
```
