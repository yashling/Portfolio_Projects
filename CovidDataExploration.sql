Select *
FROM PortfolioProject..CovidDeaths
order by 3,4


Select *
FROM PortfolioProject..CovidVaccinations
order by 3,4

--Selecting data to be used
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Comparing Total Cases vs. Total Deaths
--Showing the possibility of death after Acquiring COVID in a particular country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathRatePercentage 
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2

--Comparing the population with the total number of cases
--Showing percentage of the population that has been infected by covid
SELECT location, date, population, total_cases, (CAST(total_cases AS FLOAT) / population) * 100 AS CovidPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2

--Looking at Countries with the highest infection rate compared to their population
SELECT location, population, MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / population)) * 100 AS PercentageOFPopulationInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentageOFPopulationInfected desc

--Looking death count for each country
SELECT location, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY DeathCount desc


--LOOKING AT METRICS BY CONTINENT


--Looking death count for each continent
SELECT location, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY DeathCount DESC;


--GLOBAL METRICS


--Death percentage globally
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathRatePercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
ORDER BY 1, 2


--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Data, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table

Create Table #PercentOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentOfPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentOfPopulationVaccinated


--Creating Views

USE PortfolioProject;
GO

CREATE VIEW PercentOfPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


select *
from PercentOfPopulationVaccinated