# Capstone-Project-IV-Apple-Stores-Analysis-SQL

# Apple Retail Sales SQL Project

## Project Overview

Hi! I created this project to demonstrate my advanced SQL skills by analyzing over **1 million rows** of Apple retail sales data. I wanted to challenge myself with a real-world, large-scale dataset that mirrors the kind of work analysts do in global companies.

Throughout the project, I tackled a wide range of **business-critical questions** from day-to-day operational reporting to strategic and predictive analysis using a relational database of product, store, sales, and warranty information.

This project gave me hands-on experience working with complex joins, time-based queries, segmentation, and optimization. It’s one of my proudest portfolio pieces and reflects the kind of value I aim to bring to a data team.

---
![image alt](https://github.com/thandipearl/Capstone-Project-IV-One-Million-rows-Apple-Stores-Analysis-SQL/blob/4f2f1d236653a59eed89b12a8b115977c7efc570/apple-store-palo-alto.jpg)
---

## Key Business Questions I Answered

All of the questions below were framed as if I were supporting an executive team at Apple. My goal was to extract meaningful insights from the data that could support real business decisions.

### Operational & Performance Analysis
- What's our global retail footprint by country?
- How many units has each store sold?
- How many transactions were completed in **December 2023**?
- Are there any Apple Stores with **zero warranty claims**?
- What percentage of claims are marked as **"Warranty Void"?**
- Which store had the **highest unit sales** in the past year?
- How many **unique products** were sold last year?
- What's the **average product price** per category?
- How many **warranty claims** were filed in **2020**?
- When did each store reach its **highest single-day sales**?

###  Strategic Insights & Trends
- What’s the **slowest-selling product** by country and year?
- How many warranty claims occur **within 180 days** of purchase?
- How many claims relate to products **launched in the last two years**?
- Which **months** in the last 3 years did USA sales exceed **5,000 units**?
- Which **product category** generated the most warranty claims in the last two years?

###  Advanced Analytics & Forecasting
- What's the **probability** that a customer files a warranty claim by country?
- What’s the **year-over-year sales growth** for each store?
- Is there a **correlation** between product price and warranty claims?
- Which store has the **highest repair completion rate**?
- Can we build a **monthly running total** of sales per store over the last four years?

###  Bonus Strategic Insight
I also analyzed **sales trends across the product lifecycle**, breaking it down into:
- 0–6 months  
- 6–12 months  
- 12–18 months  
- Beyond 18 months after product launch

---

##  Dataset & Database Schema

The dataset I worked with contains over 1 million rows and includes sales from Apple Stores around the world. I structured it using five main tables:

| Table      | Description                           |
|------------|---------------------------------------|
| `stores`   | Apple retail store information        |
| `category` | Product category information          |
| `products` | Details on Apple products             |
| `sales`    | Sales transactions                    |
| `warranty` | Warranty claim records                |

### 🗂️ Schema Details

#### `stores`
- `store_id` (PK)  
- `store_name`  
- `city`  
- `country`  

#### `category`
- `category_id` (PK)  
- `category_name`  

#### `products`
- `product_id` (PK)  
- `product_name`  
- `category_id` (FK)  
- `launch_date`  
- `price`  

#### `sales`
- `sale_id` (PK)  
- `sale_date`  
- `store_id` (FK)  
- `product_id` (FK)  
- `quantity`  

#### `warranty`
- `claim_id` (PK)  
- `claim_date`  
- `sale_id` (FK)  
- `repair_status`  

---

##  SQL Skills I Used and Improved

This project pushed me to go beyond basic queries and really dig into more advanced SQL functionality, including:

-  **Complex Joins** across multiple tables  
-  **Aggregate Functions** to compute KPIs  
-  **Window Functions** for time-based comparisons and trends  
-  **Segmentation** by product lifecycle and region  
-  **Date Filtering & Time Logic**  
-  **Correlation Analysis** using SQL logic  
-  **Query Optimization** for handling large data volumes  
-  **Business Thinking**—translating executive questions into SQL solutions  

---

##  Conclusion

By completing this project, I:
- Sharpened my ability to solve **real-world business problems** using SQL  
- Gained experience working with **large, relational datasets**  
- Built a professional-grade project to add to my **data analytics portfolio**





