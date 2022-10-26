set -ex

declare -a CURL
CURL=(curl -H 'Content-Type: application/json' -H 'Accept: application/json')

if [ -n "${GRAFANA_API_KEY}" ]; then
    CURL+=(-H "Authorization: Bearer ${GRAFANA_API_KEY}")
    GRAFANA=http://localhost:3000/api
else
    GRAFANA=http://admin:admin@localhost:3000/api
fi

# create data source
"${CURL[@]}" -X POST -d @grafana/create_source.json $GRAFANA/datasources > _created_ds.json

# read id, uid and orgid from the _created_ds.jon
read GFID GFUID GFORGID <<< `jq -rcM '.datasource | ( .id, .uid, .orgId )' _created_ds.json | xargs`

m4 -D ID=${GFID} -D UID=${GFUID} -D ORGID=${GFORGID} grafana/update_data_source.m4 > _update_ds.json

"${CURL[@]}" -X PUT -d @_update_ds.json $GRAFANA/datasources/${GFID}

m4 -D UID=${GFUID} grafana/create_dashboard.m4 > _create_dsh.json
"${CURL[@]}" -X POST -d @_create_dsh.json $GRAFANA/dashboards/db


