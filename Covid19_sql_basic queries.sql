select * from CovidDeaths$
where continent is not null
order by 3,4;


--select * from dbo.CovidVaccinations$
--order by 3,4;


select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2


-- total cases vs total deaths
-- likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from CovidDeaths$
where location like '%states%'
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from CovidDeaths$
where location like '%Romania%'
order by 1,2

-- total cases vs pop
-- % of pop got covid

select Location, date, total_cases, population, (total_cases/population)*100 as death_rate
from CovidDeaths$
where location like '%states%'
order by 1,2

-- countries with highest infection rate compare to pop

select Location, max(total_cases) as highest_infection_count, population, max((total_cases/population))*100 as infection_rate
from CovidDeaths$
--where location like '%states%'
group by location, population
order by infection_rate desc 


-- showing the countries with the highest death count per pop

select Location, max(cast(total_deaths as bigint)) as total_death_count
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by total_death_count desc 


-- by continent

select location, max(cast(total_deaths as bigint)) as total_death_count
from CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by total_death_count desc 


-- global num

select  date, sum(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as death_percentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as death_percentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2

-- total pop vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, cast(vacc.new_vaccinations as bigint) as new_vacc
from CovidDeaths$ dea
join Project.dbo.CovidVaccinations$ vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 5 desc


select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint))
over (partition by dea.Location order  by dea.Location, dea.Date) as rolling_pop_vac
from CovidDeaths$ dea
join Project.dbo.CovidVaccinations$ vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2,3

-- cte

with popvsvac(Continent, Location, Date, Population, new_vacc, rolling_pop_vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint))
over (partition by dea.Location order  by dea.Location, dea.Date) as rolling_pop_vac
from CovidDeaths$ dea
join Project.dbo.CovidVaccinations$ vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)

select *, (rolling_pop_vac/Population)*100
from popvsvac

-- temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rolling_pop_vac numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint))
over (partition by dea.Location order  by dea.Location, dea.Date) as rolling_pop_vac
from CovidDeaths$ dea
join CovidVaccinations$ vacc
	on dea.location = vacc.location
	and dea.date = vacc.date


select *, (rolling_pop_vac/Population)*100
from #PercentPopulationVaccinated


 

 -- views for later visualizations

create view pop_vacc as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint))
over (partition by dea.Location order  by dea.Location, dea.Date) as rolling_pop_vac
from CovidDeaths$ dea
join CovidVaccinations$ vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3