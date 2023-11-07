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

Here is an example of how to use minio in an API with a service:

// TODO clean up java example

```java
package fr.polytech.service;

import io.minio.*;
import io.minio.errors.*;
import io.minio.http.Method;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.concurrent.TimeUnit;


/**
 * Service to interact with Minio.
 */
@Service
public class MinioService {

    private final Logger logger = LoggerFactory.getLogger(MinioService.class);

    // Initialize minioClient with MinIO server.
    private final MinioClient minioClient = MinioClient.builder()
            .endpoint("http://invoice-minio:9000")
            .credentials("invoice", "invoiceinvoice")
            .region("europe")
            .build();

    /**
     * Create a public bucket in Minio.
     *
     * @param bucketName: The name of the bucket.
     * @throws MinioException if an error occurs.
     * @throws IOException if an I/O error occurs.
     * @throws NoSuchAlgorithmException if an algorithm is not available.
     * @throws InvalidKeyException if the key is invalid.
     */
    private void createPublicBucket(String bucketName) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {

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

        createBucket(bucketName, config);
    }

    /**
     * Create a private bucket in Minio.
     *
     * @param bucketName: The name of the bucket.
     * @throws MinioException if an error occurs.
     * @throws IOException if an I/O error occurs.
     * @throws NoSuchAlgorithmException if an algorithm is not available.
     * @throws InvalidKeyException if the key is invalid.
     */
    private void createPrivateBucket(String bucketName) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {

        String config = "{\n" +
                "    \"Statement\": [\n" +
                "        {\n" +
                "            \"Action\": [\n" +
                "                \"s3:GetBucketLocation\",\n" +
                "                \"s3:ListBucket\"\n" +
                "            ],\n" +
                "            \"Effect\": \"Allow\",\n" +
                "            \"Principal\": {\n" +
                "                \"AWS\": \"arn:aws:iam::company:root\"\n" +
                "            },\n" +
                "            \"Resource\": \"arn:aws:s3:::" + bucketName + "\"\n" +
                "        },\n" +
                "        {\n" +
                "            \"Action\": \"s3:GetObject\",\n" +
                "            \"Effect\": \"Allow\",\n" +
                "            \"Principal\": {\n" +
                "                \"AWS\": \"arn:aws:iam::company:root\"\n" +
                "            },\n" +
                "            \"Resource\": \"arn:aws:s3:::" + bucketName + "/*\"\n" +
                "        }\n" +
                "    ],\n" +
                "    \"Version\": \"2012-10-17\"\n" +
                "}";

        createBucket(bucketName, config);
    }


    /**
     * Create a bucket in Minio.
     *
     * @param bucketName: The name of the bucket.
     * @param config: The configuration of the bucket.
     * @throws MinioException if an error occurs.
     * @throws IOException if an I/O error occurs.
     * @throws NoSuchAlgorithmException if an algorithm is not available.
     * @throws InvalidKeyException if the key is invalid.
     */
    private void createBucket(String bucketName, String config) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {

        // Create a new bucket.
        minioClient.makeBucket(
                MakeBucketArgs
                        .builder()
                        .bucket(bucketName)
                        .region("europe")
                        .build()
        );

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


    /**
     * Check if a bucket exists.
     *
     * @param bucketName: The name of the bucket.
     * @return True if the bucket exists, false otherwise.
     * @throws MinioException if an error occurs.
     * @throws IOException if an I/O error occurs.
     * @throws NoSuchAlgorithmException if an algorithm is not available.
     * @throws InvalidKeyException if the key is invalid.
     */
    private boolean bucketExists(String bucketName) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {
        return minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucketName).build());
    }

    /**
     * Create a bucket if it does not exist.
     *
     * @param bucketName: The name of the bucket.
     * @param isPublic: True if the bucket should be public, false otherwise.
     * @throws MinioException if an error occurs.
     * @throws IOException if an I/O error occurs.
     * @throws NoSuchAlgorithmException if an algorithm is not available.
     * @throws InvalidKeyException if the key is invalid.
     */
    private void createBucketIfNotExists(String bucketName, boolean isPublic) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {
        if (!bucketExists(bucketName)) {
            if (isPublic) {
                createPublicBucket(bucketName);
            } else {
                createPrivateBucket(bucketName);
            }
        }
    }

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
    public void uploadFile(String bucketName, String objectName, MultipartFile multipartFile, boolean isPublicFile) throws IOException, NoSuchAlgorithmException, InvalidKeyException, MinioException {
        logger.info("Starting the upload of a file to Minio");

        createBucketIfNotExists(bucketName, isPublicFile);

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

        // Close the file stream.
        fileInputStream.close();

        logger.info("Completed the upload of a file to Minio");
    }

    /**
     * Upload a file to Minio.
     *
     * @param bucketName: The name of the bucket.
     * @param objectName: The name of the object.
     * @param file: The file to upload.
     * @throws IOException: If an I/O error occurs.
     * @throws NoSuchAlgorithmException: If the algorithm SHA-256 is not available.
     * @throws InvalidKeyException: If the key is invalid.
     */
    public void uploadFile(String bucketName, String objectName, File file, boolean isPublicFile) throws IOException, NoSuchAlgorithmException, InvalidKeyException, MinioException {
        logger.info("Starting the upload of a file to Minio");

        createBucketIfNotExists(bucketName, isPublicFile);

        // Get the input stream from the File object.
        FileInputStream fileInputStream = new FileInputStream(file);

        // Upload the file to the bucket with putObject.
        minioClient.putObject(
                PutObjectArgs.builder()
                        .bucket(bucketName)
                        .object(objectName)
                        .contentType("application/pdf")
                        .stream(fileInputStream, fileInputStream.available(), -1)
                        .build());

        // Close the file stream.
        fileInputStream.close();

        logger.info("Completed the upload of a file to Minio");
    }

    /**
     * Get the private URL of an object in Minio.
     *
     * @param bucket: The name of the bucket.
     * @param object: The name of the object.
     * @return The private URL of the object.
     */
    public String getPrivateDocumentUrl(String bucket, String object) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {

        logger.info("Getting the private URL of an object in Minio with bucketName: " + bucket + " and object: " + object);
        // Générez l'URL de l'objet dans Minio.
        String url = null;
//        Map<String, String> reqParams = new HashMap<String, String>();
//        reqParams.put("response-content-type", "application/json");

        url = minioClient.getPresignedObjectUrl(
                GetPresignedObjectUrlArgs.builder()
                        .method(Method.GET)
                        .region("europe")
                        .bucket(bucket)
                        .object(object)
//                            .extraHeaders()
                        .expiry(2, TimeUnit.HOURS)
                        .build());

        logger.info("Completed getting the private URL of an object in Minio");

        return url;
    }

    /**
     * Delete a file from a bucket.
     *
     * @param bucketName: The name of the bucket.
     * @param objectName: The name of the object.
     * @throws MinioException if an error occurs.
     * @throws IOException if an I/O error occurs.
     * @throws NoSuchAlgorithmException if an algorithm is not available.
     * @throws InvalidKeyException if the key is invalid.
     */
    public void deleteFileFromPrivateBucket(String bucketName, String objectName) throws MinioException, IOException, NoSuchAlgorithmException, InvalidKeyException {
        minioClient.removeObject(
                RemoveObjectArgs
                        .builder()
                        .bucket(bucketName)
                        .object(objectName)
                        .build());
    }
}

```
