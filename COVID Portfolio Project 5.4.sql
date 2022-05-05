 Select*
 From [Portfolio Project]..CovidDeaths
 Where continent is not null
 order by 3,4
 
 --select *
 --from [Portfolio Project]..CovidVaccinations
 --order by 3,4

--Select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
 from [Portfolio Project]..CovidDeaths
 order by 1,2

 -- Looking at Total Cases vs Total Deaths
 -- Shows Likelihood of dying if you contract covid in your country
 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from [Portfolio Project]..CovidDeaths
 Where Location like '%states%'
 order by 1,2


 -- Looking at Total Cases vs Population
 -- Shows what percentage of population got Covid
 select location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
 from [Portfolio Project]..CovidDeaths
 --Where Location like '%states%'
 order by 1,2


 -- Looking at Countries with Highest Infection Rate compared to Population

 select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 from [Portfolio Project]..CovidDeaths
-- Where Location like '%states%'
 Group by Location, population
 order by PercentPopulationInfected desc


 -- Showing Countries with Highest Death Count per Population

 select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from [Portfolio Project]..CovidDeaths
-- Where Location like '%states%'
 Where continent is not null
 Group by Location
 order by TotalDeathCount desc

 -- Let's Break things down by Continent

 select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from [Portfolio Project]..CovidDeaths
-- Where Location like '%states%'
 Where continent is null
 Group by location
 order by TotalDeathCount desc




 -- Global Numbers

 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercnetage
 From [Portfolio Project]..CovidDeaths
 --Where location like '%states%'
 where continent is not null
 Group by date
 order by 1,2



 -- Looking at Total Population vs Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location, 
 dea.date) as RollingPeopleVaccinated
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location, 
 dea.date) as RollingPeopleVaccinated
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Temp Table

Create Table #PercentPopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location, 
 dea.date) as RollingPeopleVaccinated
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinate



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location, 
 dea.date) as RollingPeopleVaccinated
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3