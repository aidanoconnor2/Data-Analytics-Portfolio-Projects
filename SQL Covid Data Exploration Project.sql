-- SQL Covid Data Exploration Project

-- We will explore a Covid-19 dataset which contains data starting from January 1st 2020 up until August 8th 2021.

-------------------------------------------------------------------------------------------------------------

-- Let's start by taking a look at the data:
select * from PortfolioProject.dbo.CovidDeaths
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2;

-- Looking at the total cases vs total deaths in Ireland and the death rate. 
-- This shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%reland%' -- In case Northern Ireland is counted separately or if there are some instances where Ireland is not capitalized etc.
order by 1,2;

-- Looking at Total Cases vs Population in Ireland and the rate of cases.
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as CasePercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%reland%'
order by 1,2;

-- Looking at each country's highest infection rate compared to their population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasePercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null -- This filters out the entries for continents and the world
Group by location, population
order by CasePercentage desc;

-- Looking at each country's highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

-- Let's break things down by continent:

-- Looking at each continent's highest death totals along with the world death total
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc;

-- Global numbers:

-- Looking at the total death percentages and new cases by day across the world
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100
as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2;

-- Looking at how many people across the world have been vaccinated.
-- To do that, we must first join both tables together.
-- Then we will use partition by in order to create a rolling sum of the nuber of people vaccinated day by day:
select 
	dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- To see the percentage of people vaccinated day by day per country, let's use a CTE:

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select 
	dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as Percentagevaccinated from PopvsVac

--Let's do the same thing using a temporary table instead of a CTE:

drop table if exists #PercentPopulationVaccinated -- In case we need to change something in the table and output it again
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as Percentagevaccinated from #PercentPopulationVaccinated

-- Creating a view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
