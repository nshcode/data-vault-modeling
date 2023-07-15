# Data Vault Modeling

## Introduction

The repository contains the SQL scripts for creating a Data Vault model
for a PostgreSQL demo database available at https://postgrespro.com/community/demodb 
The er-diagrams and some SQL script contained here are accompanying material 
for the article Practical Introduction to Data Vault Modeling 
published on medium.

## Structure
There are two versions of the modeling discussed in the article.
The directory dv-version1 contains the code of the first version, while dv-version2 contains
the code of the second version.
The directory ER-Diagram contains all er-diagrams created by the author except for
the diagram bookings-schema, which was adapted from https://postgrespro.com/docs/postgrespro/10/apjs02.html
The zip file bookings-demo-small-en contains the script for creating the small version of the demo database.

## How to Install
1. Download and unzip data-vault-modelling,zip
2. CD into directory with that file. 
3. Install the small version of the demo database
 psql -f bookings-demo-mall-en -U postgres


psql -f dv-version1/create_version1_tables.sql -U postgres -d demo
psql -f dv-version1/load_version1_tables.sql -U postgres -d demo

psql -f dv-version2/create_version2_tables.sql -U postgres -d demo
psql -f dv-version2/load_version2_tables.sql -U postgres -d demo

