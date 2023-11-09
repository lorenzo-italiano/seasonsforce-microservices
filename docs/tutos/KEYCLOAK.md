# How to set up Keycloak in a microservices architecture (using Spring Boot as API framework)

## Description

This file is a *tutorial* on how to set up keycloak in a microservices' architecture. It is not a tutorial in the traditional sense, but rather a collection of notes on how to set up keycloak in a microservices' architecture. It is meant to be used as a reference for future developers who need to set up keycloak in a microservices' architecture.

## Keycloak container

### Setting up the Keycloak container

The keycloak container is a docker container that runs the keycloak server. It is used to manage users and roles for the microservices. It is also used to authenticate users and generate access tokens for the microservices.

For this you need to have a Dockerfile for the Keycloak container, one for the Database container (PostgreSQL in this case) and a docker-compose.yml file to run both containers.

Here is the example of the Dockerfile for the Keycloak container:

```dockerfile
# Using Keycloak 22.0.4
FROM quay.io/keycloak/keycloak:22.0.4

# Start Keycloak in development mode, remove the -dev flag to start in production mode
CMD ["start-dev"]
```

Here is the example of the Dockerfile for the Database container:

```dockerfile
# Using PostgreSQL image (latest)
FROM postgres:latest
```

Here is the example of the docker-compose.yml file:

```yaml
version: '3'

services:
  keycloak:
    image: keycloak-server
    hostname: keycloak-server
    ports:
      - ${KEYCLOAK_PORT}
    build: .
    environment:
      KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN}
      KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD}
      KC_DB_URL_HOST: ${KC_DB_URL_HOST}
      KC_DB_PASSWORD: ${KC_DB_PASSWORD}
      KC_DB: ${KC_DB}
      KC_DB_USERNAME: ${KC_DB_USERNAME}
      KC_HEALTH_ENABLED: ${KC_HEALTH_ENABLED}
    depends_on:
      - db
    networks:
      - keycloak-network

  db:
    image: keycloak-db
    hostname: keycloak-db
    ports:
      - ${POSTGRES_PORT}
    volumes:
      - keycloak-db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    networks:
      - keycloak-network

networks:
  keycloak-network:

volumes:
  keycloak-db_data:
```

In this file, we can see that we have two services, one for the Keycloak server and one for the database. The Keycloak server depends on the database service, so the database service will start before the Keycloak server. The Keycloak server also uses the database service to store the users and roles.

There is also a network called keycloak-network. This network is used to connect the Keycloak server and the database service together. This allows the Keycloak server to communicate with the database service.

There is also a volume called keycloak-db_data. This volume is used to store the data for the database service. This allows the database service to persist data between restarts.

The values in the environment sections are declared in a `.env` file at the same root level as the docker-compose.yml file. This file is not included in the repository for security reasons. The following is an example of a `.env` file:

```dotenv
# Keycloak credentials
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin

# Keycloak database credentials
KC_DB_URL_HOST=keycloak-db
KC_DB_PASSWORD=password
KC_DB=postgres
KC_DB_USERNAME=keycloak

# Keycloak server configuration
KEYCLOAK_PORT=8080:8080
KC_HEALTH_ENABLED=true

# Postgres database credentials
POSTGRES_DB=keycloak
POSTGRES_USER=keycloak
POSTGRES_PASSWORD=password
POSTGRES_PORT=5432
```

### Running the Keycloak and Database containers

First you need to build the Keycloak and Database images. To do this, you must run the following command:

```bash
docker build -t keycloak-server .
docker build -t keycloak-db .
```

Then to run the Keycloak and Database containers, you must run the following command:

```bash
docker-compose up
```

### Setting up the Keycloak server

Once the Keycloak and Database containers are running, you can access the Keycloak server at http://localhost:8080. You can log in with the credentials specified in the `.env` file.

Once you are logged in, you can create a new realm. A realm is a collection of users, roles, and groups. It is used to manage users, roles, and groups. It is also used to manage the authentication of users.

Then create a new client. A client is an application that uses the Keycloak server to manage users, roles, and groups. It is used to manage the authentication of users.

