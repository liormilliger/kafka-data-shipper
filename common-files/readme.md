# Dev ops test

The repository contains the following:

- init.sql - contains the init script to bootstrap and seed the mysql db
- common - java/maven project with common entity classes
- [producer](#producer) - java/maven project (spring-boot app) that binds to http port 9000 reads from the db and publishes data to kafka
- [consumer](#Consumer) - java/maven project (spring-boot app) that consumes the kafka topic and updates the db

## Producer

The producer binds to http port 9000 and accepts post commands:

```http
POST http://localhost:9000/producer/?count=100
Accept: */*
Cache-Control: no-cache
```

where count is the number of items to publish. it will then read the number of items requested from the db and publish them to the kafka topic... settings are located under `src/main/resources/application.properties` relevant properties are:

- `spring.datasource.url` maps to the mysql db
- `spring.kafka.bootstrap-servers` maps to the kafka servers
- `app.topic` sets the kafka topic to write to

## Consumer

the consumer starts a service and acts as a consumer to the kafka topic.
When messages arrive they are stored back into a shado table in the db (with some fx)

settings are located under `src/main/resources/application.properties` relevant properties are:

- `spring.datasource.url` maps to the mysql db
- `spring.kafka.bootstrap-servers` maps to the kafka servers
- `app.topic` sets the kafka topic to consume messages from

## Building

both the [producer](#Producer) and [consumer](#Consumer) projects relay on the common project.

so build order is:

1. `mvn install -f ./common`
2. `mvn install -f ./producer`
3. `mvn install -f ./consumer`

and containerazation would be:

1. `docker build -t test/producer ./producer`
2. `docker build -t test/consumer ./consumer`

and execution would be:

1. `docker run -p 9000:9000 test/producer`
2. `docker run test/consumer`

> make sure all configs are set correctly for the mysql and kafka servers
