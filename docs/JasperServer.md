
## Replay a failed job:
Fetch the Job ID:
```sql
SELECT
label, occurrence_date, trigger_group, job_name, job_group, jb.description, trigger_state, trigger_type, misfire_instr
FROM qrtz_triggers  qt
JOIN JIREPORTJOB jb on id::text = substr(qt.job_name, 5,LENGTH(qt.job_name))
, jilogevent jl where (event_text LIKE '%ReportJobs.' ||  job_name ||'%')
and occurrence_date > now() - interval '7 hours' order by occurrence_date desc
```
Run the following api call:

```bash
curl -X POST http://jasperadmin:MYAWESOMEPASSWORD@localhost:8080/jasperserver/rest_v2/jobs/restart/ \
   -H "Content-Type: application/xml" \
   -H "Accept: application/xml" \
   -d "<jobIdList><jobId>49993</jobId><jobId>000001</jobId></jobIdList>"
```