Then create a new client role. A client role is a role that is specific to a client. It is used to manage the permissions of users for a specific client.

Then create a new realm role. A realm role is a role that is specific to a realm. It is used to manage the permissions of users for a specific realm.

Then link the client role to the realm role. This allows the client role to inherit the permissions of the realm role.

Then create a new user. A user is a person who uses the Keycloak server to manage users, roles, and groups. It is used to manage the authentication of users.

Then add credentials to the user. Credentials are used to authenticate users. They are used to manage the authentication of users.

## Add a route to the API Gateway to authenticate users

On the API Gateway, you need to add a route to authenticate users. Here is an example : 

```java
package springboot.keycloak.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {
    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("keycloak-route", r -> r
                        .path("/api/v1/auth/login")  // Matching path
                        .filters(f -> f.rewritePath("/api/v1/auth/login", "/realms/ <realm-name> /protocol/openid-connect/token")) // Rewrite the path
                        .uri("http://keycloak-server:8080")  // Target URL
                )
                // Other routes...
                .build();
    }
}
```

This path `http://keycloak-server:8080/realms/<realm-name>/protocol/openid-connect/token` is the path to authenticate users. You need to pass a body as x-www-form-urlencoded with the following parameters :

- `grant_type` : `password`
- `client_id` : `<client-id>`
- `username` : `<username>`
- `password` : `<password>`

This will return a JSON object that looks like this :

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJYU19pU2ZjX1lnX1NRYWM2eTBHeEdzeFFVOWJkNndmU2VLa2lBSDdkYnNvIn0.eyJleHAiOjE2OTcxODY1MDIsImlhdCI6MTY5NzE4NjIwMiwianRpIjoiOGMwMmY3YWMtZmMwYy00ZDFlLTliZjMtOTAzOGU4NTRiNjBhIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo5MDkwL3JlYWxtcy9zZWFzb25zLWZvcmNlIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImMwMDBkNTE5LTk4OGQtNDE1Mi1iYTJjLWRhYzcyOTFkMzFhMSIsInR5cCI6IkJlYXJlciIsImF6cCI6Im15Y2xpZW50Iiwic2Vzc2lvbl9zdGF0ZSI6IjYyZjYyYjFhLWMxM2ItNGIyNi1hZjFkLTAyMDExMjUzZDJlYiIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiLyoiXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbImRlZmF1bHQtcm9sZXMtc2Vhc29ucy1mb3JjZSIsIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6InByb2ZpbGUgZW1haWwiLCJzaWQiOiI2MmY2MmIxYS1jMTNiLTRiMjYtYWYxZC0wMjAxMTI1M2QyZWIiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6ImFkbWluIiwiZ2l2ZW5fbmFtZSI6IiIsImZhbWlseV9uYW1lIjoiIn0.NYTVyOFwY-LUt9lNe0MHJ1yJhH0WD2YWpXfA2taEOZfmsqgFwJ3tqVc5CZeqqqVxFKqYxLp-2zyb0Un6wYjKQyoxtHJyo8PiSUqBA0C-ATw5yAk-smkGZKx79dvCvi2ceDPjdwY_PTnFid8_VvWqOcKV02Bg28RPlu8w3XRk1jaDiO0nmND3OhhpPzTzccmPRrxePIkX_nal_EwwwWEA7urWLiK_DirTn1wV4qnFKh3anNMfNIP2JIx6pNcf_x64s5NSQAd6IRO6WXwuakL4n9d6hUS56FJSHz5a5Mi5M6v3A81uK75v8LQHqPD7bwG9YO8fBVrNV4Zb9lKNyduB6g",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwZDZmYzc2MS1iNmJjLTQ0MTQtYjliMC1hNDNkMDM5Y2FlMjUifQ.eyJleHAiOjE2OTcxODgwMDIsImlhdCI6MTY5NzE4NjIwMiwianRpIjoiMjg0NGI2MzYtZjM0NC00NDVjLWFkNWItMWY4Mzc4ODZlOTM3IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo5MDkwL3JlYWxtcy9zZWFzb25zLWZvcmNlIiwiYXVkIjoiaHR0cDovL2xvY2FsaG9zdDo5MDkwL3JlYWxtcy9zZWFzb25zLWZvcmNlIiwic3ViIjoiYzAwMGQ1MTktOTg4ZC00MTUyLWJhMmMtZGFjNzI5MWQzMWExIiwidHlwIjoiUmVmcmVzaCIsImF6cCI6Im15Y2xpZW50Iiwic2Vzc2lvbl9zdGF0ZSI6IjYyZjYyYjFhLWMxM2ItNGIyNi1hZjFkLTAyMDExMjUzZDJlYiIsInNjb3BlIjoicHJvZmlsZSBlbWFpbCIsInNpZCI6IjYyZjYyYjFhLWMxM2ItNGIyNi1hZjFkLTAyMDExMjUzZDJlYiJ9.0lDZt9RxvuPFhClVnBGcBToFKseguhxipLoGz-fENwA",
  "token_type": "Bearer",
  "not-before-policy": 0,
  "session_state": "62f62b1a-c13b-4b26-af1d-02011253d2eb",
  "scope": "profile email"
}
```

You can then use the `access_token` to authenticate users on the microservices.

## Setting up the microservices

### Add dependencies to the `pom.xml` file

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
</dependencies>
```

