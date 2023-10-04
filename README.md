# Microservices Git Module
##### for SeasonsForce Project

## Description
This is the API Gateway for the SeasonsForce project. It is a Spring Boot application that uses the Spring Cloud Gateway library to route requests to the appropriate microservice. It also uses the Eureka library to register itself as a service with the Eureka server. This allows the api gateway to discover the other microservices and route requests to them.

## How to add a new submodule to the project
In order to add a new submodule to the project, you must add a new submodule to this repository. The following is an example of how to add a new submodule to this repository.

``` bash
git submodule add <url of the submodule repository>
```

## How to update all submodules
In order to update all submodules, you must run the following command.

``` bash
./update-submodules.sh
```

## Devs: Romain Frezier & Lorenzo Italiano