-- Get all failed scheduled jobs
SELECT
label, occurrence_date, trigger_group, job_name, job_group, jb.description, trigger_state, trigger_type, misfire_instr
FROM qrtz_triggers  qt
JOIN JIREPORTJOB jb on id::text = substr(qt.job_name, 5,LENGTH(qt.job_name))
, jilogevent jl where (event_text LIKE '%ReportJobs.' ||  job_name ||'%')
and occurrence_date > now() - interval '7 hours' order by occurrence_date desc

-- Extract list of scheduled Jobs 
SELECT
to_timestamp(cast(next_fire_time/1000 as bigint)) as next_fire,
to_timestamp(cast(prev_fire_time/1000 as bigint)) as prev_fire,
label,
cron_expression, trigger_state,
report_unit_uri, string_agg(address, ', ')
FROM qrtz_triggers  qt
join qrtz_job_details qjd using (job_name)
LEFT join qrtz_cron_triggers qct on (qt.trigger_name=qct.trigger_name and trigger_type = 'CRON')
LEFT Join qrtz_simple_triggers qst on (qst.trigger_name=qt.trigger_name and trigger_type = 'SIMPLE')
JOIN JIREPORTJOB jb on id::text = substr(qt.job_name, 5,LENGTH(qt.job_name))
 
LEFT JOIN jireportjobmail jbm on (mail_notification = jbm.id)
LEFT JOIN jireportjobmailrecipient jbr ON (jbr.destination_id = jbm.id)
where trigger_state != 'PAUSED'
GROUP BY 1,2,3,4,5,6
order by 1,3

-- Users activity / with version report stripped out 
WITH tb AS (
	SELECT DISTINCT
	 u.username, u.emailaddress, 
	 trim(both ' ' from replace(regexp_replace(LOWER(r.name) , 'v\d|v.\d|\d|\d.\d', '', 'g'), '_', ' ')) as name, 
	 trim(both ' ' from replace(regexp_replace(LOWER(r.label) , 'v\d|v.\d|\d|\d.\d', '', 'g'), '_', ' ')) as label,
	 COUNT(ae.id), 
	 MAX(ae.event_date) AS latest
	FROM jiaccessevent ae
	LEFT JOIN jiuser u ON (ae.user_id = u.id)
	LEFT JOIN jiresource r ON (ae.resource_id = r.id)
	WHERE r.resourcetype = 'com.jaspersoft.jasperserver.api.metadata.jasperreports.domain.ReportUnit'
	AND username not in ('jasperadmin')
	GROUP BY u.username, u.emailaddress, 
	trim(both ' ' from replace(regexp_replace(LOWER(r.name) , 'v\d|v.\d|\d|\d.\d', '', 'g'), '_', ' ')),
	trim(both ' ' from replace(regexp_replace(LOWER(r.label) , 'v\d|v.\d|\d|\d.\d', '', 'g'), '_', ' '))
)
SELECT distinct username, emailaddress, name, label, sum(count) as count, max(latest)  as latest
FROM tb 
GROUP BY username, emailaddress, name, label
ORDER BY 4,1

