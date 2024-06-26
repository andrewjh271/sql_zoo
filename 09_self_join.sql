-- 1. How many stops are in the database.
SELECT COUNT(*)
FROM stops;

-- 2. Find the id value for the stop 'Craiglockhart'
SELECT id
FROM stops
WHERE name = 'Craiglockhart';

-- 3. Give the id and the name for the stops on the '4' 'LRT' service.
SELECT
  stops.id,
  stops.name
FROM route
INNER JOIN stops ON route.stop = stops.id
WHERE
  route.num = 4
  AND route.company = 'LRT'
ORDER BY route.pos;
-- No mention is made in the question that the list should be ordered by position.

-- 4. The query shown gives the number of routes that visit either London Road (149) or Craiglockhart (53). Run the query and notice the two services that link these stops have a count of 2. Add a HAVING clause to restrict the output to these two routes.
SELECT
  company,
  num,
  COUNT(*)
FROM route
WHERE
  stop = 149
  OR stop = 53
GROUP BY
  company,
  num
HAVING COUNT(*) = 2;

-- 5. Execute the self join shown and observe that b.stop gives all the places you can get to from Craiglockhart, without changing routes. Change the query so that it shows the services from Craiglockhart to London Road.
SELECT
  a.company,
  a.num,
  a.stop,
  b.stop
FROM route AS a
JOIN route AS b
  ON a.company = b.company
  AND a.num = b.num
JOIN stops ON b.stop = stops.id
WHERE
  a.stop = 53
  AND stops.name = 'London Road';

-- 6. The query shown is similar to the previous one, however by joining two copies of the stops table we can refer to stops by name rather than by number. Change the query so that the services between 'Craiglockhart' and 'London Road' are shown. If you are tired of these places try 'Fairmilehead' against 'Tollcross'
SELECT
  a.company,
  a.num,
  stopa.name,
  stopb.name
FROM route AS a
JOIN route AS b
  ON a.company = b.company
  AND a.num=b.num
JOIN stops AS stopa ON a.stop = stopa.id
JOIN stops AS stopb ON b.stop = stopb.id
WHERE
  stopa.name = 'Craiglockhart'
  AND stopb.name = 'London Road';

-- 7. Give a list of all the services which connect stops 115 and 137 ('Haymarket' and 'Leith')
SELECT DISTINCT
  a.company,
  a.num
FROM route AS a
INNER JOIN route AS b
  ON a.company = b.company
  AND a.num = b.num
WHERE
  a.stop = 115
  AND b.stop = 137;
-- The COUNT method from question 4 is not possible because of some routes being circular and including the initial stop twice

-- 8. Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'
SELECT DISTINCT
  a.company,
  a.num
FROM route a
INNER JOIN route b
  ON a.company = b.company
  AND a.num = b.num
INNER JOIN stops AS stopa ON a.stop = stopa.id
INNER JOIN stops AS stopb ON b.stop = stopb.id
WHERE
  stopa.name = 'Craiglockhart'
  AND stopb.name = 'Tollcross';

-- 9. Give a distinct list of the stops which may be reached from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. Include the company and bus no. of the relevant services.
SELECT DISTINCT
  stopb.name,
  b.company,
  b.num
FROM route AS a
INNER JOIN route AS b
  ON a.company = b.company
  AND a.num = b.num
INNER JOIN stops AS stopa ON a.stop = stopa.id
INNER JOIN stops AS stopb ON b.stop = stopb.id
WHERE
  stopa.name = 'Craiglockhart'
  AND a.company = 'LRT';

-- 10. Find the routes involving two buses that can go from Craiglockhart to Lochend. Show the bus no. and company for the first bus, the name of the stop for the transfer, and the bus no. and company for the second bus.
SELECT
  a.num AS Num1,
  a.comp AS Comp1,
  a.transfer AS Transfer,
  b.num AS Num2,
  b.comp AS Comp2
FROM
  (SELECT DISTINCT
  a.num AS num,
  a.company AS comp,
  stopb.name AS transfer
  FROM route AS a
  INNER JOIN route AS b
    ON a.company = b.company
    AND a.num = b.num
  INNER JOIN stops AS stopa ON a.stop = stopa.id
  INNER JOIN stops AS stopb ON b.stop = stopb.id
  WHERE
    stopa.name = 'Craiglockhart'
  ) AS a
INNER JOIN
  (SELECT DISTINCT
    a.num AS num,
    a.company AS comp,
    stopb.name AS transfer
  FROM route AS a
  INNER JOIN route AS b
    ON a.company = b.company
    AND a.num = b.num
  INNER JOIN stops AS stopa ON a.stop = stopa.id
  INNER JOIN stops AS stopb ON b.stop = stopb.id
  WHERE
    stopa.name = 'Lochend'
  ) AS b
  ON a.transfer = b.transfer
ORDER BY
  Num1,
  Transfer,
  Num2;

-- Order not specified in problem

SELECT Bus1.num AS 'Bus 1',
       Bus1.company AS 'Company 1',
       stops.name AS Transfer,
       Bus2.num AS 'Bus 2',
       Bus2.company AS 'Company 2'
FROM
  (SELECT a.num, a.stop AS transfer, a.company
  FROM route AS a
  INNER JOIN route AS b
  ON a.num = b.num  AND a.company = b.company
  INNER JOIN stops ON b.stop = stops.id
  WHERE stops.name = 'Craiglockhart'
  ) AS Bus1
INNER JOIN
  (SELECT a.num, a.stop AS transfer, b.company
  FROM route AS a
  INNER JOIN route AS b
  ON a.num = b.num  AND a.company = b.company
  INNER JOIN stops ON b.stop = stops.id
  WHERE stops.name = 'Lochend'
  ) AS Bus2
ON Bus1.transfer = Bus2.transfer
INNER JOIN stops ON Bus1.transfer = stops.id
ORDER BY Bus1.num, stops.name, Bus2.num;

-- Almost the same answer, with different decisions in line breaks and naming — maybe clearer?
-- Joins with stops table at end to get the name of the transfer, rather than joining twice with stops within each inner SELECT