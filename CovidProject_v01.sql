
Select *
From CovidProject..Deaths
where continent is not null
order by 3,4

--Select *
--From CovidProject..Vaccinations
--order by 3,4

--Select Data that we are going to be using

--Select location,date,total_cases,New_Cases,total_deaths,population
--from CovidProject..Deaths
--order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if your contract covid in your country
--Shows what percentage of population got Covid

Select location,date,total_cases,total_deaths,population,(total_deaths/population)*100 as PercentPopulationInfected01
From CovidProject..Deaths
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate Compared to Population

Select location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected02
From CovidProject..Deaths
--where location like '%states%'
where continent is not null
Group by Location, Population
order by 1,2

--Showing Countries with Highest Death Count per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..Deaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's break Things down by Continent

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..Deaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continent with the highest death count per population
--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From CovidProject..Deaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, CONVERT(int, vac.new_vaccinations), SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidProject..Deaths dea
join CovidProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--JUSE CTE

;with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
From CovidProject..Deaths dea
join CovidProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
From CovidProject..Deaths dea
join CovidProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later visualization
PRINT 'Creating PercentPopulationVaccinated View'
GO

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
From CovidProject..Deaths dea
join CovidProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
