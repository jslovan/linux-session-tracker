.PHONY: install uninstall

LIB=/usr/local/lib
VAR=/var/lib
ETC=/etc

# https://grafana.com/grafana/plugins/frser-sqlite-datasource/

install_dirs = $(VAR)/linux-session-tracker $(LIB)/linux-session-tracker $(LIB)/systemd/system

install: $(LIB)/linux-session-tracker/session-tracker.py $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions $(VAR)/grafana/plugins/frser-sqlite-datasource
	/usr/bin/python into_grafana.py && systemctl enable session-tracker && systemctl start session-tracker

$(install_dirs):
	/usr/bin/install -d $@

$(LIB)/linux-session-tracker/session-tracker.py: $(LIB)/linux-session-tracker
	/usr/bin/install -t $(LIB)/linux-session-tracker session-tracker.py

$(LIB)/systemd/system/session-tracker.service: $(LIB)/systemd/system
	/usr/bin/install -t $(LIB)/systemd/system session-tracker.service

$(ETC)/cron.hourly/assemble_sessions: $(ETC)/cron.hourly
	/usr/bin/install -t $(ETC)/cron.hourly assemble_sessions

$(VAR)/grafana/plugins/frser-sqlite-datasource:
	grafana-cli plugins install frser-sqlite-datasource

uninstall:
	- systemctl stop session-tracker && systemctl disable session-tracker
	- rm -r $(LIB)/linux-session-tracker $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions
	echo "Leaving the database at " $(VAR)/linux-session-tracker
	echo "It must be deleted manually"
	echo "Possibly leaving datasource and dashboard in Grafana - must be deleted manually."
