SELECT * FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4

--SELECT * FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2


--Total Cases vs Total Deaths 

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location ='India'
ORDER BY 1,2


--Total Cases vs Population

SELECT Location,date,population,total_cases,(total_cases/population)*100 as PercentageOfInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location='INDIA'
ORDER BY 1,2


--Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM [Portfolio Project]..CovidDeaths
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

--Countries with highest death count per population

SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Breaking Things By Continent

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Continents with highest death count

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--JOINING TWO TABLES

SELECT *
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidDeaths vac
ON dea.location = vac.location
AND dea.date = vac.date


--Total Population vs Vaccinations

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated