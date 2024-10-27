--SELECT *
--FROM project.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Nepal
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM project.dbo.CovidDeaths
WHERE location like '%Nepal%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Shows likelihood of dying if you contract covid in USA
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM project.dbo.CovidDeaths
WHERE location like '%States%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM project.dbo.CovidDeaths
WHERE location like '%States%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS percent_population_infected
FROM project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Showing countries with highest death count per population.

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Showing continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- Global Numbers


SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Total cases and death percentage with respect to the cases registered.

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM project.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


--Looking at Total Population VS Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS rolling_people_vaccinated
FROM project.dbo.CovidDeaths dea
JOIN project.dbo.CovidVaccinations vac
ON dea.location= vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

WITH PopvsVac( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location,
dea.date) AS rolling_people_vaccinated
FROM project.dbo.CovidDeaths dea
JOIN project.dbo.CovidVaccinations vac
ON dea.location= vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)


SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--OR 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 







