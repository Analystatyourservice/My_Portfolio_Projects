SELECT * 
FROM COVIDDATA..COVIDDEATHS
WHERE CONTINENT IS NOT NULL
ORDER BY 3,4

--Select Data that we will be using..

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVIDDATA..COVIDDEATHS
ORDER BY 1,2

--Converting date to format mm-dd-yyyy from COVIDDEATHS

ALTER TABLE COVIDDATA..COVIDDEATHS
add ConvertedDate Date;

Update COVIDDATA..COVIDDEATHS
Set ConvertedDate = convert (varchar(8),date, 110)

SELECT * 
FROM COVIDDATA..COVIDDEATHS
WHERE CONTINENT IS NOT NULL
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths
-- shows data of death percentage in the Philippines

SELECT Location, ConvertedDate, total_cases, total_deaths, (CAST (total_deaths AS FLOAT) / total_cases)*100 as DeathPercentage
FROM COVIDDATA..COVIDDEATHS
WHERE LOCATION LIKE '%PHIL%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage affected in a population

SELECT Location, ConvertedDate, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM COVIDDATA..COVIDDEATHS
WHERE LOCATION LIKE '%PHIL%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighestInfectionRate
FROM COVIDDATA..COVIDDEATHS
-- WHERE LOCATION LIKE '%PHIL%'
GROUP BY Location, Population
ORDER BY HighestInfectionRate DESC

-- Looking at Countries with Highest Death Count per Population 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM COVIDDATA..COVIDDEATHS
--WHERE LOCATION LIKE '%PHIL%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Looking at Continent with Highest Death Count per Population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM COVIDDATA..COVIDDEATHS
-- WHERE LOCATION LIKE '%PHIL%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBER

SELECT ConvertedDate, SUM([new_cases]) AS Total_Cases , sum(cast(new_deaths as int)) as total_deaths, (SUM(CAST (new_deaths AS int)) / SUM(NEW_CASES))*100 as DeathPercentage
FROM COVIDDATA..COVIDDEATHS
--WHERE LOCATION LIKE '%PHIL%'
WHERE continent IS NOT NULL
GROUP BY ConvertedDate
ORDER BY 1,2

--Converting date to format mm-dd-yyyy from COVIDVACCINATION

ALTER TABLE COVIDDATA..COVIDVACCINATION
add ConvertedDate Date;

Update COVIDDATA..COVIDVACCINATION
Set ConvertedDate = convert (varchar(8),date, 110)

SELECT *
FROM COVIDDATA..COVIDVACCINATION
WHERE CONTINENT IS NOT NULL
ORDER BY 3,4

 -- Total Population vs Vaccinations

 SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) 
 OVER (PARTITION BY cd.location order by cd.location, cd.ConvertedDate) as IncreasingPeopleVaccinated
FROM COVIDDATA..COVIDDEATHS cd
JOIN COVIDDATA..COVIDVACCINATION cv
ON cd.ConvertedDate = cv. ConvertedDate AND cd.location = cv.location
where cd.continent is NOT NULL
ORDER BY 2,3

--SELECT new_vaccinations, ConvertedDate, location
--FROM COVIDDATA..COVIDVACCINATION
--ORDER BY 2,3

-- USING CTE to use this field IncreasingPeopleVaccinated

With PopvsVac (continent, location, ConvertedDate, population, new_vaccinations, IncreasingPeopleVaccinated)
as
(
 SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as BIGINT)) 
 OVER (PARTITION BY cd.location order by cd.location, cd.ConvertedDate) as IncreasingPeopleVaccinated
FROM COVIDDATA..COVIDDEATHS cd
JOIN COVIDDATA..COVIDVACCINATION cv
ON cd.ConvertedDate = cv. ConvertedDate AND cd.location = cv.location
where cd.continent is NOT NULL
)

Select *, (IncreasingPeopleVaccinated/Population)*100 as PopvsVacRate
From PopvsVac

-- Other way to create temporary table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
ConvertedDate datetime,
Population numeric,
New_Vaccinations numeric,
IncreasingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
 SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as BIGINT)) 
 OVER (PARTITION BY cd.location order by cd.location, cd.ConvertedDate) as IncreasingPeopleVaccinated
FROM COVIDDATA..COVIDDEATHS cd
JOIN COVIDDATA..COVIDVACCINATION cv
ON cd.ConvertedDate = cv. ConvertedDate AND cd.location = cv.location
--where cd.continent is NOT NULL

Select *, (IncreasingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view for tableau visualization

Create View PercentPopulationVaccinated as 
SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as BIGINT)) 
 OVER (PARTITION BY cd.location order by cd.location, cd.ConvertedDate) as IncreasingPeopleVaccinated
FROM COVIDDATA..COVIDDEATHS cd
JOIN COVIDDATA..COVIDVACCINATION cv
ON cd.ConvertedDate = cv. ConvertedDate AND cd.location = cv.location
where cd.continent is NOT NULL

Select * 
From PercentPopulationVaccinated

--FOR TABLEAU

--1.) edited

SELECT SUM([new_cases]) AS Total_Cases , sum(cast(new_deaths as int)) as total_deaths, (SUM(CAST (new_deaths AS int)) / SUM(NEW_CASES))*100 as DeathPercentage
FROM COVIDDATA..COVIDDEATHS
--WHERE LOCATION LIKE '%PHIL%'
WHERE continent IS NOT NULL
--GROUP BY ConvertedDate
ORDER BY 1,2

--2.) edited

SELECT Location, SUM(cast(total_deaths as int)) as TotalDeathCount
FROM COVIDDATA..COVIDDEATHS
-- WHERE LOCATION LIKE '%PHIL%'
WHERE continent IS NULL AND LOCATION NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income', 'European Union')
GROUP BY Location
ORDER BY TotalDeathCount DESC

--3.)

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighestInfectionRate
FROM COVIDDATA..COVIDDEATHS
-- WHERE LOCATION LIKE '%PHIL%'
GROUP BY Location, Population
ORDER BY HighestInfectionRate DESC

--4.)

SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighestInfectionRate
FROM COVIDDATA..COVIDDEATHS
-- WHERE LOCATION LIKE '%PHIL%'
GROUP BY Location, Population, date
ORDER BY HighestInfectionRate DESC