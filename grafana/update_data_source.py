import json
import pathlib
import argparse


def update_data_source(dsid=None, uid=None, orgid=None):
    return {
        "id": dsid,
        "uid": uid,
        "orgId": orgid,
        "name": "Session Tracker DB", # Changed data source name
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
          "path": "/var/lib/linux-session-tracker/store.db" # Ensured correct path
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
          "datasdatasources:delete": False,
          "datasources:query": True,
          "datasources:read": True,
          "datasources:write": False
        }
    }


parser = argparse.ArgumentParser(description='Produce "update data source" request for grafana API.')
parser.add_argument('--gf_dsh', type=pathlib.Path, required=True, help='The datasource description of the created dashboard.')

args = parser.parse_args()
with open(args.gf_dsh) as gf_dsh_file:
    gf_dsh = json.load(gf_dsh_file)['datasource']
    print(
        json.dumps(
            update_data_source(
                dsid=gf_dsh['id'],
                uid=gf_dsh['uid'],
                orgid=gf_dsh['orgId']
            )
        )
    )
