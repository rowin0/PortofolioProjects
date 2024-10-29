select*
from portofolioproject..coviddeaths$
order by 3,4

select*
from portofolioproject..covidvaccinations$
order by 3,

--select Data that we are going to be using

select location, date, total_cases, new_cases,total_deaths, population
from portofolioproject..coviddeaths$
order by 1,2

--looking at total cases vs total deaths
--shows the percentage of dying of covid per each country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from portofolioproject..coviddeaths$
--where location like '%states%'
order by 1,2


--looking at total cases vs population
--what percentage of population got covid (in our case U.S)

select location, date, total_cases,population, (total_cases/population)*100 as casesPercentage
from portofolioproject..coviddeaths$
where location like '%states%'
order by 1,2

--looking at countries with higest infection rate

select location,population,max(total_cases)as highestInfection, max((total_cases/population))*100 as percentagePopulationInfected
from portofolioproject..coviddeaths$
--where location like '%states%'
group by location, population
order by percentagePopulationInfected desc

--looking at countries with highest death count per population

select location, max(cast(total_deaths as int))as highestDeath
from portofolioproject..coviddeaths$
--where location like '%states
where continent is not null
group by location
order by highestDeath desc

--looking at continent with thehigest death counts

select continent, max(cast(total_deaths as int))as highestDeath
from portofolioproject..coviddeaths$
where continent is not null
group by continent
order by highestDeath desc



--looking at the global numbers

select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths
from portofolioproject..coviddeaths$
--where location like '%states
group by date
order by 1,2



--looking at percentage

select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100
from portofolioproject..coviddeaths$
--where location like '%states
where new_cases <>0
group by date
order by 1,2

select sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)as worrldPercent
from portofolioproject..coviddeaths$
--where location like '%states
where new_cases <>0
order by 1,2

-- join the two tables

select*
from portofolioproject..coviddeaths$ dea
join portofolioproject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portofolioproject..coviddeaths$ dea
join portofolioproject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--partition population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVac
from portofolioproject..coviddeaths$ dea
join portofolioproject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--use CTE

with PopvsVac( continent, location, date, population, new_vaccinations, rollingPeopleVac) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVac
from portofolioproject..coviddeaths$ dea
join portofolioproject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select*,(rollingPeopleVac/population)*100
from PopvsVac


--TEMP Table

drop table if exists #percentPopulationVac
create table #percentPopulationVac
(
continent nvarchar(255), 
location nvarchar (255),
date datetime,
poulation numeric,
new_vaccinations numeric,
rollingPeopleVac numeric,
)

insert into #percentPopulationVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVac
from portofolioproject..coviddeaths$ dea
join portofolioproject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(rollingPeopleVac/population)*100
from #percentPopulationVac

--create view to store data for later visualization

create view percentPeopleVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVac
from portofolioproject..coviddeaths$ dea
join portofolioproject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,

select *
from percentPeopleVac


