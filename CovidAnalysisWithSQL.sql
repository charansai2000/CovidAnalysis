create database portfolioproject;
use portfolioproject;
select location,date,total_cases,new_cases,total_deaths,population from coviddeathss;
-- totalcases vs total deaths
select location , max(total_cases) as totalcases,max(total_deaths) as totaldeaths,(max(total_deaths)/max(total_cases))*100 as death_percentage from coviddeathss group by location;

-- totalcases vs population

select location,population,max(total_cases) as totalcases , max((total_cases)/population)*100  as casestopopulation 
from coviddeathss
group by location,population
order by casestopopulation desc;

-- country with highest infection rate
select location,max(total_cases) as totalcases from coviddeathss
group by location
order by totalcases desc
limit 1;

-- maximum deaths
select location,max(total_deaths) as totaldeaths from coviddeathss
where continent is not null
 group by location
order by totaldeaths desc;

-- by continent max deaths

select continent,max(total_deaths) as totaldeaths from coviddeathss
 group by continent
order by totaldeaths desc;

-- continent with highest infection rate

select continent,max(total_cases) as totalcases from coviddeathss
group by continent
order by totalcases desc
;

-- cases with population by continent

select continent,population,max(total_cases) as totalcases , max((total_cases)/population)*100  as casestopopulation 
from coviddeathss
group by continent,population
order by casestopopulation desc;


-- Global numbers 
select date,sum(new_cases)  as totalcases,sum(new_deaths) as totaldeaths ,(sum(new_deaths)/sum(new_cases))*100 as deathpercentage from coviddeathss
group by date;



-- merging tables

select * from coviddeathss cd join covidvaccination cv on cd.location=cv.location;

-- total population vs vaccination vs covidcases using CTE
with runningvaccination(location,vaccination,date,rollingsum) as(
	select cv.location,cv.new_vaccinations,cv.date,
    sum(cv.new_vaccinations) over(partition by cv.location order by cv.location,cv.date) as rollingsum
    from covidvaccination cv
    where cv.continent is not null and location='Australia'),
runningcases(population,clocation,rollingcase) as( 
select cd.population,cd.location,sum(cd.new_cases) over(partition by cd.location order by cd.location,cd.date) as rollingcase
from coviddeathss cd
where cd.continent is not null and location='Australia')
select date,rollingsum,rollingcase,population,clocation,(rollingsum/rollingcase)*100 as percentageofvaccinespercases,
(rollingsum/population)*100 as percentageofvaccinesperpopulation from runningcases 
join runningvaccination on runningcases.clocation=runningvaccination.location
order by rollingsum;


-- creating view for visualization

create view vaccinationstacks as 
with runningvaccination(location,vaccination,date,rollingsum) as(
	select cv.location,cv.new_vaccinations,cv.date,
    sum(cv.new_vaccinations) over(partition by cv.location order by cv.location,cv.date) as rollingsum
    from covidvaccination cv
    where cv.continent is not null and location='Australia'),
runningcases(population,clocation,rollingcase) as( 
select cd.population,cd.location,sum(cd.new_cases) over(partition by cd.location order by cd.location,cd.date) as rollingcase
from coviddeathss cd
where cd.continent is not null and location='Australia')
select date,rollingsum,rollingcase,population,clocation,(rollingsum/rollingcase)*100 as percentageofvaccinespercases,
(rollingsum/population)*100 as percentageofvaccinesperpopulation from runningcases 
join runningvaccination on runningcases.clocation=runningvaccination.location
order by rollingsum;


 


