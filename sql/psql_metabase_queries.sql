
-- Export user activity cards & dashboard
COPY (
	select timestamp, email, first_name, last_name, last_login, model, model_id, coalesce(cl.name, rd.name) as card_dash_name 
	from view_log vl 
	join core_user cu on (vl.user_id=cu.id) 
	left join report_card cl on (cl.id=model_id and model = 'card') 
	left join report_dashboard rd on (rd.id=model_id and model = 'dashboard') 
	where timestamp > now() - interval '1 month') 
TO '/tmp/activity.csv' DELIMITER '|' CSV HEADER;