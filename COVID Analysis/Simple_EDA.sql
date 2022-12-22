-- Select data to be used

SELECT  [location],[date],total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY [location],[date];

-- Total cases vs Total Deaths

SELECT  [location],[date],total_cases,total_deaths, (CAST(total_deaths as float)/total_cases)*100 Death_per_case
FROM CovidDeaths
WHERE [location] LIKE 'India'
ORDER BY [location],[date];

-- Total cases vs Population

SELECT  [location],[date],total_cases,population, (CAST(total_cases as float)/population)*100 Death_per_capita
FROM CovidDeaths
WHERE [location] LIKE 'India'
ORDER BY [location],[date];

-- Infection rate vs Population

SELECT [location], population, MAX(total_cases) HighestInfectionCount, MAX((CAST(total_cases as float)/population)*100) HighestInfectionRate 
FROM CovidDeaths
GROUP BY [location],population
ORDER BY [HighestInfectionRate] DESC;

-- Highest Death count per capita

SELECT [location], population, MAX(total_deaths) HighestDeathCount, MAX((CAST(total_deaths as float)/population)*100) HighestDeathRate 
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY [location],population
ORDER BY [HighestDeathRate] DESC;

-- Grouping by continent
 
 SELECT [location], MAX(total_deaths) Deaths FROM CovidDeaths
 WHERE continent is NULL
 GROUP BY [location]
 ORDER BY Deaths DESC;

 -- Global Numbers per day

SELECT  [date], SUM(new_cases) Total_Cases, SUM(new_deaths) Total_Deaths, SUM(CAST(new_deaths as float))/SUM(new_cases)*100 DeathPercentage
FROM CovidDeaths
--WHERE [location] LIKE 'India'
WHERE continent is not NULL
GROUP BY [date]
ORDER BY [date];

-- Total Population vs Vaccinations
WITH PopvsVac AS
(
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) Rolling_sum_vax
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL)
SELECT continent, [location], population, MAX(Rolling_sum_vax) Total_vaccinations, MAX(Rolling_sum_vax)/(CAST(population as float)) Total_vaccinations_per_capita FROM PopvsVac
GROUP BY continent, [location], population
ORDER BY Total_vaccinations_per_capita DESC;

CREATE VIEW RollingSumVaxed AS
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) Rolling_sum_vax
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL;

SELECT * FROM RollingSumVaxed