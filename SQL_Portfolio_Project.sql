
Select * 
from PortfolioProject..CovidDeaths

--Select * 
--from PortfolioProject..CovidVaccinations

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if yoy contract Covid in your Country
Select location, date, total_cases, total_deaths, population, round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2;


Select location, date, total_cases, total_deaths, population, round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
Order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid in United States 
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2;


-- Looking at Countries with Hightest Infection Rate compared to Population
Select location, population, Max(total_cases) as HightestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
Order by PercentPopulationInfected desc;


-- Showing the Countries Highest Death Count per Population
Select location, population, Max(cast(total_deaths as int)) as HightestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
Order by HightestDeathCount desc;


-- Let's Break Things Down by Continents
-- Continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;

-- Global Numbers
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;


Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date;


-- Looking at Total Population vs Vaccinations
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where continent is not null
Order by 1,2


-- Using CTE to calculate Total Population vs Vaccinations

WITH CTE_popvsvacc(continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	--Order by 1,2
)
Select continent, location, date, RollingVaccinations, population, 
(RollingVaccinations/population)*100 as PercentagePopulationVaccinated
from CTE_popvsvacc


-- Using TEMP table to calculate Total Population vs Vaccinations
DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

	--Order by 1,2

Select continent, location, date, RollingVaccinations, population, 
(RollingVaccinations/population)*100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated 
order by 2,3



-- Creating View to store data for visualization
Create View PercentPopulationVaccinated 
As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



Select * from PercentPopulationVaccinated
order by 2,3