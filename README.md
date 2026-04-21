# Crisis_Control
Analysis for crisis recovery
## Project Overview: QuickBite Express Crisis Recovery Analysis

This project serves as a comprehensive, data-driven post-mortem for **QuickBite Express**, a Bengaluru-based food-tech startup. Following a severe brand crisis in mid-2025, this analysis evaluates the damage and outlines a strategic recovery roadmap using multi-dimensional datasets.

---

### The Catalyst: The June 2025 Crisis
In June 2025, QuickBite Express faced a "perfect storm" of operational and reputational failures:
* **Reputational Damage:** A viral social media scandal regarding food safety at partner locations.
* **Operational Failure:** A week-long delivery shutdown caused by monsoon-related logistics issues.
* **Market Pressure:** Rivals launched aggressive, predatory marketing campaigns during the outage.
* **Result:** A massive erosion of customer trust and a surge in churn rates.

### Data Architecture & Scope
The analysis utilizes a **star schema** across 149,000+ records to compare three distinct phases:
1.  **Pre-Crisis (Jan – May 2025):** Baseline performance metrics.
2.  **Crisis Period (June – Sept 2025):** Direct impact and behavioral shifts.
3.  **Recovery Phase (Post-Sept 2025):** Strategic implementation and monitoring.

**Key Datasets:** * **Dimensions:** Customers (107k+), Restaurants, Delivery Partners, and Menu Items.
* **Facts:** Order Transactions, Line Items, Delivery SLAs, and Sentiment Ratings.

---

### Strategic Business Objectives

As the Lead Data Analyst, the project focuses on six pillars to stabilize and grow the platform:

#### 1. Customer Retention & Segmentation
* Distinguish between "at-risk" customers and those who have already churned.
* Identify high-value users whose behavior shifted most drastically during the crisis.

#### 2. Behavioral Order Patterns
* Quantify the decline in order frequency and volume across different demographics.
* Analyze how the "monsoon outage" altered long-term ordering habits.

#### 3. Operational & Delivery Resilience
* Audit delivery times and SLA breaches to identify specific regional bottlenecks.
* Correlation analysis between delivery delays and plummeting CSAT (Customer Satisfaction) scores.

#### 4. Strategic Marketing & Re-acquisition
* Design targeted campaigns to win back lapsed users in the most affected demographics.
* Develop data-backed loyalty initiatives to rebuild brand equity.

#### 5. Partner Ecosystem Management
* Evaluate restaurant performance to prioritize high-quality, reliable partnerships.
* Analyze cuisine trends and regional demand to optimize the partner portfolio.

#### 6. Sentiment & Feedback Analysis
* Leverage real-time rating data to monitor the effectiveness of recovery efforts.
* Translate qualitative review data into actionable improvements for the user experience.

---

This analysis provides QuickBite Express leadership with the insights necessary to move from a state of crisis management to sustainable growth.
**Key Findings**
The analysis reveals several critical impacts during the crisis period:

**Order Volume:** Significant changes in order patterns
**Cancellation Rates:** Increased cancellations across different cities
**Delivery Performance:** SLA compliance and delivery time impacts
**Customer Satisfaction:** Rating fluctuations indicate service quality issues
**Customer Retention:** High-value customer behaviour changes
## Data Architecture
The analytics framework is built on a **Star Schema** designed to isolate performance metrics and customer behavior efficiently.

### Dimension Table: Customer (`dim_customer`)
This table provides the foundational data needed for user segmentation and acquisition tracking.

* **customer_id**: The unique primary key for every user.
* **signup_date**: Marks the beginning of the user’s lifecycle.
* **city**: The geographic anchor for regional trend analysis.
* **acquisition_channel**: Identifies the marketing source (Organic, Paid, or Referral).

### Fact Table: Orders (`fact_orders`)
The central hub for all transactional data, capturing the financial and operational heartbeat of the platform.

| Field | Description |
| :--- | :--- |
| **order_id** | Unique identifier for each transaction. |
| **Keys (FK)** | `customer_id`, `restaurant_id`, and `delivery_partner_id` link transactions to their specific entities. |
| **order_timestamp** | Tracks precise timing to analyze ordering frequency and peak crisis shifts. |
| **Financials** | `subtotal_amount`, `discount_amount`, `delivery_fee`, and `total_amount` provide a full revenue breakdown. |
| **is_cod** | Boolean flag for Cash on Delivery payments. |
| **is_cancelled** | Critical indicator for measuring fulfillment failure and revenue leakage. |

---

## Project Execution & Workflow
To replicate the analysis or explore the findings, follow this standard pipeline:

* **1. Initialization:** Execute the setup scripts to build the local database schema and ingest the raw datasets.
* **2. Data Analysis:** Run the curated SQL queries to extract metrics related to the crisis impact and recovery phases.
* **3. Visualization:** Utilize **Metabase** to explore the data through interactive, real-time dashboards.
* **4. Logic Reference:** Consult `notes.txt` for a detailed walkthrough of the SQL logic and the rationale behind the analytical approach.

**Contributing**

When adding new analysis queries:

Document the business question being answered
Include the SQL query with proper formatting
