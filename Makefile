.PHONY: install uninstall clean check_env install-test verify-files verify-systemd verify-grafana-plugin verify-grafana-datasource verify-grafana-dashboard

# Variables
LIB=/usr/local/lib
VAR=/var/lib
ETC=/etc
GRAFANA=http://localhost:3000/api
PYTHON=/usr/bin/python3
CURL=curl -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $(GRAFANA_API_KEY)"
INSTALL=/usr/bin/install
SYSTEMCTL=systemctl

# Directories to be created during installation
install_dirs=$(VAR)/linux-session-tracker $(LIB)/linux-session-tracker $(LIB)/systemd/system

# Check for required commands
$(SYSTEMCTL):
	@command -v $(SYSTEMCTL) >/dev/null 2>&1 || { echo >&2 "$(SYSTEMCTL) is required but not installed. Aborting."; exit 1; }

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

# Pro CI prostředí se předpokládá instalace pluginu přes GF_INSTALL_PLUGINS v Docker konfiguraci Grafana.
# V lokálním prostředí by se plugin instaloval jinak. Zde pouze zajistíme existenci adresáře.
$(VAR)/grafana/plugins/frser-sqlite-datasource:
	$(INSTALL) -d $@

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

install-test: install verify-files verify-systemd verify-grafana-plugin verify-grafana-datasource verify-grafana-dashboard
	@echo "--------------------------------------------------------"
	@echo "All installation tests passed successfully!"
	@echo "--------------------------------------------------------"

verify-files:
	@echo "Verifying installation of files and directories..."
	@test -f $(LIB)/linux-session-tracker/session-tracker.py || { echo "ERROR: session-tracker.py not found!"; exit 1; }
	@test -f $(LIB)/systemd/system/session-tracker.service || { echo "ERROR: session-tracker.service not found!"; exit 1; }
	@test -f $(ETC)/cron.hourly/assemble_sessions || { echo "ERROR: assemble_sessions not found!"; exit 1; }
	@test -d $(VAR)/linux-session-tracker/ || { echo "ERROR: /var/lib/linux-session-tracker/ not found!"; exit 1; }
	@test -f $(VAR)/linux-session-tracker/store.db || { echo "ERROR: store.db not found!"; exit 1; }
	@echo "All files and directories are in place."

verify-systemd: $(SYSTEMCTL)
	@echo "Verifying systemd service..."
	@$(SYSTEMCTL) daemon-reload
	@$(SYSTEMCTL) is-enabled session-tracker.service || { echo "ERROR: Service is not enabled!"; exit 1; }
	@$(SYSTEMCTL) is-active session-tracker.service || { echo "ERROR: Service is not active!"; exit 1; }
	@echo "The session-tracker.service is enabled and active."

verify-grafana-plugin: check_env
	@echo "Verifying Grafana plugin installation..."
	@curl -s -H "Authorization: Bearer $(GRAFANA_API_KEY)" http://localhost:3000/api/plugins | \
	jq -e '.[] | select(.id == "frser-sqlite-datasource")' > /dev/null || { echo "ERROR: Grafana plugin frser-sqlite-datasource not found or not listed via API!"; exit 1; }
	@echo "Grafana plugin frser-sqlite-datasource is installed."

verify-grafana-datasource: check_env
	@echo "Verifying Grafana datasource creation..."
	@curl -s -H "Authorization: Bearer $(GRAFANA_API_KEY)" http://localhost:3000/api/datasources | \
	jq -e '.[] | select(.name == "Session Tracker DB")' > /dev/null || { echo "ERROR: Grafana datasource 'Session Tracker DB' not found!"; exit 1; }
	@echo "Grafana datasource 'Session Tracker DB' was created."

verify-grafana-dashboard: check_env
	@echo "Verifying Grafana dashboard creation..."
	@curl -s -H "Authorization: Bearer $(GRAFANA_API_KEY)" http://localhost:3000/api/search?query=Desktop%20Session%20Tracker | \
	jq -e '.[0] | select(.title == "Desktop Session Tracker")' > /dev/null || { echo "ERROR: Grafana dashboard 'Desktop Session Tracker' not found!"; exit 1; }
	@echo "Grafana dashboard 'Desktop Session Tracker' was created."
