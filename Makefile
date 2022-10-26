.PHONY: install uninstall clean

LIB=/usr/local/lib
VAR=/var/lib
ETC=/etc
GRAFANA = http://localhost:3000/api
CURL = curl -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $(GRAFANA_API_KEY)"
install_dirs = $(VAR)/linux-session-tracker $(LIB)/linux-session-tracker $(LIB)/systemd/system

install: $(LIB)/linux-session-tracker/session-tracker.py $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions $(VAR)/grafana/plugins/frser-sqlite-datasource _create_dsh.json
	systemctl enable session-tracker && systemctl start session-tracker

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

_created_ds.json:
	$(CURL) -X POST -d @grafana/create_source.json $(GRAFANA)/datasources > $@

_gfids: _created_ds.json
	jq -rcM '.datasource | ( .id, .uid, .orgId )' _created_ds.json | xargs > _gfids

_update_ds.json: _gfids
	read GFID GFUID GFORGID < _gfids \
	&& m4 -D ID=$${GFID} -D UID=$${GFUID} -D ORGID=$${GFORGID} grafana/update_data_source.m4 > $@ \
	&& $(CURL) -X PUT -d @_update_ds.json $(GRAFANA)/datasources/$${GFID}

_create_dsh.json: _update_ds.json _gfids
	read GFID GFUID GFORGID < _gfids \
	&& m4 -D UID=$${GFUID} grafana/create_dashboard.m4 > $@ \
	&& $(CURL) -X POST -d @_create_dsh.json $(GRAFANA)/dashboards/db

clean:
	- rm _*.json _gfids

uninstall:
	- systemctl stop session-tracker && systemctl disable session-tracker
	- rm -r $(LIB)/linux-session-tracker $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions
	echo "Leaving the database at " $(VAR)/linux-session-tracker
	echo "It must be deleted manually"
	echo "Possibly leaving datasource and dashboard in Grafana - must be deleted manually."
