
Select *
From [DATA PROJECT]..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From [DATA PROJECT]..CovidVaccinations

-- Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [DATA PROJECT]..CovidDeaths


-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF (CONVERT(float, total_cases), 0)) *100 AS DeathPercentage
FROM [DATA PROJECT]..CovidDeaths 
WHERE location like '%bani%' and continent is not null
order by 1,2



-- Looking at the total cases vs the population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, NULLIF (CONVERT(float, total_cases) / population, 0) *100 AS PercentofPopulationInfected
FROM [DATA PROJECT]..CovidDeaths 
--WHERE location like '%bani%'



--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(NULLIF (CONVERT(float, total_cases) / population, 0)) *100 AS PercentofPopulationInfected
FROM [DATA PROJECT]..CovidDeaths 
--WHERE location like '%bani%'
group by Location, Population
order by PercentofPopulationInfected 

--Showing the countries with the highest death count per population
-- conveting total deaths to integer

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [DATA PROJECT]..CovidDeaths 
--WHERE location like '%bani%'
where continent is not null
group by location
order by TotalDeathCount desc 

--LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing the continent with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [DATA PROJECT]..CovidDeaths 
--WHERE location like '%bani%'
where continent is not null
group by continent
order by TotalDeathCount desc 


--If the nvarchar is not suitable for SUM --> SUM(cast(new_deaths as int))
-- GLOBAL NUMBERS
Select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (CONVERT(float, SUM(new_deaths)) / NULLIF (CONVERT(float, SUM(new_cases)), 0)) *100 as DeathPercentage--. total_deaths, (CONVERT(float, total_deaths) / NULLIF (CONVERT(float, total_cases), 0)) *100 AS DeathPercentage
FROM [DATA PROJECT]..CovidDeaths 
--WHERE location like '%bani%' 
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations
With PopvsVac(Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [DATA PROJECT]..CovidDeaths dea
JOIN [DATA PROJECT]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac 
--USE CTE




-- TEMP TABLE

DROP Table if exists #PercentVaccinatedPopulation
Create Table #PercentVaccinatedPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentVaccinatedPopulation
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [DATA PROJECT]..CovidDeaths dea
JOIN [DATA PROJECT]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (PercentVaccinatedPopulation/population)*100
From #PercentVaccinatedPopulation 




--Creating view too store data for later visualizations
Create view PercentVaccinatedPopulation as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [DATA PROJECT]..CovidDeaths dea
JOIN [DATA PROJECT]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentVaccinatedPopulation