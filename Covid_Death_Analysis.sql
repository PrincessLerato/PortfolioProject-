-- ============================================
-- Project: COVID-19 Data Analysis
-- Author: Princess Lerato Kgoedi
-- Description:
-- This project analyzes global COVID-19 trends,
-- including cases, deaths, infection rates,
-- and vaccination progress.
-- ============================================

-----------------------------------------------------
-- 1. DATA EXPLORATION
-----------------------------------------------------

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY Location, Date;

-----------------------------------------------------
-- 2. TOTAL CASES VS TOTAL DEATHS
-- Likelihood of dying if infected
-----------------------------------------------------

SELECT 
    Location, 
    Date, 
    total_cases, 
    total_deaths,
    (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%south%'
ORDER BY Location, Date;

-----------------------------------------------------
-- 3. TOTAL CASES VS POPULATION
-- Percentage of population infected
-----------------------------------------------------

SELECT 
    Location, 
    Date, 
    total_cases, 
    population,
    (total_cases / NULLIF(population, 0)) * 100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%south%'
ORDER BY Location, Date;

-----------------------------------------------------
-- 4. HIGHEST INFECTION RATE BY COUNTRY
-----------------------------------------------------

SELECT 
    Location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;

-----------------------------------------------------
-- 5. HIGHEST DEATH COUNT BY COUNTRY
-----------------------------------------------------

SELECT 
    Location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-----------------------------------------------------
-- 6. DEATH COUNT BY CONTINENT
-----------------------------------------------------

SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-----------------------------------------------------
-- 7. GLOBAL NUMBERS OVER TIME
-----------------------------------------------------

SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-----------------------------------------------------
-- 8. POPULATION VS VACCINATIONS (ROLLING TOTAL)
-----------------------------------------------------

SELECT 
    deaths.continent, 
    deaths.location, 
    deaths.date, 
    deaths.population, 
    vaccinations.new_vaccinations,
    SUM(CAST(vaccinations.new_vaccinations AS INT)) 
        OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) 
        AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vaccinations
    ON deaths.location = vaccinations.location
    AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
ORDER BY deaths.location, deaths.date;

-----------------------------------------------------
-- 9. CTE: PERCENTAGE OF POPULATION VACCINATED
-----------------------------------------------------

WITH PopulationVsVaccination AS (
    SELECT 
        deaths.continent, 
        deaths.location, 
        deaths.date, 
        deaths.population, 
        vaccinations.new_vaccinations,
        SUM(CAST(vaccinations.new_vaccinations AS INT)) 
            OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) 
            AS RollingPeopleVaccinated
    FROM ProjectPortfolio..CovidDeaths deaths
    JOIN ProjectPortfolio..CovidVaccinations vaccinations
        ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date
    WHERE deaths.continent IS NOT NULL
)

SELECT *,
    (RollingPeopleVaccinated / NULLIF(population, 0)) * 100 AS PercentVaccinated
FROM PopulationVsVaccination;

-----------------------------------------------------
-- 10. VIEW FOR TABLEAU DASHBOARD
-----------------------------------------------------

CREATE VIEW vw_PercentPopulationVaccinated AS
SELECT 
    deaths.continent, 
    deaths.location, 
    deaths.date, 
    deaths.population, 
    vaccinations.new_vaccinations,
    SUM(CAST(vaccinations.new_vaccinations AS INT)) 
        OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) 
        AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vaccinations
    ON deaths.location = vaccinations.location
    AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL;
