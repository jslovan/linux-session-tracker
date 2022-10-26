{
    "dashboard": {
        "annotations": {
          "list": [
            {
              "builtIn": 1,
              "datasource": {
                "type": "grafana",
                "uid": "-- Grafana --"
              },
              "enable": true,
              "hide": true,
              "iconColor": "rgba(0, 211, 255, 1)",
              "name": "Annotations & Alerts",
              "target": {
                "limit": 100,
                "matchAny": false,
                "tags": [],
                "type": "dashboard"
              },
              "type": "dashboard"
            }
          ]
        },
        "editable": true,
        "fiscalYearStartMonth": 0,
        "graphTooltip": 0,
        "id": null,
        "links": [],
        "liveNow": false,
        "panels": [
          {
            "datasource": {
              "type": "frser-sqlite-datasource",
              "uid": "UID"
            },
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 1,
                  "drawStyle": "bars",
                  "fillOpacity": 61,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "lineInterpolation": "linear",
                  "lineWidth": 1,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "auto",
                  "spanNulls": false,
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
                      "value": null
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
                "showLegend": true
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
                  "uid": "UID"
                },
                "hide": false,
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
              "uid": "UID"
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
                    "legend": false,
                    "tooltip": false,
                    "viz": false
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
                      "value": null
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
              "combine": false,
              "legend": {
                "calcs": [
                  "mean",
                  "max",
                  "count"
                ],
                "displayMode": "list",
                "placement": "bottom",
                "showLegend": true
              }
            },
            "repeat": "user",
            "repeatDirection": "v",
            "targets": [
              {
                "datasource": {
                  "type": "frser-sqlite-datasource",
                  "uid": "UID"
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
              "uid": "UID"
            },
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "Session duration",
                  "axisPlacement": "auto",
                  "barAlignment": 1,
                  "drawStyle": "bars",
                  "fillOpacity": 61,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "lineInterpolation": "linear",
                  "lineWidth": 1,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "auto",
                  "spanNulls": false,
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
                      "value": null
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
                "showLegend": true
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
                  "uid": "UID"
                },
                "hide": false,
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
                "selected": true,
                "text": [
                  "All"
                ],
                "value": [
                  "$__all"
                ]
              },
              "datasource": {
                "type": "frser-sqlite-datasource",
                "uid": "UID"
              },
              "definition": "select distinct username from session_history where start_ts between $__from / 1000 and $__to / 1000",
              "hide": 0,
              "includeAll": true,
              "multi": true,
              "name": "user",
              "options": [],
              "query": "select distinct username from session_history where start_ts between $__from / 1000 and $__to / 1000",
              "refresh": 2,
              "regex": "",
              "skipUrlSync": false,
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
        "uid": null,
        "version": 1,
        "weekStart": ""
    },
    "folderId": 0,
    "overwrite": true
}
