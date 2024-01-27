-- Selecting relevant columns to be used

SELECT Location, Date, total_cases, new_cases, total_deaths, Population
FROM Covid_Deaths

-- Comparing total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS TotalDeathPerCase
FROM Covid_Deaths
WHERE location like '%alaysi%'

-- Comparing at total cases vs population

SELECT location, date, total_cases, total_deaths, (total_deaths/population)*100 AS TotalDeathPerPopulation
FROM Covid_Deaths
WHERE location like '%alaysi%'

-- Searching for country with highest infection

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercenPopulationInfected
FROM Covid_Deaths
GROUP BY Location, Population
ORDER BY HighestInfectionCount DESC

-- Finding country with Highest death count

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Finding continent with highest death count

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Covid_Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL STATS
-- OVER 150M CASES WITH 3M DEATHS AND 2% DEATH PERCENTAGE ALL OVER THE WORLD
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS float)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS Float))/SUM(new_cases))*100 AS DeathPercentage
FROM Covid_Deaths
WHERE continent IS NOT NULL

--Grouping by date
SELECT
    date,
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_cases) AS TotalCases,
    CASE WHEN SUM(new_cases) = 0 THEN 'Cannot calculate percentage due to 0 cases'
         ELSE ROUND((SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100, 2) END AS DeathPercentage
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--Looking at Covid Vacc table and combining them together

SELECT *
FROM Covid_vaccinations v
JOIN Covid_Deaths d
	ON v.location = d.location
	AND v.date = d.date

--Looking at total pop vs vaccination rate
--using CTE to calculate the pop vs vacc

WITH PopVsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM Covid_vaccinations v
JOIN Covid_Deaths d
	ON v.location = d.location
	AND v.date = d.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/CAST(population AS float))*100
FROM PopVsVacc

--using Temp Table to create the same analysis

DROP TABLE IF EXISTS #PercentPopVaccinated --adding this to drop table below if modification required
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM Covid_vaccinations v
JOIN Covid_Deaths d
	ON v.location = d.location
	AND v.date = d.date
WHERE d.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

-- Creating view for visualisation later

CREATE VIEW PercentPopVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM Covid_vaccinations v
JOIN Covid_Deaths d
	ON v.location = d.location
	AND v.date = d.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopVaccinated