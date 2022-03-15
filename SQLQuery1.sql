--Select *
--From CovidDeaths$
--ORDER BY 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths$
Where continent is not null
Order by 1,2

--Looking at Total Cases vs. Total Deaths
Select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
From CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Total cases vs. population
--shows what percentage of population got covid
Select Location,date,total_cases,Population,total_deaths,(total_cases/population)*100 PopulationPercentage
From CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Countires with Highest Infection Rate
Select Location, Population, MAX(total_cases), MAX((total_cases/population))*100 PopulationPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location, Population
Order by 4 DESC

--Countries with Highest Death Count Per Population
Select Location, Population, MAX(CAST(total_deaths as int)) TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location, Population
Order by 3 DESC

--BREAK THINGS DOWN BY CONTINENT
Select continent,  MAX(CAST(total_deaths as int)) TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by 2 DESC

--GLOABL NUMBERS
Select date, SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2


--Looking at total population vs. vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) RollingPeopleVaccinated,
From CovidDeaths$ dea JOIN CovidVaccinations$ vac
  On dea.location=vac.location 
  And dea.date=vac.date
Where dea.continent is not null
Order by 2,3




--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) RollingPeopleVaccinated
From CovidDeaths$ dea JOIN CovidVaccinations$ vac
  On dea.location=vac.location 
  And dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*,(RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) RollingPeopleVaccinated
From CovidDeaths$ dea JOIN CovidVaccinations$ vac
  On dea.location=vac.location 
  And dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select*,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) RollingPeopleVaccinated
From CovidDeaths$ dea JOIN CovidVaccinations$ vac
  On dea.location=vac.location 
  And dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select *
FROM PercentPopulationVaccinated