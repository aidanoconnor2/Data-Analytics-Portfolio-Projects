# Cleaning a Housing Dataset using SQL

This is a project where I used SQL to clean a dataset containing information on housing in Nashville. The dataset includes information such as the property's address, the owner's address and the value of the property etc.

The techniques used in this project are:
- The aggregate function CONVERT to remove the time from "SalesDate" and leave only the date.
- A self join to to help populate entries with missing data.
- Creating new tables in order to split address data into multiple columns.
- Using CASE statements to standardize some of the data.
- Using a WITH statement to remove duplicates.
