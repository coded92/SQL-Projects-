-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardice the data
-- 3. Null Values or blank values
-- 4. Remoe column or Row

select * 
from layoffs;

-- Create a new working table to avoid modifying raw data
create table layoffs_work
like layoffs;

insert into layoffs_work
select * 
from layoffs;

-- 1. Remove Duplicates

select *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, 
        percentage_laid_off, `date`, stage, country, funds_raised_millions)
FROM layoffs_work;

-- let's just look at oda to confirm
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;
-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate

-- Identifying the real duplicates 
with duplicates_cte as
(
select *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, 
        percentage_laid_off, `date`, stage, country, funds_raised_millions
	) as row_num
	FROM layoffs_work
)
select *
from duplicates_cte
where row_num > 1;

-- Create a new table to store cleaned data
CREATE TABLE `layoffs_work2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert cleaned data into layoffs_works2
insert into layoffs_work2
select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_work;


select *
from layoffs_work2;
-- Removes duplicates rows 
delete 
from layoffs_works
where row_num > 1;

-- 2. Standardice the data
select company, trim(company)
from layoffs_work2
order by 1;

update layoffs_work2
set company = trim(company);

select distinct industry
from layoffs_work2
order by 1;

update layoffs_work2
set industry ='Crypto'
where industry like 'crypto%'; 

select distinct country
from layoffs_work2
order by 1;

update layoffs_work2
set country ='United States'
where country like 'United States%';
-- Convert `date` column to proper date format
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_work2;

update layoffs_work2
set date = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_work2
modify column `date` date;

-- Null Values 

select *
from layoffs_work2
where total_laid_off is Null
and percentage_laid_off is Null;

select *
from layoffs_work2
where company = 'Airbnb';

select t1.industry, t2.industry
from layoffs_work2 t1
join layoffs_work2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_work2 t1
join layoffs_work2 t2
	on t1.company = t2.company
    and t1.location = t2.location
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_work2 
set industry = null
where industry = '';

alter table layoffs_work2
drop column row_num;
