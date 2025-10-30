#!/bin/sh

sudo docker run -d -v odoo-db:/var/lib/postgresql/data -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15

sudo docker run -d -v odoo-data:/var/lib/odoo -d -p 8069:8069 --name odoo --link db:db -t odoo


