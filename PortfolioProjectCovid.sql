select * 
from Covid..coviddeaths$
where continent is not null
order by 1,2 

--Looking at deaths vs cases
--Filtered by location

select location, date,total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From Covid..coviddeaths$
where location like '%india%'
order by 2

--Looking at total cases vs population 
--shows what percentage of population got covid

select location, date,total_cases, population ,(cast(total_cases as float)/population)*100 as CovidPercentage
From Covid..coviddeaths$
where location like '%india%'
order by 2

--Looking for the country that has highest rate of infection compared to population


select location, population ,Max(total_cases)as HighestInfectionCount ,Max((cast(total_cases as float)/population)*100) as PercentPopulatioinInfected
From Covid..coviddeaths$
--where location like '%india%'
group by location,population 
order by PercentPopulatioinInfected desc

-- Showing countries with highest deathcount per population

select location ,Max(cast(total_deaths as int))as TotalDeathCount
From Covid..coviddeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid..coviddeaths$
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths ,(sum(cast(new_deaths as int))/sum(cast(new_cases as int)))*100 as DeathPercentage
from Covid..coviddeaths$
where continent is not null 

order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS


select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as float) ) over (Partition by dea.location order by dea.location,dea.date ) 
as RollingPeopleVaccinated
from Covid..coviddeaths$ dea Join Covid..covidvaccinations$ vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac(Continent,Location,Date, Population, NewVaccinations,RollingPopulationVaccinated)
as(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as float) ) over (Partition by dea.location order by dea.location,dea.date ) 
as RollingPeopleVaccinated
from Covid..coviddeaths$ dea Join Covid..covidvaccinations$ vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null
)
select *,(RollingPopulationVaccinated/Population)*100 as PercentPopulationVaccinated
from PopvsVac

--Creating view to store data for visualisations later

create view RollingPeopleVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as float) ) over (Partition by dea.location order by dea.location,dea.date ) 
as RollingPeopleVaccinated
from Covid..coviddeaths$ dea Join Covid..covidvaccinations$ vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null

create view PercentPopulationvaccination as 
With PopvsVac(Continent,Location,Date, Population, NewVaccinations,RollingPopulationVaccinated)
as(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as float) ) over (Partition by dea.location order by dea.location,dea.date ) 
as RollingPeopleVaccinated
from Covid..coviddeaths$ dea Join Covid..covidvaccinations$ vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null
)
select *,(RollingPopulationVaccinated/Population)*100 as PercentPopulationVaccinated
from PopvsVac

