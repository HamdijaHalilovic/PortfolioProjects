select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccine
--order by 3,4

-- select data which we are using
select location, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Total cases vs Total Deaths
-- shows likelihood of death when contracting covid in a specific country
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where location like '%states%'
order by 1,2

-- Total cases vs population
--shows what percentage of population has covid
select location, date, total_cases,  population, (total_cases/population)*100 as PopulationPercentage
From CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with highest infection rate vs population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionPercentage
From CovidDeaths
--where location like '%states%'
group by location, population
order by PopulationInfectionPercentage desc

-- Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc

-- Group by continent 
-- continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%states%'
where continent is not null and
location not like '%income%'
group by continent
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 as NumberofVaccinationsPercent
from PopvsVac

-- creating a view for a visualisation
CREATE VIEW TotalDeathCount as
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
--order by TotalDeathCount desc

CREATE VIEW DeathCountContinents as
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null and
location not like '%income%'
group by continent
--order by TotalDeathCount desc
