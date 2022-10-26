import requests
import os


GRAFANA_API_KEY = os.environ.get('GRAFANA_API_KEY')


create_data_source = {
  "name": "SQLite Session Tracker",
  "type": "frser-sqlite-datasource",
  "access": "proxy",
  "isDefault": False
}


def update_data_source(id=None, uid=None, orgId=None, **kwds):
    return {
        "id": int(id),
        "uid": str(uid),
        "orgId": int(orgId),
        "name": kwds.get('name', "SQLite Session Tracker") ,
        "type": "frser-sqlite-datasource",
        "typeLogoUrl": "",
        "access": "proxy",
        "url": "",
        "user": "",
        "database": "",
        "basicAuth": False,
        "basicAuthUser": "",
        "withCredentials": False,
        "isDefault": False,
        "jsonData": {
          "pathPrefix": "file:",
          "pathOptions": "mode=ro",
          "path": "/var/lib/linux-session-tracker/store.db"
        },
        "secureJsonFields": {},
        "version": 1,
        "readOnly": False,
        "accessControl": {
          "alert.instances.external:read": True,
          "alert.instances.external:write": True,
          "alert.notifications.external:read": True,
          "alert.notifications.external:write": True,
          "alert.rules.external:read": True,
          "alert.rules.external:write": True,
          "datasources.id:read": True,
          "datasources:delete": False,
          "datasources:query": True,
          "datasources:read": True,
          "datasources:write": False
        }
    }


