--Select *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4

--Select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Russia%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
--where location like '%Russia%'
order by 1,2

--Looking at countries with highest infection rate compared to population
 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
GROUP by Location, population
order by PopulationPercentage DESC

--Showing countries with highest death count

Select location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP by location
order by TotalDeathCount DESC

--Let's show the breakdown by continent
Select continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP by continent
order by TotalDeathCount DESC

--Showing continents with the highest death count per population
Select continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP by continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,
		dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,
		dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/Population)*100
FROM PopvsVac

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,
		dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
