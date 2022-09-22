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

#### With Network Latency 50ms

| Query execution |     Time              |
| --------------- | --------------------- |
| sequential      | 15.31580271600069     |
| Query Pipeline  | 15.087736591000066    |
| load_async      | 7.286523711998598     |



#### With Network Latency 2000ms

| Query execution |     Time              |
| --------------- | --------------------- |
| sequential      | 25.075979429002473    |
| Query Pipeline  | 17.024850215999322    |
| load_async      | 25.072874052999396    |


## Run tests

Run test cases to view the results of query execution in sequential, load_async and pipeline mode 

```sh
docker exec -it web bash
rspec
```




