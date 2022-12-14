# README

## Getting started

You'll need to have Docker installed. To start up the application in your local Docker environment:

```sh
git clone git@github.com:MohanThanigaivelan/rails_pg_latency_test.git
cd rails_pg_latency_test
docker-compose build
docker-compose up
```

## Overview

This project uses [Toxiproxy](https://github.com/Shopify/toxiproxy) to add latency toxics to postgres DB connection and [Benchmark](https://github.com/ruby/benchmark) for  measuring and reporting the time used to execute ruby code.


## Execution of queries in Sequential , load_async and Pipeline mode 

User model has a slow_query scope. 

```sh
scope :slow_query, ->(time) {
        where("SELECT true FROM pg_sleep(?)", time) } 
```

Each test case queries the user table five times with the above scope.

## Result

#### With Network Latency 5ms and 100 independent queries

| Query execution | 1ms                 | 3ms                  | 5ms                |
| --------------- |---------------------|----------------------|--------------------|
| sequential      | 93.27012500011733   | 120.86554200004684   | 132.50650000009045 |
| Query Pipeline  | 27.64462499999354   | 57.61070799985646    | 65.21970899984808  |
| load_async      | 50.84033399998589   | 58.64487500002724    | 61.87308299990946  |



#### With Network Latency 10ms and 100 independent queries

| Query execution | 1ms                 | 3ms                 | 5ms                |
| --------------- |---------------------|---------------------|--------------------|
| sequential      | 146.76754199990683  | 171.63583299998209  | 188.56237499994677 |
| Query Pipeline  | 32.16812499999833   | 56.63087499988251   | 66.88945799987778  |
| load_async      | 88.09399999995549   | 93.44212500013782   | 90.60524999995323  |

#### With Network Latency 50ms  and 100 independent queries

| Query execution | 1ms                  | 3ms                | 5ms                 |
| --------------- |----------------------|--------------------|---------------------|
| sequential      | 555.3861250000409    | 595.7117919999746  | 618.0218340000465   |
| Query Pipeline  | 75.59308400004738    | 100.53179199985607 | 112.13220900003762  |
| load_async      | 317.80800000001364   | 321.1978750000526  | 273.7884169998779   |


#### With Network Latency 5ms and 5 independent queries

| Query execution |     50ms              |   100ms           |   200ms            |
| --------------- | --------------------- | ----------------- | ------------------ |
| sequential      | 317.67500000205473    | 562.7299999978277 | 1070.5280000001949 |
| Query Pipeline  | 274.8590000010154     | 528.1780000004801 | 1031.2940000003437 |
| load_async      | 73.73899999947753     | 124.1809999992256 | 223.64100000049802 |



#### With Network Latency 10ms and 5 independent queries

| Query execution |     50ms              |   100ms            |   200ms            |
| --------------- | --------------------- | ------------------ | ------------------ |
| sequential      | 339.2099999982747     | 608.7550000011106  | 1106.4839999999094 |
| Query Pipeline  | 280.3139999996347     | 533.330999998725   | 1034.879999999248  |
| load_async      | 95.96700000111014     | 145.80299999943236 | 243.3019999989483  |

#### With Network Latency 50ms  and 5 independent queries

| Query execution |     50ms              |   100ms            |   200ms            |
| --------------- | --------------------- | ------------------ | ------------------ |
| sequential      | 551.3370000007853     | 798.3370000001742  | 1307.9340000003867 |
| Query Pipeline  | 321.9839999983378     | 573.526000000129   | 1076.732000001357  |
| load_async      | 223.16399999908754    | 266.85899999938556 | 367.21699999907287 |


## Run tests

Run test cases to view the results of query execution in sequential, load_async and pipeline mode 

```sh
docker exec -it web bash
rspec
```

## load_async setup

When the queries are executed with load_async option for the first time, Rails tries to establish new database connections and hence the queries take longer. An initial step has been added to setup the pool of active connections, which could then be used by the subsequent test cases.

## load_async limitation

- load_async can only be called on ActiveRecord::Relation instance. Hence, load_async doesn't work on some finder_methods such as find , find_by, first, last. 
- load_async queries are never lazy loaded but work similarly to calling to_a on an ActiveRecord_Relation object in a separate thread.
- load_async query inside a transaction would execute in foreground.


## Observation on Query pipeline

When using query pipeline mode , it is observed that it saves time of (no_of_queries - 1) * network_latency . 

