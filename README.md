# Data Vault Modeling

## Introduction

The repository contains the SQL scripts for creating a Data Vault model
for a PostgreSQL demo database available at https://postgrespro.com/community/demodb. 
The er-diagrams and some SQL script contained here are accompanying material 
for the article 

[Practical Introduction to Data Vault Modeling](https://medium.com/@nuhad.shaabani/practical-introduction-to-data-vault-modeling-1c7fdf5b9014)

published on medium.

## Structure
There are two versions of the modeling discussed in the article.
The directory dv-version1 contains the code of the first version, while dv-version2 contains
the code of the second version.
The directory ER-Diagram contains all er-diagrams created by the author except for
the diagram bookings-schema, which was adapted from https://postgrespro.com/docs/postgrespro/10/apjs02.html
The zip file bookings-demo-small-en contains the script for creating the small version of the demo database.

## How to Install
1. Download and unzip data-vault-modelling-mainzip
2. CD into directory with that file.
3. Unzip the file bookings-demo-small-en
4. Install the small version of the demo database
   - psql -f bookings-demo-small-en/demo-small-en-20170815.sql -U postgres
     
   Note that a new database named demo will be created. If the database already exists,it will be dropped and recreated. 

5. Install Version 1
   - psql -f dv-version1/create_version1_tables.sql -U postgres -d demo
   - psql -f dv-version1/load_version1_tables.sql -U postgres -d demo
     
   The tables of Version 1 will be created in a new schema named dv. If the schema dv already exists, it will be dropped and recreated. 

6. Install Version 2
   - psql -f dv-version2/create_version2_tables.sql -U postgres -d demo
   - psql -f dv-version2/load_version2_tables.sql -U postgres -d demo
     
  The tables of Version 2 will be created in a new schema named dv1. If the schema dv1 already exists, it will be dropped and recreated. 


All scripts of Version 1 and Version 2 are tested on the small version of the demo database. 
