/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select *
from PortfolioProject..CovidDeaths 
WHERE continent is not null
Order by 3,4

-- Select Data that we are going to be starting with


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths
--Shows Likelihood of dying if you contract covid in the country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS DeathPercentage
from PortfolioProject..CovidDeaths
where  location like  '%India%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected with Covid

select Location, date, total_cases, population, (total_deaths/population*100) AS PercentOfPopulationAffected
from PortfolioProject..CovidDeaths
--where  location like  '%India%'
Order by 1,2


-- Countries with highest Infection Rate compared to Population


select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX (total_cases/population*100) AS PercentOfPopulationAffected
from PortfolioProject..CovidDeaths
--where  location like  '%India%'
Group by location, population
Order by PercentOfPopulationAffected DESC


--Showing Countries with highest death Count per Population


select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where  location like  '%India%'
WHERE continent is not null
Group by location
Order by TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with highest death count per population


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where  location like  '%India%'
WHERE continent is not null
Group by continent
Order by TotalDeathCount DESC



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
--where  location like  '%India%'
where continent is not null
--Group By date
Order by 1,2



-- Total Population Vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population *100) 
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