def create_dash(uid=None, **_rest):
    return {
        "dashboard": {
            "annotations": {
              "list": [
                {
                  "builtIn": 1,
                  "datasource": {
                    "type": "grafana",
                    "uid": "-- Grafana --"
                  },
                  "enable": True,
                  "hide": True,
                  "iconColor": "rgba(0, 211, 255, 1)",
                  "name": "Annotations & Alerts",
                  "target": {
                    "limit": 100,
                    "matchAny": False,
                    "tags": [],
                    "type": "dashboard"
                  },
                  "type": "dashboard"
                }
              ]
            },
            "editable": True,
            "fiscalYearStartMonth": 0,
            "graphTooltip": 0,
            "id": None,
            "links": [],
            "liveNow": False,
            "panels": [
              {
                "datasource": {
                  "type": "frser-sqlite-datasource",
                  "uid": uid
                },
                "fieldConfig": {
                  "defaults": {
                    "color": {
                      "mode": "palette-classic"
                    },
                    "custom": {
                      "axisCenteredZero": False,
                      "axisColorMode": "text",
                      "axisLabel": "",
                      "axisPlacement": "auto",
                      "barAlignment": 1,
                      "drawStyle": "bars",
                      "fillOpacity": 61,
                      "gradientMode": "none",
                      "hideFrom": {
                        "legend": False,
                        "tooltip": False,
                        "viz": False
                      },
                      "lineInterpolation": "linear",
                      "lineWidth": 1,
                      "pointSize": 5,
                      "scaleDistribution": {
                        "type": "linear"
                      },
                      "showPoints": "auto",
                      "spanNulls": False,
                      "stacking": {
                        "group": "A",
                        "mode": "normal"
                      },
                      "thresholdsStyle": {
                        "mode": "off"
                      }
                    },
                    "mappings": [],
                    "thresholds": {
                      "mode": "absolute",
                      "steps": [
                        {
                          "color": "green",
                          "value": None
                        },
                        {
                          "color": "red",
                          "value": 80
                        }
                      ]
                    },
                    "unit": "dtdurations"
                  },
                  "overrides": []
                },
                "gridPos": {
                  "h": 9,
                  "w": 12,
                  "x": 0,
                  "y": 0
                },
                "id": 2,
                "options": {
                  "legend": {
                    "calcs": [],
                    "displayMode": "list",
                    "placement": "bottom",
                    "showLegend": True
                  },
                  "tooltip": {
                    "mode": "single",
                    "sort": "none"
                  }
                },
                "pluginVersion": "8.5.2",
                "targets": [
                  {
                    "datasource": {
                      "type": "frser-sqlite-datasource",
                      "uid": uid
                    },
                    "hide": False,
                    "queryText": "SELECT  $__unixEpochGroupSeconds(start_ts, 86400) AS ts, username,  SUM(end_ts - start_ts) as screen_time\nFROM session_history\nWHERE start_ts BETWEEN $__from / 1000 AND $__to / 1000\nGROUP BY $__unixEpochGroupSeconds(start_ts, 86400), username\nORDER BY ts ASC, username ASC;\n",
                    "queryType": "time series",
                    "rawQueryText": "SELECT  $__unixEpochGroupSeconds(start_ts, 86400) AS ts, username,  SUM(end_ts - start_ts) as screen_time\nFROM session_history\nWHERE start_ts BETWEEN $__from / 1000 AND $__to / 1000\nGROUP BY $__unixEpochGroupSeconds(start_ts, 86400), username\nORDER BY ts ASC, username ASC;\n",
                    "refId": "A",
                    "timeColumns": [
                      "time",
                      "ts"
                    ]
                  }
                ],
                "title": "Daily screen time",
                "transformations": [],
                "type": "timeseries"
              },
              {
                "datasource": {
                  "type": "frser-sqlite-datasource",
                  "uid": uid
                },
                "fieldConfig": {
                  "defaults": {
                    "color": {
                      "mode": "thresholds"
                    },
                    "custom": {
                      "fillOpacity": 80,
                      "gradientMode": "none",
                      "hideFrom": {
                        "legend": False,
                        "tooltip": False,
                        "viz": False
                      },
                      "lineWidth": 1
                    },
                    "mappings": [],
                    "min": 0,
                    "thresholds": {
                      "mode": "absolute",
                      "steps": [
                        {
                          "color": "green",
                          "value": None
                        }
                      ]
                    },
                    "unit": "dtdurations"
                  },
                  "overrides": []
                },
                "gridPos": {
                  "h": 8,
                  "w": 12,
                  "x": 12,
                  "y": 0
                },
                "id": 5,
                "options": {
                  "bucketOffset": 1,
                  "bucketSize": 600,
                  "combine": False,
                  "legend": {
                    "calcs": [
                      "mean",
                      "max",
                      "count"
                    ],
                    "displayMode": "list",
                    "placement": "bottom",
                    "showLegend": True
                  }
                },
                "repeat": "user",
                "repeatDirection": "v",
                "targets": [
                  {
                    "datasource": {
                      "type": "frser-sqlite-datasource",
                      "uid": uid
                    },
                    "queryText": "SELECT  end_ts - start_ts as screen_time\nFROM session_history\nWHERE start_ts BETWEEN ($__to / 1000  - 2592000) AND $__to / 1000 \n               AND username = \"$user\" ; ",
                    "queryType": "table",
                    "rawQueryText": "SELECT  end_ts - start_ts as screen_time\nFROM session_history\nWHERE start_ts BETWEEN ($__to / 1000  - 2592000) AND $__to / 1000 \n               AND username = \"$user\" ; ",
                    "refId": "A",
                    "timeColumns": [
                      "time",
                      "ts"
                    ]
                  }
                ],
                "title": "Session lenghts distribution ($user)",
                "type": "histogram"
              },
              {
                "datasource": {
                  "type": "frser-sqlite-datasource",
                  "uid": uid
                },
                "fieldConfig": {
                  "defaults": {
                    "color": {
                      "mode": "palette-classic"
                    },
                    "custom": {
                      "axisCenteredZero": False,
                      "axisColorMode": "text",
                      "axisLabel": "Session duration",
                      "axisPlacement": "auto",
                      "barAlignment": 1,
                      "drawStyle": "bars",
                      "fillOpacity": 61,
                      "gradientMode": "none",
                      "hideFrom": {
                        "legend": False,
                        "tooltip": False,
                        "viz": False
                      },
                      "lineInterpolation": "linear",
                      "lineWidth": 1,
                      "pointSize": 5,
                      "scaleDistribution": {
                        "type": "linear"
                      },
                      "showPoints": "auto",
                      "spanNulls": False,
                      "stacking": {
                        "group": "A",
                        "mode": "none"
                      },
                      "thresholdsStyle": {
                        "mode": "off"
                      }
                    },
                    "mappings": [],
                    "thresholds": {
                      "mode": "absolute",
                      "steps": [
                        {
                          "color": "green",
                          "value": None
                        },
                        {
                          "color": "red",
                          "value": 80
                        }
                      ]
                    },
                    "unit": "dtdurations"
                  },
                  "overrides": []
                },
                "gridPos": {
                  "h": 9,
                  "w": 12,
                  "x": 0,
                  "y": 9
                },
                "id": 3,
                "options": {
                  "legend": {
                    "calcs": [
                      "mean",
                      "sum"
                    ],
                    "displayMode": "table",
                    "placement": "bottom",
                    "showLegend": True
                  },
                  "tooltip": {
                    "mode": "single",
                    "sort": "none"
                  }
                },
                "pluginVersion": "8.5.2",
                "targets": [
                  {
                    "datasource": {
                      "type": "frser-sqlite-datasource",
                      "uid": uid
                    },
                    "hide": False,
                    "queryText": "SELECT  start_ts AS ts, username,  end_ts - start_ts as screen_time\nFROM session_history\nWHERE start_ts BETWEEN $__from / 1000 AND $__to / 1000\nORDER BY ts ASC, username ASC;\n",
                    "queryType": "time series",
                    "rawQueryText": "SELECT  start_ts AS ts, username,  end_ts - start_ts as screen_time\nFROM session_history\nWHERE start_ts BETWEEN $__from / 1000 AND $__to / 1000\nORDER BY ts ASC, username ASC;\n",
                    "refId": "A",
                    "timeColumns": [
                      "time",
                      "ts"
                    ]
                  }
                ],
                "title": "Sessions",
                "transformations": [],
                "type": "timeseries"
              }
            ],
            "schemaVersion": 37,
            "style": "dark",
            "tags": [],
            "templating": {
              "list": [
                {
                  "current": {
                    "selected": True,
                    "text": [
                      "All"
                    ],
                    "value": [
                      "$__all"
                    ]
                  },
                  "datasource": {
                    "type": "frser-sqlite-datasource",
                    "uid": uid
                  },
                  "definition": "select distinct username from session_history where start_ts between $__from / 1000 and $__to / 1000",
                  "hide": 0,
                  "includeAll": True,
                  "multi": True,
                  "name": "user",
                  "options": [],
                  "query": "select distinct username from session_history where start_ts between $__from / 1000 and $__to / 1000",
                  "refresh": 2,
                  "regex": "",
                  "skipUrlSync": False,
                  "sort": 1,
                  "type": "query"
                }
              ]
            },
            "time": {
              "from": "now-90d",
              "to": "now"
            },
            "timepicker": {},
            "timezone": "",
            "title": "Desktop screen time",
            "uid": None,
            "version": 1,
            "weekStart": ""
        },
        "folderId": 0,
        "overwrite": True
        }


with requests.Session() as req:

    if GRAFANA_API_KEY:
        print("Using Grafana API Token ...")
        req.headers.update({'Authorization': 'Bearer {}'.format(GRAFANA_API_KEY)})
    else:
        print("Trying username:password ...")
        req.auth = ('admin', 'admin')

    initiation = req.post('http://localhost:3000/api/datasources',
                          json=create_data_source)
    initiation.raise_for_status()

    dsource = initiation.json()
    update_data = update_data_source(**dsource['datasource'])

    update_req = req.put(
        'http://localhost:3000/api/datasources/{}'.format(dsource["datasource"]["id"]),
        json=update_data
    )
    update_req.raise_for_status()

    dash_req = create_dash(**dsource['datasource'])
    ud_req = req.post('http://localhost:3000/api/dashboards/db',
                      json=dash_req)

    ud_req.raise_for_status()


print("Done.")
