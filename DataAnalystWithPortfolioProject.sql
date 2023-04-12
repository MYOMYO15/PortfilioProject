SELECT *
FROM ProtfolioProject..CovidDeathsUpdate
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM ProtfolioProject..CovidDeathsUpdate
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProtfolioProject..CovidDeathsUpdate
order by 1,2

-- to check the all data type with detail
select * from ProtfolioProject.INFORMATION_SCHEMA.COLUMNS

-- Looking at Total Cases vs Total Deaths and change data type nvarchar to int or float because nvarchar can't calculate
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, cast(total_deaths as float) / cast(total_cases as float)*100 as DeathPercentage
FROM ProtfolioProject..CovidDeathsUpdate 
--WHERE location = 'Thailand' or
where location like '%state%'
order by 1,2

-- looking at Total Cases Vs Population
-- Show what percentage of Population got covid

SELECT location, date, population, total_cases, cast(total_cases as float) / cast(population as float)*100 as CasePercentageOfPopulation
FROM ProtfolioProject..CovidDeathsUpdate 
--where location like '%state%'
order by 1,2

-- Looking at Countries wiht Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float) / cast(population as float))*100 as PercentagePopulationInfected
FROM ProtfolioProject..CovidDeathsUpdate 
--where location like '%state%'
Group by location, population
order by PercentagePopulationInfected desc

-- Shwoing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeathsUpdate 
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET's BREAK THINGS DOWN BY CONTINET
-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeathsUpdate 
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBER
-- 
SELECT SUM(new_cases) AS Total_Case, SUM(new_deaths) As Total_Death,  NULLIF(SUM(new_deaths),0) / NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM ProtfolioProject..CovidDeathsUpdate 
-- where location like '%state%'
Where continent is not null --AND new_cases is not null AND new_deaths is not null
--Group by date
order by 1,2

---***-----------------------------------------------------------------------------------------------***---

 -- Looking at total population and Vaccinations
 --USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
( 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
FROM ProtfolioProject..CovidDeathsUpdate dea
JOIN ProtfolioProject..CovidVaccinationasUpdate vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE vac.location like '%state%'
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
FROM ProtfolioProject..CovidDeathsUpdate dea
JOIN ProtfolioProject..CovidVaccinationasUpdate vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE vac.location like '%state%'
--where dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
FROM ProtfolioProject..CovidDeathsUpdate dea
JOIN ProtfolioProject..CovidVaccinationasUpdate vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE vac.location like '%state%'
where dea.continent is not null
--ORDER BY 2,3

Drop View if exists PercentPopulationVaccinated

SELECT * 
FROM PercentPopulationVaccinated