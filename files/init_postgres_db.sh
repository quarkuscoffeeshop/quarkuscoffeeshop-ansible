#!/bin/bash

if [ -z ${PGPASSWORD} ];
then 
  echo "postgres password not in enviornment."
  exit 1
fi 

psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "CREATE SCHEMA coffeeshop AUTHORIZATION coffeshopadmin;"
psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "alter table if exists coffeeshop.LineItems
    drop constraint if exists FK6fhxopytha3nnbpbfmpiv4xgn;"
psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "drop table if exists coffeeshop.LineItems cascade;
drop table if exists coffeeshop.Orders cascade;
drop table if exists coffeeshop.OutboxEvent cascade;"
psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "create table coffeeshop.LineItems (
                           itemId varchar(255) not null,
                           item varchar(255),
                           lineItemStatus varchar(255),
                           name varchar(255),
                           price numeric(19, 2),
                           order_id varchar(255) not null,
                           primary key (itemId)
);"

psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "create table coffeeshop.Orders (
                        order_id varchar(255) not null,
                        loyaltyMemberId varchar(255),
                        location     varchar(255),
                        orderSource varchar(255),
                        orderStatus varchar(255),
                        timestamp timestamp,
                        primary key (order_id)
);"

psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "create table coffeeshop.OutboxEvent (
                             id uuid not null,
                             aggregatetype varchar(255) not null,
                             aggregateid varchar(255) not null,
                             type varchar(255) not null,
                             timestamp timestamp not null,
                             payload varchar(8000),
                             primary key (id)
);"

psql -h coffeeshopdb -p 5432 -U coffeshopadmin coffeeshopdb  -c "alter table if exists coffeeshop.LineItems
    add constraint FK6fhxopytha3nnbpbfmpiv4xgn
        foreign key (order_id)
            references coffeeshop.Orders;"