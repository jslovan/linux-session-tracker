CREATE TABLE if not exists session_history (
	start_ts timestamp,
	end_ts timestamp,
	username text,
	sesssion_id text
	);


BEGIN TRANSACTION;

CREATE TEMPORARY TABLE _durations AS
       SELECT session_id, username, start_ts, end_ts
       FROM (
       	    SELECT lag(ts) OVER same_session as start_ts, ts AS end_ts,
	    	   username, session_id, active
       	    FROM (
	    	 SELECT ts, username, session_id, active, previous_active
	 	 FROM (
	 	      SELECT ts, username, session_id, active,
     	 	      	     lag(active, 1, -1) OVER same_session AS previous_active
     	 	 	     FROM sessions_log
			     WINDOW same_session AS (
       	 	     	     	    PARTITION BY session_id, username
       		     		    ORDER BY ts ASC
       		     		    )
		) WHERE previous_active != active
	    ) WINDOW same_session AS (
       	 	     PARTITION BY session_id, username
       		     ORDER BY ts ASC
       		     )
	)
	WHERE active = 0 AND start_ts is not NULL;

INSERT INTO session_history
       SELECT session_id, username, start_ts, end_ts
       FROM _durations;


DELETE FROM sessions_log WHERE ROWID IN (
	SELECT ROWID
	       FROM sessions_log JOIN
	       	    (SELECT session_id, username, max(end_ts) AS max_ts
		     FROM _durations
		     GROUP BY session_id, username
		     ) AS max_end_time
	       ON sessions_log.username = max_end_time.username AND
	       sessions_log.ts <= max_end_time.max_ts
	);

DROP TABLE _durations;

COMMIT;
