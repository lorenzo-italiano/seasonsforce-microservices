# Microservices Git Module
##### for SeasonsForce Project

<a target="_blank" href="https://github.com/lorenzo-italiano/Seasonsforce">
  <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-global-green?logo=github&style=for-the-badge">
</a>

## Description
This is the common repository for all the microservices of SeasonsForce project. It is a Spring Boot application that uses the Spring Cloud Gateway library to route requests to the appropriate microservice. It also uses the Eureka library to register itself as a service with the Eureka server. This allows the api gateway to discover the other microservices and route requests to them.

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

---

© Romain Frezier & Lorenzo Italiano - IG5 Polytech Montpellier - 2023
