-- 1. Show the lastName, party and votes for the constituency 'S14000024' in 2017.
SELECT
  lastName,
  party,
  votes
FROM ge
WHERE
  constituency = 'S14000024'
  AND yr = 2017
ORDER BY votes DESC;

-- 2. Show the party and RANK for constituency S14000024 in 2017. List the output by party
SELECT
  party,
  votes,
  RANK() OVER (ORDER BY votes DESC) AS Rank
FROM ge
WHERE
  constituency = 'S14000024'
  AND yr = 2017
ORDER BY party;

-- 3. Use PARTITION to show the ranking of each party in S14000021 in each year. Include yr, party, votes and ranking (the party with the most votes is 1).
SELECT
  yr,
  party,
  votes,
  RANK() OVER (PARTITION BY yr ORDER BY votes DESC) AS rank
FROM ge
WHERE constituency = 'S14000021'
ORDER BY
  party,
  yr;

-- 4. Use PARTITION BY constituency to show the ranking of each party in Edinburgh in 2017. Order your results so the winners are shown first, then ordered by constituency.
-- Edinburgh constituencies are numbered S14000021 to S14000026.
SELECT
  constituency,
  party,
  votes,
  RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) AS rank
FROM ge
WHERE
  constituency BETWEEN 'S14000021' AND 'S14000026'
  AND yr  = 2017
ORDER BY
  rank,
  constituency;

-- 5. Show the parties that won for each Edinburgh constituency in 2017.
SELECT
  constituency,
  party
FROM ge AS x
WHERE
  constituency BETWEEN 'S14000021' AND 'S14000026'
  AND yr  = 2017
  AND votes = (SELECT MAX(votes)
              FROM ge AS y
              WHERE x.constituency = y.constituency
              AND yr = 2017)
ORDER BY
  constituency,
  votes DESC;

-- alternative...
SELECT a.constituency,
       a.party
FROM ge AS a
INNER JOIN
  (SELECT party, 
          constituency, 
          RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) as posn
  FROM ge
  WHERE 
    constituency BETWEEN 'S14000021' AND 'S14000026'
    AND yr  = 2017
  ) AS b
ON a.party = b.party 
  AND a.constituency = b.constituency
  AND b.posn = 1
WHERE 
  a.constituency BETWEEN 'S14000021' AND 'S14000026'
  AND a.yr  = 2017
ORDER BY constituency,
         votes DESC;



-- 6. Show how many seats for each party in Scotland in 2017.
-- You can use COUNT and GROUP BY to see how each party did in Scotland. Scottish constituencies start with 'S'
SELECT
  party,
  COUNT(*)
FROM ge AS x
WHERE
  constituency LIKE 'S%'
  AND yr  = 2017
  AND votes = (SELECT MAX(votes)
              FROM ge AS y
              WHERE x.constituency = y.constituency
              AND yr = 2017)
GROUP BY party;


-- A more confusing alternative...
SELECT a.party, COUNT(*)
FROM ge AS a
LEFT JOIN ge AS b
  ON a.constituency =  b.constituency
  AND a.yr = b.yr
  AND a.votes < b.votes
WHERE
  a.constituency LIKE 'S%'
  AND a.yr = 2017
  AND b.party IS NULL
GROUP BY a.party;

-- Left joins with self, matching constituency and year, and comparing party votes.
-- Only rows where a.votes < b.votes are selected, however because it's a LEFT JOIN,
-- the row where a.party = SNP = MAX(votes) is still selected once, even though there
-- are no cases where a.votes < b.votes. In this row, there are NULL values in the
-- b columns. The WHERE clause can select for that row.

-- constituency | year | a.party | a.votes | b.party | b.votes
--       1      | 2017 | DEM     | 1698    | CONSERV | 4032   
--       1      | 2017 | DEM     | 1698    | GREEN   | 2698   
--       1      | 2017 | DEM     | 1698    | LABOUR  | 3821   
--       1      | 2017 | DEM     | 1698    | INDPNDT | 2322
--       1      | 2017 | LABOUR  | 3821    | CONSERV | 4032
--       1      | 2017 | SNP     | 13821   |         |
--       1      | 2017 | GREEN   | 2698    | LABOUR  | 3821
--       1      | 2017 | GREEN   | 2698    | CONSERV | 4032
