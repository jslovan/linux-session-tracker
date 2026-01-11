import argparse
import json
import pathlib
import sys


def create_dashboard(uid=None):
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
                      "spanNones": False,
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
                      "spanNones": False,
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
            "title": "Desktop Session Tracker", # Changed title
            "uid": None,
            "version": 1,
            "weekStart": ""
        },
        "folderId": 0,
        "overwrite": True
    }


parser = argparse.ArgumentParser(description='Produce "create dashboard" request for grafana API.')
parser.add_argument('--gf_dsh', type=pathlib.Path, required=True, help='The datasource description of the created dashboard.')

args = parser.parse_args()
with open(args.gf_dsh) as gf_dsh_file:
    gf_dsh = json.load(gf_dsh_file)['datasource']
    print(
        json.dumps(
            create_dashboard(
                uid=gf_dsh['uid']
            )
        )
    )
