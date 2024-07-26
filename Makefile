.PHONY: install uninstall clean

LIB=/usr/local/lib
VAR=/var/lib
ETC=/etc
GRAFANA = http://localhost:3000/api
PYTHON=/usr/bin/python3
CURL = curl -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $(GRAFANA_API_KEY)"
install_dirs = $(VAR)/linux-session-tracker $(LIB)/linux-session-tracker $(LIB)/systemd/system

install: $(LIB)/linux-session-tracker/session-tracker.py $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions $(VAR)/grafana/plugins/frser-sqlite-datasource _create_dsh.json $(VAR)/linux-session-tracker/store.db
	systemctl enable session-tracker && systemctl start session-tracker

$(install_dirs):
	/usr/bin/install -d $@

$(LIB)/linux-session-tracker/session-tracker.py: $(LIB)/linux-session-tracker
	/usr/bin/install -t $(LIB)/linux-session-tracker session-tracker.py

$(LIB)/systemd/system/session-tracker.service: $(LIB)/systemd/system
	/usr/bin/install -t $(LIB)/systemd/system session-tracker.service

$(ETC)/cron.hourly/assemble_sessions: $(ETC)/cron.hourly
	/usr/bin/install -t $(ETC)/cron.hourly assemble_sessions

$(VAR)/linux-session-tracker/store.db: $(VAR)/linux-session-tracker
	touch $@

$(VAR)/grafana/plugins/frser-sqlite-datasource:
	grafana-cli plugins install frser-sqlite-datasource \
	&& systemctl restart grafana-server

_created_ds.json:
	$(CURL) -X POST -d @grafana/create_source.json $(GRAFANA)/datasources > $@

_gfid:	_created_ds.json
	$(PYTHON) grafana/datasource_id.py --gf_dsh _created_ds.json > $@

_update_ds.json: _created_ds.json _gfid
	read GFID < _gfid \
	&& $(PYTHON) grafana/update_data_source.py --gf_dsh _created_ds.json > $@ \
	&& $(CURL) -X PUT -d @_update_ds.json $(GRAFANA)/datasources/$${GFID}

_create_dsh.json: _update_ds.json _created_ds.json
	$(PYTHON) grafana/create_dashboard.py --gf_dsh _created_ds.json > $@ \
	&& $(CURL) -X POST -d @_create_dsh.json $(GRAFANA)/dashboards/db

clean:
	- rm _*.json

uninstall:
	- systemctl stop session-tracker && systemctl disable session-tracker
	- rm -r $(LIB)/linux-session-tracker $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions
	echo "Leaving the database at " $(VAR)/linux-session-tracker
	echo "It must be deleted manually"
	echo "Possibly leaving datasource and dashboard in Grafana - must be deleted manually."
