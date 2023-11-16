## Print all prime numbers < 1000 in a list with space separator

### PSQL
```sql
WITH nset AS (SELECT generate_series(2, 1000, 1) AS n),
fset AS (
	SELECT t1.n
	FROM nset t1
	JOIN nset t2 ON (t1.n != t2.n)
	WHERE t2.n != t1.n
	GROUP BY 1
	HAVING min(t1.n % t2.n) != 0
	ORDER BY 1
	)
SELECT STRING_AGG(n::text, ' ') FROM fset
```

### MySQL
```sql
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 1000
), calc as (
    SELECT t1.n, min(t1.n MOD t2.n) as tt
       FROM ( select n from cte ) t1
       JOIN ( select n from cte ) t2
       where t2.n != t1.n and t2.n > 1 and t1.n !=1
       group by 1
       order by 1,2
)
select GROUP_CONCAT(n ORDER BY n SEPARATOR ' ') from calc where tt != 0;   
```


## Generate series
### PSQL
```sql
-- date
SELECT generate_series(date_trunc('month', now() - interval '6 month'), now(), INTERVAL '1 month') 
-- numbers
SELECT generate_series(2, 1000, 1)
```



## Automatically create table in postgres from csv file

[Load csv file function](https://stackoverflow.com/questions/2987433/how-to-import-csv-file-data-into-a-postgresql-table)
