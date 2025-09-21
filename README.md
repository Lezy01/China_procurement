# China Procurement Data Processing

This repository contains data processing scripts and replication materials for my research on **government procurement and procurement efficiency in China**. The work builds on Chinese public procurement announcements and regulatory thresholds, with a focus on procurement methods, discretion levels, and their impact on prices.

## Data

- **Source**: Official procurement announcements from the China Government Procurement Network (中国政府采购网) and local government platforms.
- **Unit of observation**: Contract (中标公告).
- **Key variables**:  
  - `price`: winning contract amount.  
  - `category`: project category (works, goods, services).  
  - `method`: procurement method (open bidding, competitive negotiation, e-marketplace, etc.).  
  - `province`, `year`: geographic and temporal identifiers.  
  - `openbid`, `highdis`: constructed indicators for low- vs. high-discretion methods.  
- **Filtering**: Remove incomplete records, standardize monetary units, and classify procurement methods into comparable groups.

## Processing Pipeline

1. **Raw data cleaning**  
   - Drop duplicates, harmonize province and category names, handle missing values.  
   - Convert contract amounts into standardized units (CNY).  

2. **Procurement method classification**  
   - Map long-string method names to a standardized set:  
     * Open bidding (公开招标)  
     * E-marketplace (电子卖场)  
     * Framework agreement / agreement supply (协议供货、定点采购)  
     * Competitive negotiation / consultation (竞争性谈判、磋商、询价)  
     * Single source (单一来源)  

3. **Category classification**  
   - Classify into **Works (工程)**, **Goods (货物)**, **Services (服务)**.  
   - Handle unclassified or ambiguous categories separately.  

4. **Policy threshold alignment**  
   - Match each contract with contemporaneous central and provincial thresholds for mandatory open bidding.  
   - Construct standardized contract value relative to thresholds (e.g. `amount_stad`).  

5. **Estimation datasets**  
   - Create clean panel by province × year × category.  
   - Generate variables for regression and bunching analysis.  

## Repository Structure

