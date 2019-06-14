# MBTA-First-Hold-Project

## Purpose

This project looks at Procurement and Logistics Department efficiency by measuring various metrics related to "hold time," which is the time difference between a requisition's approval and the first time that requisiton is placed on hold. Data for this project covers the first three quarters of the 2019 MBTA Fiscal Year.

## Package Requirements

#### Software

* `R 3.5.1`

##### R Packages

* `dplyr` for data manipulation 
* `lubridate` for date handling
* `tidyverse` for data tidying
* `kableExtra` for generating tables
* `readxl` for importing data from excel
* `tidyr` for daya tidying
* `reshape2` for data transformation (i.e. tables)
* `ggplot2` for data visualization

### Data Requirements

#### `SLT_DANZ.xlsx`

This excel file should contain the following columns:

| Columns                      | Definition/Use                            |
| ---------------------------- | ----------------------------------------- |
| Unit                         | Business Unit of each requisition         |
| Req_ID                       | Unique Identifier of each requisition     |
| Req_Approval_Date            | Exact date that requisition was approved  |
| Hold                         | Whether requisition is currently on hold  |
| Buyer                        | Buyer assigned to each requisition        |
| Updated_By                   | Unsure/not used anyway                    |
| Hold_Status                  | Shows if hold has been accepted or not    |
| Comment                      | Info as to why that requisition is on hold|
| Line                         | Represents 1st instance of a hold for req |
| DateTime                     | Timestamp of requisition being put on hold|

### Output File(s)

This project will produce two table and two boxplots. The tables - one by Buyer and one by month, show the 0, 25, 50, 75, and 100th percentile hold time as well as hold requisition count and mean hold time. One boxplot is by Buyer and the other is by month as well.

![](https://github.com/ncagliuso/MBTA-First-Hold-Project/blob/master/Buyer%20Hold%20Time.jpeg)
![](https://github.com/ncagliuso/MBTA-First-Hold-Project/blob/master/Month%20Hold%20Time.jpeg)




