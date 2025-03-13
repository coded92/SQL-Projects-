-- Exploratory Data Analysis Project

SELECT * 
FROM world_layoffs.layoffs_work2;

-- EASIER QUERIES

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_work2;

-- Looking at Percentage to see how big these layoffs were
SELECT *
FROM layoffs_work2
WHERE percentage_laid_off = 1;

SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_work2
WHERE percentage_laid_off IS NOT NULL;

-- Which companies had 1 (100%) of their workforce laid off?
SELECT *
FROM layoffs_work2
WHERE percentage_laid_off = 1;

-- If we order by funds_raised_millions, we can see how big some of these companies were
SELECT *
FROM layoffs_work2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow, raised like 2 billion dollars and went under - ouch

-- SOMEWHAT TOUGHER QUERIES USING GROUP BY ----------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff
SELECT company, total_laid_off
FROM layoffs_work2
ORDER BY 2 DESC
LIMIT 5;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- Layoffs by location
SELECT location, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- Layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY country
ORDER BY 2 DESC;

-- Layoffs per year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
WHERE `date` IS not NULL
GROUP BY YEAR(date)
ORDER BY 1 ASC;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY industry
ORDER BY 2 DESC;

-- Layoffs by funding stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY stage
ORDER BY 2 DESC;

-- TOUGHER QUERIES ----------------------------------------------------------------------------------------------------------------------

-- Companies with the most layoffs per year
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_work2
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
  SELECT company, years, total_laid_off, 
         DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date, 1, 7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY dates
ORDER BY dates ASC;

-- Now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date, 1, 7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_work2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
