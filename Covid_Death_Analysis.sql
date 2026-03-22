Select*
FROM ProjectPortfolio..CovidDeaths 
Where continent is not null 
order by 3,4 

--Select*
--FROM ProjectPortfolio..CovidVaccinations 

Select Location, Date, Population, total_cases, total_deaths
FROM ProjectPortfolio..CovidDeaths 
order by 1,2 

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in my country 
Select Location, Date, total_cases, total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths 
Where location like '%south%' 
order by 1,2 

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid 

Select Location, Date, total_cases, Population,(Total_cases/Population)*100 asPercentPopulationInfected  PercentPopulationInfected 
FROM ProjectPortfolio..CovidDeaths 
Where location like '%south%' 
order by 1,2 

--Looking at countries with highest infection rate compared to population 

Select Location,Population,MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 as PercentPopulationInfected 
FROM ProjectPortfolio..CovidDeaths 
--Where location like '%south%' 
Group by Location,Population 
order by PercentPopulationInfected desc
 
 --Shows Countries with the Highest Death Count Per Population 

Select Location,MAX(cast (total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths 
--Where location like '%south%' 
Where continent is not null 
Group by Location  
order by TotalDeathCount desc

-- let's break things down by continent 

Select Continent,MAX(cast (total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths 
--Where location like '%south%' 
Where continent is not null 
Group by continent   
order by TotalDeathCount desc

-- Global Numbers 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 
as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%south%' 
Where continent is not null
Group By date 
order by 1,2 

--looking at Total Population vs Vaccinations 

Select a1.continent, a1.location, a1.date, a1.population, a2.new_vaccinations
, SUM(Cast(a2.new_vaccinations as int)) OVER (Partition by a1.location Order by a1.location, a1.date)
as RollingPeopleVaccinated 
From ProjectPortfolio..CovidDeaths a1
Join ProjectPortfolio..CovidVaccinations a2 
On a1.location = a2.location 
and a1.date = a2.date 
where a1.continent is not null
order by 2,3

--USE CTE 

With PopulationvsVaccination (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select a1.continent, a1.location, a1.date, a1.population, a2.new_vaccinations
, SUM(Cast(a2.new_vaccinations as int)) OVER (Partition by a1.location Order by a1.location, a1.date)
as RollingPeopleVaccinated 
From ProjectPortfolio..CovidDeaths a1
Join ProjectPortfolio..CovidVaccinations a2 
On a1.location = a2.location 
and a1.date = a2.date 
where a1.continent is not null
--order by 2,3
)

select*, (RollingPeopleVaccinated/Population) *100 
from PopulationvsVaccination

--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar (255), 
Location nvarchar (255),
Date datetime, 
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select a1.continent, a1.location, a1.date, a1.population, a2.new_vaccinations
, SUM(Cast(a2.new_vaccinations as int)) OVER (Partition by a1.location Order by a1.location, a1.date)
as RollingPeopleVaccinated 
From ProjectPortfolio..CovidDeaths a1
Join ProjectPortfolio..CovidVaccinations a2 
On a1.location = a2.location 
and a1.date = a2.date 
where a1.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated 

--Creating a view for visualations 

Create view PercentPopulationVaccinated as 
Select a1.continent, a1.location, a1.date, a1.population, a2.new_vaccinations
, SUM(Cast(a2.new_vaccinations as int)) OVER (Partition by a1.location Order by a1.location, a1.date)
as RollingPeopleVaccinated 
From ProjectPortfolio..CovidDeaths a1
Join ProjectPortfolio..CovidVaccinations a2 
On a1.location = a2.location 
and a1.date = a2.date 
where a1.continent is not null
--order by 2,3









 





