 /* SELECT * 
FROM coviddeaths
ORDER BY 3, 4 ;
*/
SElECT 
	location, 
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM coviddeaths
ORDER BY 1,2;

-- looking at total cases vs total deaths

SElECT 
	location, 
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_percentage
    
FROM coviddeaths
WHERE location REGEXP 'Egypt'
ORDER BY 1,2;

-- looking at total cases vs population

SElECT 
	location, 
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS Infection_percentage
    
FROM coviddeaths
WHERE location REGEXP 'Egypt'
ORDER BY 1,2;

-- countries w highest infection rate compared to population

SElECT 
	location, 
    population,
    MAX(total_cases) AS highest_infection_count,
    (MAX(total_cases/population))*100 AS Infection_percentage_per_country
    
FROM coviddeaths
-- WHERE location REGEXP 'Egypt'
GROUP BY location, population
ORDER BY 4 DESC;

/* countries w highes death count, 
've face problem with casting 'total_deats' col into INT, so i changet it from the table setting,
also added 'WHERE continent IS NOT NULL' line to get rid of continent rows as we comparing countries
*/

SElECT 
	location, 
    MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- breaking it down by Continents

SElECT 
	continent, 
    MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global numbers

SElECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths
    ,(SUM(new_deaths)/SUM(new_cases))*100 AS Death_percentage
    
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- changing the date format from 'covidvaccinations' table from year/month/day, to year-month-day
-- also joining the two tables by date and location
/*
UPDATE covidvaccinations
SET date = str_to_date(date, '%m/%d/%Y');
*/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE

WITH POPvsVAC (continent, location, date, population,new_vaccinations,  rolling_people_vaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)

SELECT * , (rolling_people_vaccinated/population)*100
FROM POPvsVAC;


-- creating Temp Table  /  also inserting the 'DROP TABLE' syntax in order to optimize the content later if needed
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
NEW_VACCINATION NUMERIC,
rolling_people_vaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
;
SELECT * , (rolling_people_vaccinated/population)*100 AS rolling_people_vaccinated_to_population
FROM PercentPopulationVaccinated;


-- creating view to store data for late visualization

CREATE VIEW PercentPopulationVaccinated_VIEW AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
;

SELECT * 
FROM PercentPopulationVaccinated_VIEW






