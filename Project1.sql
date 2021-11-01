
--Covid 19 Data Exploration:


select *
from CovidDeaths cd
where cd.continent is not null
order by 3,4


-- Select Data that we are going to be starting with

select c.location,c.date,c.total_cases,c.new_cases,c.total_deaths,c.population
from CovidDeaths c
where c.continent is not null
order by 1,2


--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select c.location,c.date,c.total_cases,c.total_deaths,(c.total_deaths/c.total_cases) *100 death_percentage
from CovidDeaths c
where c.location = 'israel' and c.continent is not null
order by 1,2


--looking at total cases vs population
-- Shows what percentage of population infected with Covid

select c.location,c.date,c.population,c.total_cases,(c.total_cases/c.population) *100  as persent_population_infected
from CovidDeaths c
where c.location like '%israel' and c.continent is not null
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select c.location,c.population,max(c.total_cases) as Highest_infection_count,
       max((c.total_cases/c.population)) *100  as persent_population_infected	  
from CovidDeaths c
where c.continent is not null
group by c.location,c.population
order by persent_population_infected desc


-- Countries with Highest Death Count per Population

select c.location, max(cast(c.total_deaths as int)) as total_death_count
from CovidDeaths c
where c.continent is not null
group by c.location
order by total_death_count desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select c.continent, max(cast(c.total_deaths as int)) as total_death_count
from CovidDeaths c
where c.continent is not null
group by c.continent
order by total_death_count desc

select c.location, max(cast(c.total_deaths as int)) as total_death_count
from CovidDeaths c
where c.continent is null
group by c.location
order by total_death_count desc


--Global numbers

--cases and deaths per day

select c.date,sum(c.new_cases) as total_cases_per_day,
       sum(cast(c.new_deaths as int)) as total_deaths_per_day,
       sum(cast(c.new_deaths as int))/sum(c.new_cases)*100 as death_percentage_per_day
from CovidDeaths c
where c.continent is not null
group by c.date
order by 1,2


--Total cases and deaths until 31/10/21

select sum(c.new_cases) as total_cases_per_day,
       sum(cast(c.new_deaths as int)) as total_deaths_per_day,
       sum(cast(c.new_deaths as int))/sum(c.new_cases)*100 as death_percentage_per_day
from CovidDeaths c
where c.continent is not null


--looking at total population vs vaccinations

with pop_vs_vac as (
select cd.continent, cd.location, cd.date,
       cd.population,cv.new_vaccinations,
	   sum(cast(cv.new_vaccinations as BIGINT)) over (partition by cd.location order by cd.location,cd.date) as rolling_pepole_vaccinated
from CovidDeaths cd join CovidVaccinations cv
     on cv.location = cd.location
     and cv.date = cd.date
where cd.continent is not null 
--order by 2,3
)
select *,(rolling_pepole_vaccinated/population) *100
from pop_vs_vac


--First date of vaccination by each country

select cd.continent, cd.location, min(case when cv.new_vaccinations is not null then cd.date end)
       --cd.population,cv.new_vaccinations
from CovidDeaths cd join CovidVaccinations cv
     on cv.location = cd.location
     and cv.date = cd.date
where cd.continent is not null 
group by cd.continent, cd.location
order by 3


-- Creating View to store data

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date,
       cd.population,cv.new_vaccinations,
	   sum(cast(cv.new_vaccinations as BIGINT)) over (partition by cd.location order by cd.location,cd.date) as rolling_pepole_vaccinated
from CovidDeaths cd join CovidVaccinations cv
     on cv.location = cd.location
     and cv.date = cd.date
where cd.continent is not null 

select *
from PercentPopulationVaccinated
