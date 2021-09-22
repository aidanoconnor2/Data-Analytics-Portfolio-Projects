# Exploring two Covid-19 Datasets using SQL

In this project, I used SQL to explore 2 datasets, both containing covid-19 data from January 1st 2020 to August 8th 2021. One of the datasets contains information on the numbers of total deaths per day per country and total deaths per day per continent. The 2nd dataset describes the total number of vaccinations per day per country and the total number vaccinations per day per continent. 

The types of techniques I used to explore the data are:

- SELECT, ORDER BY, GROUP BY, WHERE and HAVING, to precisely specify certain information to view.
- Joins in order to combine both datasets together and compare informtion from both.
- Aggregate functions such as MAX in order to find the latest death and vaccination case totals per country.
- Creating a rolling sum to indicate the increase in death and vaccination cases day-by-day. I did this in two ways: one way using a temporary table and the other using a CTE.
