# How to set up Minio in a microservices architecture (using Spring Boot as API framework)

Minio is a S3 compatible object storage server. It is a good open source alternative to AWS S3.

## 1. How to set up Minio in a microservices architecture

In order to use minio in a microservices architecture, you must first set up a minio docker image. You can do this with the following Dockerfile example: 
```Dockerfile
# Using the latest version of minio
FROM quay.io/minio/minio:latest

# Starting minio server with console on port 9001
CMD ["minio", "server", "/data", "--console-address", ":9001"]
```

You can then build the docker image with the following command:
```bash
docker build -t minio-server .
```

## 2. How to run Minio in a microservices architecture

In order to run minio in a microservices architecture, you can use the following docker-compose.yml example:

```yaml
version: '3.7'

services:

  company-minio: # Minio database for companies
    image: company-minio:latest
    container_name: company-minio
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - company-minio-data:/data
    environment:
      MINIO_ROOT_USER: ${COMPANY_MINIO_ROOT_USER}
      MINIO_ROOT_PASSWORD: ${COMPANY_MINIO_ROOT_PASSWORD}
    networks:
      - company-network
      - api-network
  
  company-db: # Postgresql database for companies
    image: company-db:latest
    container_name: company-db
    volumes:
      - company-db_data:/var/lib/postgresql/data
    networks:
      - company-network
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${COMPANY_POSTGRES_DB}

  company-api:
    image: company-api:latest  # Spring Boot API for companies
    container_name: company-api
    networks:
      - company-network
      - api-network

  api-gateway:
    image: api-gateway:latest  # Spring API Gateway
    container_name: api-gateway
    ports:
      - "8090:8080"  # Output to port 8090
    networks:
      - api-network

networks:
  company-network:
  api-network:

volumes:
  company-db_data:
  company-minio-data:
```

As you can see below, it is recommended to use `.env file for the environment variables. You can use the following .env example:
```dotenv
POSTGRES_USER=seasonsforce
POSTGRES_PASSWORD=seasonsforce

COMPANY_POSTGRES_DB=company

COMPANY_MINIO_ROOT_USER=company
COMPANY_MINIO_ROOT_PASSWORD=companycompany
```

You can also check the healthcheck of the minio server with the following parameter in the docker-compose.yml file:
```yaml
healthcheck:
  test: [ "CMD", "curl", "-f", "http://localhost:9000/minio/health/live" ]
  interval: 30s
  timeout: 10s, 
  retries: 15
```

## 3. How to use Minio in an API

### 3.1. Minio dependency in Java

In order to use minio in an API, you must first add the following dependency to your pom.xml file:
```xml
<dependency>
    <groupId>io.minio</groupId>
    <artifactId>minio</artifactId>
    <version>8.5.6</version>
</dependency>
```

### 3.2. How to implement Minio in Spring Boot

To implement Minio in a Spring Boot application it is best practice to create a dedicated service for Minio.
In this part we will see how to do this.

First you will need to create a new Java class in your project. This class will be the service for Minio. You can name it MinioService for example.

Then you will need to add the following annotations to the class:
```java
package com.example.service;

import org.springframework.stereotype.Service;

@Service
public class MinioService {
    // TODO add code here
}
```

#### 3.2.1. How to create a bucket

#### 3.2.2. How to upload a file to a bucket

#### 3.2.3. How to download a file from a public bucket

#### 3.2.4. How to download a file from a private bucket

#### 3.2.5. How to delete a file from a bucket

#### 3.2.6. How to delete a bucket

#### 3.2.7. Final code example


Here is an example of how to use minio in an API with a service:

// TODO clean up java example

```java
package com.example.service;

import io.minio.*;
import io.minio.errors.MinioException;
import io.minio.http.Method;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;


@Service
public class MinioService {
    
    /**
     * Upload a file to Minio.
     *
     * @param bucketName: The name of the bucket.
     * @param objectName: The name of the object.
     * @param multipartFile: The file to upload.
     * @throws IOException: If an I/O error occurs.
     * @throws NoSuchAlgorithmException: If the algorithm SHA-256 is not available.
     * @throws InvalidKeyException: If the key is invalid.
     */
    public void uploadFile(String bucketName, String objectName, MultipartFile multipartFile)
            throws IOException, NoSuchAlgorithmException, InvalidKeyException, MinioException {
        try {

            // Create a minioClient with the MinIO server, its access key and secret key.
            MinioClient minioClient = MinioClient.builder()
                    .endpoint("http://company-minio:9000")
                    .credentials("company", "companycompany")
                    .region("europe")
                    .build();

            // Verify if the bucket already exists.
            boolean found = minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucketName).build());

            if (!found) {
                // Create a new bucket.
                minioClient.makeBucket(
                        MakeBucketArgs
                                .builder()
                                .bucket(bucketName)
                                .region("europe")
                                .build()
                );

                // Define the bucket policy.
                String config = "{\n" +
                        "    \"Statement\": [\n" +
                        "        {\n" +
                        "            \"Action\": [\n" +
                        "                \"s3:GetBucketLocation\",\n" +
                        "                \"s3:ListBucket\"\n" +
                        "            ],\n" +
                        "            \"Effect\": \"Allow\",\n" +
                        "            \"Principal\": \"*\",\n" +
                        "            \"Resource\": \"arn:aws:s3:::" + bucketName + "\"\n" +
                        "        },\n" +
                        "        {\n" +
                        "            \"Action\": \"s3:GetObject\",\n" +
                        "            \"Effect\": \"Allow\",\n" +
                        "            \"Principal\": \"*\",\n" +
                        "            \"Resource\": \"arn:aws:s3:::" + bucketName + "/*\"\n" +
                        "        }\n" +
                        "    ],\n" +
                        "    \"Version\": \"2012-10-17\"\n" +
                        "}";

                // Setting the bucket policy.
                minioClient.setBucketPolicy(
                        SetBucketPolicyArgs
                                .builder()
                                .bucket(bucketName)
                                .config(config)
                                .region("europe")
                                .build()
                );
            }

            // Get the input stream.
            InputStream fileInputStream = multipartFile.getInputStream();

            // Upload the file to the bucket with putObject.
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .contentType(multipartFile.getContentType()) // Définissez le type de contenu si nécessaire.
                            .stream(fileInputStream, fileInputStream.available(), -1)
                            .build());

        } catch (InvalidKeyException e) {
            throw new InvalidKeyException("The key is invalid.");
        } catch (NoSuchAlgorithmException e) {
            throw new NoSuchAlgorithmException("The SHA-256 algorithm is not available.");
        } catch (IOException e) {
            throw new IOException("An I/O error occurs.");
        } catch (MinioException e) {
            throw new MinioException("An error occurred: " + e.getMessage());
        }
    }
}
```
