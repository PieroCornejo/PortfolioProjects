-- Query 1: Filter COVID_DEATH$ records where continent is not null
SELECT *
FROM PortfolioProject..COVID_DEATH$
WHERE continent IS NOT NULL
ORDER BY 4, 7;

-- Query 2: Select specific columns from COVID_DEATH$ and order by the 4th column
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM PortfolioProject..COVID_DEATH$
ORDER BY 4;

-- Query 3: Total cases vs Total Deaths in Peru
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..COVID_DEATH$
WHERE location LIKE 'Peru' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Query 4: Total cases vs population in Peru
SELECT
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS Infected_cases
FROM PortfolioProject..COVID_DEATH$
WHERE location LIKE 'Peru' AND continent IS NOT NULL
ORDER BY 2;

-- Query 5: Countries with highest Infection rate compared to population
SELECT
    location,
    population,
    MAX(total_cases) AS TotalCases,
    MAX((total_cases / population) * 100) AS InfectionRate_Country
FROM PortfolioProject..COVID_DEATH$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Query 6: Countries with the highest Death Count per Population
SELECT
    location,
    population,
    MAX(total_deaths) AS Maximum_deaths,
    MAX((total_deaths / population)) * 100 AS DeathRate_Country
FROM PortfolioProject..COVID_DEATH$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Query 7: Continents with highest DeathCount
SELECT
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..COVID_DEATH$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Query 8: Global numbers
SELECT
    date,
    continent,
    SUM(new_cases) AS NewCases,
    SUM(new_deaths) AS NewDeaths
FROM PortfolioProject..COVID_DEATH$
WHERE continent IS NOT NULL
GROUP BY date, continent
ORDER BY 3 DESC;

-- Query 9: Total Population vs Vaccination
SELECT
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM PortfolioProject..COVID_VACCINATION$ vac
JOIN PortfolioProject..COVID_DEATH$ dea ON vac.location = dea.location AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3;

-- Query 10: Vaccination trend by day
SELECT
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..COVID_VACCINATION$ vac
JOIN PortfolioProject..COVID_DEATH$ dea ON vac.location = dea.location AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2;

-- Query 11: Vaccination rate by day with CTE
WITH PopvsVac (Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..COVID_VACCINATION$ vac
    JOIN PortfolioProject..COVID_DEATH$ dea ON vac.location = dea.location AND vac.date = dea.date
    WHERE dea.continent IS NOT NULL
)

SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS RollingVaccineRate
FROM PopvsVac
ORDER BY 1, 2;

-- Query 12: Creating a view
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..COVID_VACCINATION$ vac
JOIN PortfolioProject..COVID_DEATH$ dea ON vac.location = dea.location AND vac.date = dea.date
WHERE dea.continent IS NOT NULL;
