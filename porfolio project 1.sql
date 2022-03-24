select * 
from [Porfolio Project]..CovidDeaths
order by 3,4

--select *
--from [Porfolio Project]..CovidVaccinations

-- select data we need

select location, date,total_cases,new_cases,total_deaths,population
from [Porfolio Project]..CovidDeaths
order by 1,2

--total cases vs total deaths
--shows the likelihood of you dying if you had covid
select location, date,total_cases,total_deaths,(total_deaths / total_cases)*100 as death_percentage
from [Porfolio Project]..CovidDeaths
where location = 'United States'
order by 1,2

-- total cases vs population
select location, date,population,total_cases,(total_cases / population)*100 as case_percentage
from [Porfolio Project]..CovidDeaths
where location = 'China'
order by 1,2

-- countries with highest percentage of population got infected
select location,population,max(total_cases) as HighestNumberOfCases,max((total_cases/ population))*100 as case_percentage
from [Porfolio Project]..CovidDeaths
group by location, population
order by case_percentage desc

-- countries with highest percentage of deaths to population

select location,population,max(cast (total_deaths as int)) as TotalDeathCount,max((total_deaths/ population))*100 as Death_percentage
from [Porfolio Project]..CovidDeaths
group by location, population
order by Death_percentage desc

--continent with highest deaths
select continent,max(cast (total_deaths as int)) as TotalDeathCount
from [Porfolio Project]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

select sum(new_cases) as total_cases,sum (cast(new_deaths as int)) as total_deaths,sum (cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Porfolio Project]..CovidDeaths
where continent is not null
order by 1,2

select date, sum(new_cases) as total_cases,sum (cast(new_deaths as int)) as total_deaths,sum (cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Porfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2


--join ----------
-------------------------------------------------
select *
from [Porfolio Project]..CovidDeaths dea
join [Porfolio Project]..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date

---total pouplation vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinated
from [Porfolio Project]..CovidDeaths dea
join [Porfolio Project]..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2


-- CTE
with VacStat(continent,location,date,population,new_vaccination,TotalVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinated
from [Porfolio Project]..CovidDeaths dea
join [Porfolio Project]..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,(TotalVaccinated/population)*100 as percentage
from VacStat


--temp table

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations bigint,
TotalVaccinated numeric
)


insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinated
from [Porfolio Project]..CovidDeaths dea
join [Porfolio Project]..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null

select *,(TotalVaccinated/population)*100 as percentage
from PercentPopulationVaccinated


---create view to store data for visualization
 create view PopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinated
from [Porfolio Project]..CovidDeaths dea
join [Porfolio Project]..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null


create view GlobalNumbers as
select date, sum(new_cases) as total_cases,sum (cast(new_deaths as int)) as total_deaths,sum (cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Porfolio Project]..CovidDeaths
where continent is not null
group by date