These dependencies are from Spring Security. They are used to authenticate users on the microservices through another provider (Keycloak in this case).

### Setting up the `application.properties` file


In the `application.properties` file, you need to add the following properties:

```properties
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://keycloak-server:8080/realms/<realm-name>
spring.security.oauth2.resourceserver.jwt.jwk-set-uri=${spring.security.oauth2.resourceserver.jwt.issuer-uri}/protocol/openid-connect/certs
```

This will tell the microservice to use the Keycloak server to authenticate users by using the `access_token` generated by the Keycloak server and validating it with the Keycloak server certs.

### Setting up the `SecurityConfig.java` file

```java
package springboot.keycloak.myapp.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

import static org.springframework.security.config.http.SessionCreationPolicy.STATELESS;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthConverter jwtAuthConverter = new JwtAuthConverter();

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests((auth) -> auth.anyRequest().authenticated());

        http
                .oauth2ResourceServer((oauth2) -> oauth2
                        .jwt((jwt) -> jwt
                                .jwtAuthenticationConverter(jwtAuthConverter)
                        )
                );

        http
                .sessionManagement((session) -> session.sessionCreationPolicy(STATELESS));

        return http.build();
    }
}
```

This `SecurityFilterChain` will intercept all requests and check if the user is authenticated (`.authorizeHttpRequests((auth) -> auth.anyRequest().authenticated())`).

If the user is not authenticated, it will return a `401 Unauthorized` error.

In this file, we use a `JwtAuthConverter`. This converter is here because Spring need to have a role name that start with `ROLE_`. Here is the code of the `JwtAuthConverter`:

```java
package springboot.keycloak.myapp.config;

import org.springframework.core.convert.converter.Converter;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Component
public class JwtAuthConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    private final JwtGrantedAuthoritiesConverter jwtGrantedAuthoritiesConverter;

    public JwtAuthConverter() {
        this.jwtGrantedAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();
    }

    // You can put these values in the `.env` file
    private final String principleAttribute = "preferred_username";
    private final String resourceId = "<client_name>"; 

    @Override
    public AbstractAuthenticationToken convert(@NonNull Jwt jwt) {
        Collection<GrantedAuthority> authorities = Stream.concat(
                jwtGrantedAuthoritiesConverter.convert(jwt).stream(),
                extractResourceRoles(jwt).stream()
        ).collect(Collectors.toSet());

        return new JwtAuthenticationToken(
                jwt,
                authorities,
                getPrincipleClaimName(jwt)
        );
    }

    private String getPrincipleClaimName(Jwt jwt) {
        return jwt.getClaim(principleAttribute);
    }

    private Collection<? extends GrantedAuthority> extractResourceRoles(Jwt jwt) {
        Map<String, Object> resourceAccess;
        Map<String, Object> resource;
        Collection<String> resourceRoles;
        if (jwt.getClaim("resource_access") == null) {
            return Set.of();
        }
        resourceAccess = jwt.getClaim("resource_access");

        if (resourceAccess.get(resourceId) == null) {
            return Set.of();
        }
        resource = (Map<String, Object>) resourceAccess.get(resourceId);

        resourceRoles = (Collection<String>) resource.get("roles");
        return resourceRoles
                .stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                .collect(Collectors.toSet());
    }
}
```

