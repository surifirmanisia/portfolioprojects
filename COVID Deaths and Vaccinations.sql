
Select *
From Covid..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From Covid..CovidVaccinations
--where continent is not null
--order by 3,4


-- Details

Select location, date, total_cases, new_cases, total_deaths, population
From Covid..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid..CovidDeaths
Where location = 'Indonesia'
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population get Covid in your country

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From Covid..CovidDeaths
Where location = 'Indonesia'
and continent is not null
order by 1,2

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From Covid..CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- Let's break things down by continent


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covid..CovidDeaths
where continent is not null
--Group By date
order by 1,2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated