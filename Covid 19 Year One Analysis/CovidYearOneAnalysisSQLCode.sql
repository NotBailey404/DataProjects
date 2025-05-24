USE CovidProject --This tells SQL to use the CovidProject Database to minimize hassle with Intellisense errors
GO
--select *
--from dbo.CovidDeaths
--order by 3,4

--select * 
--from dbo.CovidVaccinations
--order by 3,4

-- Select Location, Date, Total Cases, New Cases, Death Total, and Population 
-- for our analysis

--select location, date, total_cases, new_cases, total_deaths, population
--from dbo.CovidDeaths
--order by 1,2

--Next, we're taking a look at the Total Cases compared to Total Deaths

-- CovidDeathRate shows a percentage chance
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as CovidDeathRate
from dbo.CovidDeaths
where location = 'United States'
order by 1,2;

-- Total Cases VS Population (United States)
select location, date,Population,(total_deaths/dbo.CovidDeaths.Population)*100 as PopulationDeathRate
from dbo.CovidDeaths
where location = 'United States'
order by 1,2;

--From here on out, we're going to create views for easy access to key metrics without scrounging around the database,
-- starting with below

-- Countries with highest infection rate compared to population
select location,Population,MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 as '% of Population Infected'
from dbo.CovidDeaths
group by location, Population
order by '% of Population Infected' DESC;

select location,Population,date,MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 as '% of Population Infected'
from dbo.CovidDeaths
group by location, Population,date
order by '% of Population Infected' DESC;



--Create View: HighestInfectionRateAmongCountries
--CREATE VIEW HighestInfectionRateAmongCountries AS 
--select top 100 percent location,Population,MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 as '% of Population Infected'
--from dbo.CovidDeaths
--group by location, Population
--order by '% of Population Infected' DESC;
GO

--Measure Global Mortality counts for every single affected nation during the pandemic
Select location, MAX(CAST(total_deaths as INT)) as MortalityCount 
from dbo.CovidDeaths -- Pulling data from CovidDeaths table
where continent is not null --Ensures data accuracy when aggregating the Mortality Count
group by location
order by MortalityCount DESC;



--Create View: GlobalMortalityCount 
--CREATE VIEW GlobalMortalityCount AS
--Select TOP 100 PERCENT location, MAX(CAST(total_deaths as INT)) as MortalityCount 
--from dbo.CovidDeaths -- Pulling data from CovidDeaths table
--where continent is not null --Ensures data accuracy when aggregating the Mortality Count
--group by location
--order by MortalityCount DESC;
GO

-- ANALYZE CONTINENTAL DEATH COUNTS
Select continent, MAX(CAST(total_deaths as INT)) as MortalityCount --Note: CAST converts total_deaths to INT to accurately measure death count
from dbo.CovidDeaths -- Pulling data from CovidDeaths table
where continent is not null --Ensures data accuracy when aggregating the Mortality Count
group by continent -- Groups data by continent
order by MortalityCount DESC; -- Orders remaining data by Mortality Count

--Create View: ContinentalDeathCount
--CREATE VIEW ContinentalDeathCount AS
--Select TOP 100 PERCENT continent, MAX(CAST(total_deaths as INT)) as MortalityCount 
--Programmer's Note: CAST converts total_deaths to INT to accurately measure death count
--Programmer's Note: Order By is not applicable in a view unless we add "Top 100 Percent"
--from dbo.CovidDeaths -- Pulling data from CovidDeaths table
--where continent is not null --Ensures data accuracy when aggregating the Mortality Count
--group by continent -- Groups all data by continent
--order by MortalityCount DESC;-- Orders the remaining data by MortalityCount

--GLOBAL IMPACT OF COVID 19

--Worldwide Death Count
SELECT location, SUM(cast(new_deaths as INT)) as TotalMortalityCount
FROM CovidProject..CovidDeaths
WHERE continent is NULL
AND Location not in ('World','European Union','International')
GROUP BY Location
ORDER BY TotalMortalityCount

-- DAILY DEATHS AND CASES OVER TIME
select date, SUM(new_cases) as 'Total Cases Per Day', 
SUM(CAST(new_deaths as int)) AS 'Total Deaths Per Day', 
SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS FatalityRate
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2;

-- GLOBAL IMPACT (CUMULATIVE TOTAL)
select SUM(new_cases) as 'Total Cases', 
SUM(CAST(new_deaths as int)) AS 'Death Total', 
SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS FatalityRate
from dbo.CovidDeaths
where continent is not null
order by 1,2;


-- Total Population VS Vaccinations

--Begin by joining both tables together on two shared columns: Location and Date

--Combined Dataset for Both Tables
Select *
from dbo.CovidDeaths cda
join dbo.CovidVaccinations cvac
ON cda.location = cvac.location
AND cda.date = cvac.date

-- Total Population VS Vaccinations

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE COMMON TABLE EXPRESSION (CTE PRACTICE)
-- Note, a CTE is similar to a temporary table, used in multi-step calculations

WITH PopulationvsVaccinated (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopulationvsVaccinated

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingCountVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

select *, (RollingCountVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATE VIEW PercentPopulationVaccinated AS
--SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
--SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccinated
--FROM CovidProject..CovidDeaths dea
--JOIN CovidProject..CovidVaccinations vac
--ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
