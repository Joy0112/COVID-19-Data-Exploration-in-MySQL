USE `profolio project`

SELECT * FROM `coviddeaths$` LIMIT 10;
SELECT * FROM `covidvaccinations$` LIMIT 10;

-- looking at total cases vs total deaths
SELECT 
	location,DATE,population,total_deaths,ROUND(IFNULL((total_deaths/total_cases) *100,0),2) AS death_percentage
FROM 
	`coviddeaths$`
ORDER BY 
	1,2

-- showing likelohood of dying if you contract covid in your country
SELECT 
	location, DATE, total_cases,total_deaths, ROUND(IFNULL((total_deaths/total_cases) * 100,0),2) AS DeathPercentage
FROM 
	`coviddeaths$`
WHERE 
	location = 'Canada'

-- looking at total cases vs population 
SELECT 
	location, DATE, population, total_cases, ROUND(IFNULL((total_cases/population) * 100,0),2) AS PercentPopulationInfected
FROM 
	`coviddeaths$`
WHERE 
	location = 'Canada'
	
-- looking at countries with highest infection rate compared to population 
SELECT 
	location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(IFNULL(MAX((total_cases/population)) * 100,0),2) AS PercentagePopulationInfected
FROM 
	`coviddeaths$`
GROUP BY 
	1,2
ORDER BY 
	4 DESC

-- break things down by continent, showing continents with highest death count per population
SELECT 
	continent, MAX(total_deaths) AS TotalDeathCount 
FROM 
	`coviddeaths$`
WHERE 
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY
	2 DESC

-- global numbers 
SELECT 
	DATE, IFNULL(SUM(new_cases),0) AS total_cases, IFNULL(SUM(new_deaths),0) AS total_deaths, ROUND(IFNULL(SUM(new_deaths)/SUM(new_cases) *100,0),2) AS DeathPercentage
FROM 
	`coviddeaths$`
WHERE 
	continent IS NOT NULL
GROUP BY 
	DATE
ORDER BY 
	1,2
	
-- looking at total populatoion vs vaccinations
-- create a cte
WITH PopvsVac(continent,location,DATE,population,new_vaccinations,rollingpeoplevaccinated) AS
(
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(vac.vaccinations) over(PARTITION BY dea.location, ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM 
		`coviddeaths$` dea
	JOIN 
		`covidvaccinations$` vac
	ON 
		dea.location = vac.location AND dea.date = vac.date
	WHERE 
		dea.continent IS NOT NULL 
)

SELECT 
	*,
	ROUND(IFNULL((RollingPeopleVaccinated/population) * 100,0),2)
FROM 
	PopvsVac
	

-- create a temprorary table 
DROP TABLE IF exsits PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
DATE DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.vaccinations) over(PARTITION BY dea.location, ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	`coviddeaths$` dea
JOIN 
	`covidvaccinations$` vac
ON 
	dea.location = vac.location AND dea.date = vac.date

SELECT * FROM PercentPopulationVaccinated

-- creating view to store data for later visualiszations
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.vaccinations) over(PARTITION BY dea.location, ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	`coviddeaths$` dea
JOIN 
	`covidvaccinations$` vac
ON 
	dea.location = vac.location AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL









	
	