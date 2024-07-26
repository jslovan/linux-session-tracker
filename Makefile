.PHONY: install uninstall clean check_env

# Variables
LIB=/usr/local/lib
VAR=/var/lib
ETC=/etc
GRAFANA=http://localhost:3000/api
PYTHON=/usr/bin/python3
CURL=curl -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $(GRAFANA_API_KEY)"
INSTALL=/usr/bin/install
SYSTEMCTL=systemctl
GRAFANA_CLI=grafana-cli

# Directories to be created during installation
install_dirs=$(VAR)/linux-session-tracker $(LIB)/linux-session-tracker $(LIB)/systemd/system

# Check for required commands
$(SYSTEMCTL):
	@command -v $(SYSTEMCTL) >/dev/null 2>&1 || { echo >&2 "$(SYSTEMCTL) is required but not installed. Aborting."; exit 1; }

$(GRAFANA_CLI):
	@command -v $(GRAFANA_CLI) >/dev/null 2>&1 || { echo >&2 "$(GRAFANA_CLI) is required but not installed. Aborting."; exit 1; }

# Check for required environment variable
check_env:
	@if [ -z "$(GRAFANA_API_KEY)" ]; then \
		echo "Error: GRAFANA_API_KEY environment variable is not set or is empty."; \
		exit 1; \
	fi

install: check_env $(install_dirs) $(LIB)/linux-session-tracker/session-tracker.py $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions $(VAR)/grafana/plugins/frser-sqlite-datasource _create_dsh.json $(VAR)/linux-session-tracker/store.db
	$(SYSTEMCTL) enable session-tracker
	$(SYSTEMCTL) start session-tracker

$(install_dirs):
	$(INSTALL) -d $@

$(LIB)/linux-session-tracker/session-tracker.py: session-tracker.py | $(LIB)/linux-session-tracker
	$(INSTALL) -t $(LIB)/linux-session-tracker $<

$(LIB)/systemd/system/session-tracker.service: session-tracker.service | $(LIB)/systemd/system
	$(INSTALL) -t $(LIB)/systemd/system $<

$(ETC)/cron.hourly/assemble_sessions: assemble_sessions | $(ETC)/cron.hourly
	$(INSTALL) -t $(ETC)/cron.hourly $<

$(VAR)/linux-session-tracker/store.db: | $(VAR)/linux-session-tracker
	touch $@

$(VAR)/grafana/plugins/frser-sqlite-datasource: | $(GRAFANA_CLI)
	$(GRAFANA_CLI) plugins install frser-sqlite-datasource
	$(SYSTEMCTL) restart grafana-server

_created_ds.json:
	$(CURL) -X POST -d @grafana/create_source.json $(GRAFANA)/datasources > $@

_gfid: _created_ds.json
	$(PYTHON) grafana/datasource_id.py --gf_dsh _created_ds.json > $@

_update_ds.json: _created_ds.json _gfid
	read GFID < _gfid && $(PYTHON) grafana/update_data_source.py --gf_dsh _created_ds.json > $@ && $(CURL) -X PUT -d @_update_ds.json $(GRAFANA)/datasources/$${GFID}

_create_dsh.json: _update_ds.json _created_ds.json
	$(PYTHON) grafana/create_dashboard.py --gf_dsh _created_ds.json > $@ && $(CURL) -X POST -d @_create_dsh.json $(GRAFANA)/dashboards/db

clean:
	-rm -f _*.json

uninstall:
	-$(SYSTEMCTL) stop session-tracker
	-$(SYSTEMCTL) disable session-tracker
	-rm -r $(LIB)/linux-session-tracker $(LIB)/systemd/system/session-tracker.service $(ETC)/cron.hourly/assemble_sessions
	echo "Leaving the database at " $(VAR)/linux-session-tracker
	echo "It must be deleted manually"
	echo "Possibly leaving datasource and dashboard in Grafana - must be deleted manually."
