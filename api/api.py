#! /usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later

import psycopg2
import psycopg2.extras
import json
import sys
import os
from werkzeug.exceptions import HTTPException, NotFound, InternalServerError
from werkzeug.routing import Map, Rule
from werkzeug.wrappers import Request, Response
from openrailwaymap_api.facility_api import FacilityAPI
from openrailwaymap_api.milestone_api import MilestoneAPI
from openrailwaymap_api.status_api import StatusAPI

import sqlite3

with sqlite3.connect(':memory:') as connection:
    connection.enable_load_extension(True)
    connection.execute("select load_extension('spatialite')")
    print(connection.execute('SELECT spatialite_version()').fetchone()[0])

# import spatialite
# TODO use file
# with spatialite.connect(':memory:') as db:


def connect_db():
    conn = psycopg2.connect(dbname='gis', user='postgres', host='db')
    psycopg2.extras.register_hstore(conn)
    return conn

class OpenRailwayMapAPI:

    db_conn = connect_db()

    def __init__(self):
        self.url_map = Map([
            Rule('/api/facility', endpoint=FacilityAPI, methods=('GET',)),
            Rule('/api/milestone', endpoint=MilestoneAPI, methods=('GET',)),
            Rule('/api/status', endpoint=StatusAPI, methods=('GET',)),
        ])

    def ensure_db_connection_alive(self):
        if self.db_conn.closed != 0:
            self.db_conn = connect_db()

    def dispatch_request(self, environ, start_response):
        request = Request(environ)
        urls = self.url_map.bind_to_environ(environ)
        response = None
        try:
            endpoint, args = urls.match()
            self.ensure_db_connection_alive()
            response = endpoint(self.db_conn)(request.args)
        except HTTPException as e:
            return e
        except Exception as e:
            print('Error during request:', e, file=sys.stderr)
            return InternalServerError()
        finally:
            if not response:
                self.db_conn.close()
                self.db_conn = connect_db()
        return response

    def wsgi_app(self, environ, start_response):
        request = Request(environ)
        response = self.dispatch_request(request)
        return response(environ, start_response)


def application(environ, start_response):
    openrailwaymap_api = OpenRailwayMapAPI()
    response = openrailwaymap_api.dispatch_request(environ, start_response)
    return response(environ, start_response)


if __name__ == '__main__':
    openrailwaymap_api = OpenRailwayMapAPI()
    from werkzeug.serving import run_simple
    run_simple('::', int(os.environ['PORT']), application, use_debugger=True, use_reloader=True)
