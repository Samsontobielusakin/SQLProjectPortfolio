select *
from PortfolioProject..CovidDeaths
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
order by 1,2


--looking at the Total Cases vs Population
--Shows what percentage of Population got Covid

SELECT Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2



--Looking at Countries with highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population)*100) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by Location, Population
order by PercentagePopulationInfected desc

--Showing the Countries with highest Death Count per Population

SELECT Location, Population, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location, Population
order by TotalDeathCount  desc


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount  desc


SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount  desc


--GLOBAL NUMBERS

SELECT DATE, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))--/SUM((New_Cases)*100 as DeathsPercentage 
FROM PortfolioProject..CovidDeaths
--where location like '%Australia%'
where continent is not null
group by date
order by 1,2

--Looking at total population vs Vaccinations
--SELECT * 
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order 2,3

--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

DROP table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


--creating view to store data for later visualization

create view PercentPopulationVacinnated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order 2,3

SELECT *
FROM  PercentPopulationVacinnated