This converter will extract the roles from the `access_token` and add them to the `GrantedAuthority` with the prefix `ROLE_`.

### Use the `@PreAuthorize` annotation to secure endpoints

You can now use the `@PreAuthorize` annotation to secure endpoints. Here is an example:

```java
package springboot.keycloak.myapp.controller;

import springboot.keycloak.myapp.model.MyModel;
import springboot.keycloak.myapp.MyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/path")
public class MyController {

    private final MyService myService;

    @Autowired
    public MyController(MyService myService) {
        this.myService = myService;
    }
    
    // Only authenticated users can access this endpoint
    @GetMapping("/test")
    public String test1() {
        return "test for authenticated users";
    }

    // Only users with the role <admin_role_name> can access this endpoint
    @GetMapping("/test/admin")
    @PreAuthorize("hasRole('<admin_role_name>')") // Admin role of the client (see the config of Keycloak described before)
    public String test2() {
        return "test for admin";
    }
    
    // Only users with the role <user_role_name> can access this endpoint
    @GetMapping("/test/user")
    @PreAuthorize("hasRole('<user_role_name>')") // User role of the client (see the config of Keycloak described before)
    public String test3() {
        return "test for user";
    }
}
```

## Exemple of a request to authenticate users

First get a token through the API Gateway:

```bash
curl --location --request POST 'http://localhost:8080/api/v1/auth/login' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_id=<client-id>' \
--data-urlencode 'username=<username>' \
--data-urlencode 'password=<password>'
```

Then use the token to access the microservices:

```bash
curl --location --request GET 'http://localhost:8080/api/v1/path/test' \
--header 'Authorization: Bearer <access_token>'
```

You should get `test for authenticated users`.

If your user has the role `<admin_role_name>`, you can access the endpoint `/test/admin` and `/test`, but not `/test/user` (you will get a `403 Forbidden` error).

## Exemple of a request to sign up a user

First you need to create a user (eg: username : `user-manager`) that has two roles from `realm-management` client:
- `manage-users`
- `create-client`

Then you can use the following request to get an admin token:

```bash
curl --location --request POST 'http://localhost:8080/realms/seasonsforce/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_id=admin-cli' \
--data-urlencode 'username=user-manager' \
--data-urlencode 'password=<password>'
```

This request will give you an admin `access_token`, signed with a user that has the role `manage-users` and `create-client`.

Then you can use this token to create a new user:

```bash
curl --location --request POST 'http://localhost:8000/admin/realms/seasonsforce/users' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <access_token>' \
--data-raw '{
    "username": "new username",
    "firstName": "firstName",
    "lastName": "lastName",
    "email": "email@example.com",
    "attributes": {
        "phoneNumber": "00XXXXXXXX",
        "company": "company",
        "age": 55,
        <other attributes>
    },
    "enabled": true,
    "emailVerified": false,
    "credentials": [
        {
          "type": "password",
          "value": "<password>",
          "temporary": false
        }
    ],
    "groups": ["myGroup"],
    "realmRoles": ["myRole"],
    "clientRoles": {
        "myClient": ["myRole"]
    }
}' 
```

This request will create a new user with the following attributes:
- username : `new username`
- firstName : `firstName`
- lastName : `lastName`
- email : `email@example.com`
- phoneNumber : `00XXXXXXXX`
- company : `company`
- age : `55`
- password : `<password>`
- enabled : `true`
- emailVerified : `false`
- groups : `myGroup`
- realmRoles : `myRole`
- clientRoles : `myRole` for the client `myClient`

---

*© 2023 Romain Frezier & Lorenzo Italiano - Polytech Montpellier*
