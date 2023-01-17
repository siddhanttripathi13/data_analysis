-- Select data to be used
SELECT [location],
	[date],
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
ORDER BY [location],
	[date];

-- Total cases vs Total Deaths
SELECT [location],
	[date],
	total_cases,
	total_deaths,
	(CAST(total_deaths AS FLOAT) / total_cases) * 100 Death_per_case
FROM CovidDeaths
WHERE [location] LIKE 'India'
ORDER BY [location],
	[date];

-- Total cases vs Population
SELECT [location],
	[date],
	total_cases,
	population,
	(CAST(total_cases AS FLOAT) / population) * 100 Death_per_capita
FROM CovidDeaths
WHERE [location] LIKE 'India'
ORDER BY [location],
	[date];

-- Infection rate vs Population
SELECT [location],
	population,
	DATE,
	MAX(total_cases) HighestInfectionCount,
	MAX((CAST(total_cases AS FLOAT) / population) * 100) PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location],
	population,
	DATE
ORDER BY PercentPopulationInfected DESC;

-- Highest Death count per capita
SELECT [location],
	population,
	MAX(total_deaths) HighestDeathCount,
	MAX((CAST(total_deaths AS FLOAT) / population) * 100) HighestDeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location],
	population
ORDER BY [HighestDeathRate] DESC;

-- Grouping by continent
SELECT [location],
	MAX(total_deaths) Deaths
FROM CovidDeaths
WHERE continent IS NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY [location]
ORDER BY Deaths DESC;

-- Global Numbers per day
SELECT [date],
	SUM(new_cases) Total_Cases,
	SUM(new_deaths) Total_Deaths,
	SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases) * 100 DeathPercentage
FROM CovidDeaths
--WHERE [location] LIKE 'India'
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY [date];

-- Total Population vs Vaccinations
WITH PopvsVac
AS (
	SELECT dea.continent,
		dea.[location],
		dea.[date],
		dea.population,
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (
			PARTITION BY dea.location ORDER BY dea.DATE
			) Rolling_sum_vax
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.[location] = vac.[location]
			AND dea.[date] = vac.[date]
	WHERE dea.continent IS NOT NULL
	)
SELECT continent,
	[location],
	population,
	MAX(Rolling_sum_vax) Total_vaccinations,
	MAX(Rolling_sum_vax) / (CAST(population AS FLOAT)) Total_vaccinations_per_capita
FROM PopvsVac
GROUP BY continent,
	[location],
	population
ORDER BY Total_vaccinations_per_capita DESC;

CREATE VIEW RollingSumVaxed
AS
SELECT dea.continent,
	dea.[location],
	dea.[date],
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (
		PARTITION BY dea.location ORDER BY dea.DATE
		) Rolling_sum_vax
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.[location] = vac.[location]
		AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL;

SELECT *
FROM RollingSumVaxed

SELECT SUM(new_cases) Total_cases,
	SUM(new_deaths) Total_deaths,
	SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases) * 100 Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
