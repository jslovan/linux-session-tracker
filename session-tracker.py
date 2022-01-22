# -*- coding: utf-8 -*-
"""
Created on Thu Feb  7 18:04:29 2019

@author: jslovan
"""

from operator import attrgetter
from datetime import datetime
from pydbus import SystemBus
from gi.repository import GLib

import time
import sqlite3
from json import dumps


DB_PATH = '/var/lib/linux-session-tracker/store.db'
DB_PATH = './store.db'

now = datetime.now


def adapt_datetime(ts):
    return time.mktime(ts.timetuple())


class Storage_DAO(object):
    """
    Data Access Object for the store.  Backed by SQLite.
    Can:
        - init the database, create tables
        - insert_session
        - update_session
        - remove_session
        - remove_all
    """

    # active sessions
    tbl_name_active = 'sessions_in_progress'

    # column names active sessions:
    col_name_id = 'session_id'
    col_name_active = 'active'
    col_name_user = 'username'

    # sessions log
    tbl_name_log = 'sessions_log'

    #column names for session log
    col_name_timestamp = 'ts'

    # queries
    _insert_log_sql = (
        f"""
        INSERT INTO {tbl_name_log}({col_name_timestamp}, {col_name_id}, {col_name_user}, {col_name_active})
        VALUES (:ts, :id, :user, :active)
        """
    )

    def __init__(self, db_con):
        super().__init__()
        self.db_con = db_con
        self.init_tables()

    def init_tables(self):
        """
        Initializes DB tables.  Is nondestructive and idempotent.
        Returns None.
        """

        self.db_con.executescript(
            f"""
            create table if not exists {self.tbl_name_active} (
                {self.col_name_id} primary key asc,
                {self.col_name_active} integer,
                {self.col_name_user} text);
            create table if not exists {self.tbl_name_log} (
                {self.col_name_timestamp} timestamp,
                {self.col_name_id} text,
                {self.col_name_user} text,
                {self.col_name_active} integer);
            """
        )

    def insert_session(self, time: datetime, session_id: str, is_active: bool, username: str):
        """
        New session emerges.
        1. Insert it to table of active sessions and
        2. Insert current state into the session log.

        Returns: None, can raise and exception.
        """
        with self.db_con:
            self.db_con.execute(
                f"""
                REPLACE INTO {self.tbl_name_active}({self.col_name_id}, {self.col_name_active}, {self.col_name_user}) VALUES (:id, :active, :user)
                """,
                {'id': session_id, 'active': is_active, 'user': username}
                )

            self.db_con.execute(
                self._insert_log_sql,
                {'ts': time, 'id': session_id, 'user': username, 'active': is_active}
                )

    def update_session(self, time: datetime, session_id: str, is_active: bool):
        """
        Existing session changes (e.g. becomes inactive).
        1. Update the session state in table of active sessions and
        2. Insert the new state into the session log.

        Only existing session is subscribed for updates, so it always exists inside the DB.
        """
        with self.db_con:
            cur = self.db_con.execute(
                f"""
                UPDATE {self.tbl_name_active} SET {self.col_name_active} = :active WHERE {self.col_name_id} = :id
                RETURNING {self.col_name_user}
                """,
                {'id': session_id, 'active': is_active}
                )
            user = cur.fetchone()[0]

            self.db_con.execute(
                self._insert_log_sql,
                {'ts': time, 'id': session_id, 'user': user, 'active': is_active}
                )

    def remove_session(self, time: datetime, session_id: str):
        """
        Existing session ends.
        1. Remove it from table of sessions in progress and
        2. Insert the termination to the session log.
        """
        with self.db_con:
            cur = self.db_con.execute(
                f"""
                DELETE FROM {self.tbl_name_active} WHERE {self.col_name_id} = :id
                RETURNING {self.col_name_user}
                """,
                {'id': session_id}
                )
            user = cur.fetchone()

            if user is not None:    # there really is such a session
                self.db_con.execute(
                    self._insert_log_sql,
                    {'ts': time, 'id': session_id, 'user': user[0], 'active': False}
                    )

    def remove_all(self, time: datetime):
        """
        The system is halting.
        1. Empty the table of sessions in progress and
        2. Insert the termination for those active into the log.
        """
        with self.db_con:
            cur = self.db_con.execute(
                f"""
                DELETE FROM {self.tbl_name_active}
                RETURNING {self.col_name_id}, {self.col_name_user}, {self.col_name_active}
                """
                )
            deactivating = [row for row in cur.fetchall() if row[2]]

            if deactivating:
                self.db_con.executemany(
                    self._insert_log_sql,
                    [{'ts': time, 'id': sess[0], 'user': sess[1], 'active': False} for sess in deactivating]
                    )
        

class SessionTrack(object):
    detail_fields = ('Class', 'Name', 'Active')
    detail_getter = attrgetter(*detail_fields)

    def __init__(self, db_con, dbus):
        start_time = now()

        self.store = Storage_DAO(db_con)
        self.store.init_tables()

        self.dbus = dbus

        loginManager = system_bus.get('.login1')[
            'org.freedesktop.login1.Manager']
        loginManager.SessionNew.connect(
            lambda sender, session_id:
                self.newSession(now(), session_id)
            )
        loginManager.SessionRemoved.connect(
            lambda sender, session_id:
                self.store.remove_session(now(), session_id)
            )
        loginManager.PrepareForShutdown.connect(
            lambda sender: self.store.remove_all(now())
            )

        sessions = loginManager.ListSessions()
        for (_sid, _id, _uname, _ename, session_id) in sessions:
            self.newSession(start_time, session_id)

    def newSession(self, time, session_id):
        session_proxy = self.dbus.get(
            '.login1', session_id)

        session_detail = dict(
            zip(
                self.detail_fields,
                self.detail_getter(
                    session_proxy['org.freedesktop.login1.Session']
                )
            )
        )
        print("new session: ", session_detail)
        if session_detail['Class'] != "user":
            return

        self.store.insert_session(time, session_id, session_detail['Active'], session_detail['Name'])

        session_proxy["org.freedesktop.DBus.Properties"]\
            .PropertiesChanged.connect(
                lambda iface, changed, retracted: self.store.update_session(
                    now(), session_id, changed['Active'])
                )
        session_proxy["org.freedesktop.login1.Session"].Lock.connect(
            lambda: self.store.update_session(now(), session_id, False)
            )
        session_proxy["org.freedesktop.login1.Session"].Unlock.connect(
            lambda: self.store.update_session(now(), session_id, True)
            )


sqlite3.register_adapter(datetime, adapt_datetime)
db_con = sqlite3.connect(DB_PATH)

loop = GLib.MainLoop()
system_bus = SystemBus()

tracker = SessionTrack(db_con, system_bus)

try:
    loop.run()
finally:
    loop.quit()
    db_con.close()
