{
    "id": ID,
    "uid": "UID",
    "orgId": ORGID,
    "name": "SQLite Session Tracker",
    "type": "frser-sqlite-datasource",
    "typeLogoUrl": "",
    "access": "proxy",
    "url": "",
    "user": "",
    "database": "",
    "basicAuth": false,
    "basicAuthUser": "",
    "withCredentials": false,
    "isDefault": false,
    "jsonData": {
      "pathPrefix": "file:",
      "pathOptions": "mode=ro",
      "path": "/var/lib/linux-session-tracker/store.db"
    },
    "secureJsonFields": {},
    "version": 1,
    "readOnly": false,
    "accessControl": {
      "alert.instances.external:read": true,
      "alert.instances.external:write": true,
      "alert.notifications.external:read": true,
      "alert.notifications.external:write": true,
      "alert.rules.external:read": true,
      "alert.rules.external:write": true,
      "datasources.id:read": true,
      "datasources:delete": false,
      "datasources:query": true,
      "datasources:read": true,
      "datasources:write": false
    }
}
