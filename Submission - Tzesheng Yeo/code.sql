-- Prepared by TzeSheng 'tingling' Yeo

/*-----------------------
SECTION 1.0 -- OVERVIEW OF DATA
-----------------------*/

SELECT *
FROM page_visits
LIMIT 10;

/*-----------------------
RESULT 1.1
-----------------------*/
SELECT 
	COUNT(DISTINCT utm_campaign) '# of campaigns'
FROM page_visits;

SELECT 
	COUNT(DISTINCT utm_source) '# of sources'
FROM page_visits;

/*-----------------------
RESULT 1.2
-----------------------*/
SELECT 
	utm_campaign, 
	utm_source 
FROM page_visits
GROUP BY 1
ORDER BY 1; 

/*-----------------------
RESULT 1.3
-----------------------*/
SELECT 
	DISTINCT(page_name)
FROM page_visits; 

/*-----------------------
RESULT 2.1
-----------------------*/
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id)

SELECT 
/*1*/	pv.utm_campaign AS 'Campaign Name',
/*2*/	COUNT(*) AS 'First-touch attributes'
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
GROUP BY 1
ORDER BY 2 DESC;

/*-----------------------
RESULT 2.2
-----------------------*/
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id)

SELECT 
/*1*/	pv.utm_campaign AS 'Campaign Name',
/*2*/	COUNT(*) AS 'Last-touch attributes'
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
GROUP BY 1
ORDER BY 2 DESC;


/*-----------------------
RESULT 2.3
-----------------------*/
WITH num AS (
  SELECT COUNT(DISTINCT user_id) AS 'totalpurc'
  FROM page_visits 
  WHERE page_name = '4 - purchase'),

den AS (
  SELECT COUNT(DISTINCT user_id) AS 'totaluser'
  FROM page_visits)

SELECT 
	num.totalpurc,
	den.totaluser,
 	ROUND(100.00 * num.totalpurc / den.totaluser,2) AS '%'
FROM num
JOIN den;


/*-----------------------
RESULT 2.4
-----------------------*/
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id)

SELECT 
/*1*/	pv.utm_campaign AS 'Campaign Name',
/*2*/	COUNT(*) AS 'Last-touch attributes'
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
WHERE page_name = '4 - purchase'
GROUP BY 1
ORDER BY 2 DESC;


/*-----------------------
RESULT 2.5
-----------------------*/
-- Last-touch subquery
WITH last_touch AS (
    SELECT 
  			pv.user_id,
        MAX(timestamp) AS last_touch_at
    FROM page_visits pv
    GROUP BY 1)

-- Main query
SELECT 
/*1*/	pv.user_id AS 'User ID',
/*2*/	pv.timestamp AS 'Time visited page 4',
/*3*/	lt.last_touch_at AS 'Last touch at'
FROM page_visits pv
JOIN last_touch lt
	ON pv.user_id = lt.user_id
WHERE (pv.timestamp <> lt.last_touch_at
	AND page_name = '4 - purchase')
ORDER BY 1 ASC;


/*-----------------------
RESULT 2.6
-----------------------*/
-- Subquery #1 : Last-touch-time
WITH last_touch AS (
    SELECT 
	pv.user_id,
        MAX(timestamp) AS last_touch_at
    FROM page_visits pv
    GROUP BY 1),

-- Subquery #2 : Revisiting users
revisit_users AS (
  SELECT 
    	pv.user_id
  FROM page_visits pv
  JOIN last_touch lt
	ON pv.user_id = lt.user_id
  WHERE (pv.timestamp <> lt.last_touch_at
	AND page_name = '4 - purchase'))
   
-- Main query
SELECT 
/*1*/		pv.user_id AS 'User ID',
/*2*/		pv.timestamp AS 'Timestamp',
/*3*/		pv.page_name AS 'Page Name'
FROM page_visits pv
JOIN revisit_users ru
	ON pv.user_id = ru.user_id
ORDER BY 1, 2;


/*-----------------------
RESULT 2.7
-----------------------*/
-- Subquery #1 : First-touch
WITH first_touch AS (
    SELECT 
  	pv.user_id,
        MIN(timestamp) AS first_touch_at,
  	utm_campaign AS ft_campaign
    FROM page_visits pv
    GROUP BY 1),

-- Subquery #2 : Last-touch
last_touch AS (
    SELECT 
	pv.user_id,
        MAX(timestamp) AS last_touch_at,
	utm_campaign AS lt_campaign
    FROM page_visits pv
    GROUP BY 1)
   
-- Main query
SELECT 
/*1*/		pv.user_id AS 'User ID',
/*2*/		ft.ft_campaign AS 'First touch campaign',
/*3*/		lt.lt_campaign AS 'Last touch campaign'
FROM page_visits pv
JOIN first_touch ft
	ON pv.user_id = ft.user_id,
last_touch lt
	ON pv.user_id = lt.user_id
GROUP BY 1  
ORDER BY 1, 2
LIMIT 20;


/*-----------------------
RESULT 2.8
-----------------------*/
-- Subquery #1 : First-touch-time
WITH first_touch AS (
    SELECT 
	pv.user_id,
	MIN(timestamp) AS first_touch_at,
	utm_campaign AS ft_campaign
    FROM page_visits pv
    GROUP BY 1),

-- Subquery #2 : Last-touch-time
last_touch AS (
    SELECT 
			pv.user_id,
			MAX(timestamp) AS last_touch_at,
  	utm_campaign AS lt_campaign
    FROM page_visits pv
    GROUP BY 1),
   
-- Subquery #3 : Find if is different campaign
is_diff_qry AS (
    SELECT 
      pv.user_id AS 'User ID',
      CASE 
        WHEN ft.ft_campaign <> lt.lt_campaign THEN 1
        ELSE 0
      END AS 'is_diff_campgn'
    FROM page_visits pv
    JOIN first_touch ft
      ON pv.user_id = ft.user_id,
    last_touch lt
      ON pv.user_id = lt.user_id
    GROUP BY 1)

-- Main query
SELECT SUM(is_diff_campgn) AS 'Total'
FROM is_diff_qry;
