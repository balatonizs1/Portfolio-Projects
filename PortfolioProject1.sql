SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Case vs Total Deaths
-- Shows likelihood of dying if you conract covid in your country
-- I had an error with the data type. I tried to convert it to int, but it got me error too so i converted it to dec

Select location, date, CONVERT(dec, total_cases) as CASES, Convert(dec, total_deaths) as DEATHS,(CONVERT(dec, total_deaths)/Convert(dec, total_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Hungary'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, CONVERT(dec, total_cases) as CASES, population,(CONVERT(dec, total_cases)/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Hungary'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to Population

Select location, MAX(CONVERT(dec, total_cases)) as HighestInfectionCount, population, MAX((CONVERT(dec, total_cases)/population))*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
Group by location, population
order by CovidPercentage desc

-- Showing Countries with Highest Death Count per Population
-- The error with the format appeared to him too and he used the cast instead of the Convert
-- He is using the int, but for me it gets to error
-- Continent is not null 

Select location, MAX(cast(total_deaths as dec)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as dec)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- First one: Total Cases, Death and percentage of deaths by days

Select date, SUM(cast(new_cases as dec)) as TotalCases, SUM(cast(new_deaths as dec)) as TotalDeaths, SUM(cast(new_deaths as dec))/SUM(cast(new_cases as dec))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location = 'Hungary'
where continent is not null
Group by date
order by 1,2

-- This is the actual Rate in 2022.09.23	

Select SUM(cast(new_cases as dec)) as TotalCases, SUM(cast(new_deaths as dec)) as TotalDeaths, SUM(cast(new_deaths as dec))/SUM(cast(new_cases as dec))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location = 'Hungary'
where continent is not null
--Group by date
order by 1,2

--Join the 2 tables together	

Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as dec)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as dec)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--There are countries where the rates are higher than 100%. I think it is because the second and third vaccinations.

--Let's do this with temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as dec)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as dec)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated