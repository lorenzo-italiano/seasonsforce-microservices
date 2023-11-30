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

## All the submodules

<div style="display: flex; flex-direction: row; justify-content: center;">
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-address-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Address-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-availability-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Availability-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-company-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Company-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-config-server">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Config Server-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-discovery-service">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Discovery Service-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-experience-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Experience-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-invoice-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Invoice-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-keycloak">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Keycloak-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-notification-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Notification-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-offer-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Offer-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-payment-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Payment-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-reference-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Reference-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-review-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-Review-important?logo=github&style=for-the-badge">
  </a>
  <a target="_blank" href="https://github.com/lorenzo-italiano/seasonsforce-ms-user-api">
    <img alt="github link" src="https://img.shields.io/badge/SEASONFORCE-User-important?logo=github&style=for-the-badge">
  </a>
</div>

---

© Romain Frezier & Lorenzo Italiano - IG5 Polytech Montpellier - 2023
