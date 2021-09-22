In this project, I used SQL to explore 2 datasets, both containing covid-19 data from January 1st 2020 to August 8th 2021. One of the datasets contains information on the numbers of total deaths per day percountry and total deaths per day per continent. The 2nd dataset has describes the total number of vaccinations per day per country and the total number vaccinations per day per continent. 

The types of techniques I used to explore the data are:

- SELECT, ORDER BY, GROUP BY and HAVING, to precisely specify certain information to view.
- Joins in order to combine both datasets together and compare informtion from the two different datasets.
- Aggregate functions such as MAX in order to find the latest case totals per location.
- Creating a rolling sum to indicate the increase in cases day-by-day. I did this in two ways: one way using a temporary table and the other using a CTE.
