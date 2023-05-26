--Covid Deaths table
Select*
From [COVID Portfolio project]..Covid_deaths
order by 3,4

--Covid Vaccination table
Select*
From [COVID Portfolio project]..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From [COVID Portfolio project]..Covid_deaths
order by 1,2

--Total cases vs Total deaths
Select Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [COVID Portfolio project]..Covid_deaths
Where Location like '%Vietnam%'
order by 1,2

--PercentPopulationInfected
Select Location, try_cast(population as int), total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [COVID Portfolio project]..Covid_deaths
Where Location like '%Vietnam%'
order by 1,2

--Highest infection rate by country
Select Location, try_cast(population as int) as Population, Max(total_cases) as HighestInfectedCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [COVID Portfolio project]..Covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc

--Highest death count by country
Select Location, Max(total_deaths) as TotalDeathCount
From [COVID Portfolio project]..Covid_deaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- continents with highest death count
Select continent, Max(total_deaths) as TotalDeathCount
From [COVID Portfolio project]..Covid_deaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Break things down by continent
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [COVID Portfolio project]..Covid_deaths
Where continent is null
Group by location
Order by TotalDeathCount desc

--Global numbers
Select date, Sum(new_cases), Sum(cast(new_deaths as float)), Sum(cast(new_deaths as int))/ NUllif (Sum(new_cases),0)*100 as DeathPercentage
From [COVID Portfolio project]..Covid_deaths
where continent is not null
Group by date 
Order by 1,2

Select  Max(cast(total_cases as int)) as Total_cases, Max(total_deaths) as Total_deaths, (Max(total_deaths)/Max(total_cases))*100 as DeathPercentage
From [COVID Portfolio project]..Covid_deaths

Select *
From [COVID Portfolio project]..Covid_deaths

ALTER TABLE [COVID Portfolio project]..Covid_deaths
ALTER COLUMN date date

ALTER TABLE [COVID Portfolio project]..CovidVaccinations
ALTER COLUMN date date

ALTER TABLE [COVID Portfolio project]..Covid_deaths
ALTER COLUMN population bigint


--Total Population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [COVID Portfolio project]..Covid_deaths dea
Join [COVID Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [COVID Portfolio project]..Covid_deaths dea
Join [COVID Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [COVID Portfolio project]..Covid_deaths dea
Join [COVID Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

Create view TotalDeathsvsTotalCases as
Select Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [COVID Portfolio project]..Covid_deaths
Where Location like '%Vietnam%'
--order by 1,2

Create view PercentPopulationInfected as
Select Location, try_cast(population as int) as Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [COVID Portfolio project]..Covid_deaths
Where Location like '%Vietnam%'
--order by 1,2

Create view HighestInfectionRatebyCountry  as
Select Location, try_cast(population as int) as Population, Max(total_cases) as HighestInfectedCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [COVID Portfolio project]..Covid_deaths
Group by Location, Population
--order by PercentPopulationInfected desc

Create view HighestDeathCountbyCountry as
Select Location, Max(total_deaths) as TotalDeathCount
From [COVID Portfolio project]..Covid_deaths
Where continent is not null
Group by Location
--order by TotalDeathCount desc

Create view ContinentsWithHighestDeathCount as
Select continent, Max(total_deaths) as TotalDeathCount
From [COVID Portfolio project]..Covid_deaths
where continent is not null
Group by continent
--order by TotalDeathCount desc

Create view ContinentData as
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [COVID Portfolio project]..Covid_deaths
Where continent is null
Group by location

Create view GlobalNumbers as
Select date, Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as float)) as Total_Deaths, Sum(cast(new_deaths as int))/ NUllif (Sum(new_cases),0)*100 as DeathPercentage
From [COVID Portfolio project]..Covid_deaths
where continent is not null
Group by date 


