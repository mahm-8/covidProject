select *
from covidDeaths
where continent is not null
order by 3,4

-- select data going to be using
select location,date,total_cases,new_cases,total_deaths,population
from covidDeaths
order by 1,2

-- looking total cases VS total Deaths

select location,date,total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from covidDeaths
where total_deaths is not null and location like '%saudi%'
order by 1,2

-- Total cases VS Population

select location,date,total_cases,population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float,population),0))*100 as populationPercentage
from covidDeaths
where total_deaths is not null and location like '%saudi%'
order by 1,2

-- countries highest infection rate

select location,population,max(total_cases)as highinfect, max((CONVERT(float, total_cases) / NULLIF(CONVERT(float,population),0)))*100 as highPercentage
from covidDeaths
--where total_deaths is not null
group by location,population
order by highPercentage desc

-- countries highest deaths
select location,max(cast (total_deaths as int ))as highinfectdeath
from covidDeaths
where continent is not null
group by location
order by highinfectdeath desc
-- max deaths by continent

-- showing continents with highest death
select continent,max(cast (total_deaths as int ))as totaldeaths
from covidDeaths
where continent is not null
group by  continent
order by totaldeaths desc


-- global numbers

select sum(new_cases), sum(new_deaths), sum(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as percentage
--,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from covidDeaths
where continent is not null --and total_deaths is not null
--group by date
order by 1,2

-- total population vs vaccinations
-- cte

with popvsvac (continent,location,date,population,new_vaccinations, rolling)
as 
(
select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as float))over (partition by dea.location order by dea.location , dea.date) as rolling
--, sum(cast (dea.population as float))as total, sum(cast (total_vaccinations as float))total_vacc,sum(cast (total_vaccinations as float))/sum(cast (population as float))*100 percentage_vacc
from covidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null and new_vaccinations is not null
--group by dea.location,dea.date,dea.population
--order by 2,3
)

select * , (rolling/population)*100
from popvsvac


--temp table
drop table if exists #PercentPopulationvacc

create table #PercentPopulationvacc
(continent nvarchar(50),
 location nvarchar(50),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeople numeric
)
insert into #PercentPopulationvacc
select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as float))over (partition by dea.location order by dea.location , dea.date) as rolling
--, sum(cast (dea.population as float))as total, sum(cast (total_vaccinations as float))total_vacc,sum(cast (total_vaccinations as float))/sum(cast (population as float))*100 percentage_vacc
from covidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null and new_vaccinations is not null
--group by dea.location,dea.date,dea.population
--order by 2,3


select * , (RollingPeople/population)*100
from #PercentPopulationvacc
where new_vaccinations is not null

-- create view to store data for later visualizations

create view PercentPopulationvacc as
select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as float))over (partition by dea.location order by dea.location , dea.date) as rolling
--, sum(cast (dea.population as float))as total, sum(cast (total_vaccinations as float))total_vacc,sum(cast (total_vaccinations as float))/sum(cast (population as float))*100 percentage_vacc
from covidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null and new_vaccinations is not null
--order by 2,3


select *
from PercentPopulationvacc