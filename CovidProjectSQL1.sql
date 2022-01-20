-- Looking at total cases vs total deaths
-- Shows likelihood of dying from covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
AND location like 'Malaysia'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population that got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
AND location like 'Malaysia'
ORDER BY 1,2

-- Shows country with the highest infection rates per population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Shows  countries with the highest death count per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- .. now showing continents with highest death count per population
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Some global numbers (daily)
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Updated case and death numbers (19/1/2022)
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


-- Looking at daily vaccinations per population in Malaysia and Singapore
SELECT dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
AND dea.location LIKE 'Malaysia'
OR dea.location LIKE 'Singapore'
ORDER BY 2, 3

-- Cumulative number of vaccinations per country
SELECT dea.continent, dea.Location, dea.Date, population, 
	vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) 
	AS CumuPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Using a CTE to show percentage of vaccinations vs population in Malaysia 
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, 
	vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) 
	AS CumuPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as CumuVacPercent
FROM PopvsVac
WHERE location LIKE 'Malaysia'


-- Using a TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, 
	vac.new_vaccinations, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) 
	AS CumuPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL;
SELECT *, (RollingPeopleVaccinated/Population)*100 as CumuVacPercent
FROM #PercentPopulationVaccinated
WHERE location LIKE 'Malaysia';


-- Creating wiew to store data for later visualisations
CREATE VIEW PercentPopulationVacc AS
SELECT dea.continent, dea.location, dea.date, population, 
	vac.new_vaccinations, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) 
	AS CumuPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL;

-- Testing view
SELECT * 
FROM PercentPopulationVacc;