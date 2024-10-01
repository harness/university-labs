# Swagger Petstore - OpenAPI 3.0

Welcome to the Swagger Petstore API documentation! This API is based on the OpenAPI 3.0 specification and provides access to various functionalities of a pet store. Below, you'll find information on how to interact with the API, including available endpoints, request parameters, and response formats.

## Table of Contents

- [Introduction](#introduction)
- [API Overview](#api-overview)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
  - [Pets](#pets)
  - [Store](#store)
  - [Users](#users)
- [Schemas](#schemas)
- [Contact](#contact)
- [License](#license)

## Introduction

This is a sample Pet Store Server based on the OpenAPI 3.0 specification. In this third iteration of the pet store, we have adopted a design-first approach. You can contribute to improving this API by making changes to the API definition or the underlying code.

For more information about Swagger, visit [http://swagger.io](http://swagger.io).

## API Overview

- **Version**: 1.0.20-SNAPSHOT
- **Base URL**: `/v3`

### Useful Links

- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
- [Source API definition](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)

## Authentication

The API uses two types of authentication:

- **OAuth2**: You can authenticate using OAuth2 by obtaining a token via the authorization URL provided in the API.
- **API Key**: You can also authenticate using an API key, which must be included in the header of your requests.

### OAuth2 Scopes

- `write:pets`: Modify pets in your account
- `read:pets`: Read your pets

## Endpoints

### Pets

- **Add a New Pet**
  - `POST /pet`
  - Adds a new pet to the store.
  - **Security**: OAuth2 (write:pets)
  
- **Update an Existing Pet**
  - `PUT /pet`
  - Updates an existing pet by ID.
  - **Security**: OAuth2 (write:pets)

- **Find Pets by Status**
  - `GET /pet/findByStatus`
  - Finds pets based on their status (e.g., available, pending, sold).
  - **Security**: OAuth2 (read:pets)

- **Find Pets by Tags**
  - `GET /pet/findByTags`
  - Finds pets based on their tags.
  - **Security**: OAuth2 (read:pets)

- **Get Pet by ID**
  - `GET /pet/{petId}`
  - Retrieves a pet by its ID.
  - **Security**: API Key, OAuth2 (read:pets)

- **Update Pet with Form Data**
  - `POST /pet/{petId}`
  - Updates a pet using form data.
  - **Security**: OAuth2 (write:pets)

- **Delete a Pet**
  - `DELETE /pet/{petId}`
  - Deletes a pet by its ID.
  - **Security**: OAuth2 (write:pets)

- **Upload an Image**
  - `POST /pet/{petId}/uploadImage`
  - Uploads an image of the pet.
  - **Security**: OAuth2 (write:pets)

### Store

- **Get Inventory**
  - `GET /store/inventory`
  - Returns pet inventories by status.
  - **Security**: API Key

- **Place an Order**
  - `POST /store/order`
  - Places a new order in the store.
  
- **Get Order by ID**
  - `GET /store/order/{orderId}`
  - Finds a purchase order by ID.

- **Delete an Order**
  - `DELETE /store/order/{orderId}`
  - Deletes a purchase order by ID.

### Users

- **Create User**
  - `POST /user`
  - Creates a new user. Only logged-in users can perform this action.

- **Create Users with List Input**
  - `POST /user/createWithList`
  - Creates a list of users from an input array.

- **Login**
  - `GET /user/login`
  - Logs a user into the system.

- **Logout**
  - `GET /user/logout`
  - Logs out the current user session.

- **Get User by Username**
  - `GET /user/{username}`
  - Retrieves a user by username.

- **Update User**
  - `PUT /user/{username}`
  - Updates an existing user. Only logged-in users can perform this action.

- **Delete User**
  - `DELETE /user/{username}`
  - Deletes a user. Only logged-in users can perform this action.

## Schemas

The API uses several schemas to represent different entities, including `Pet`, `Order`, `User`, `Category`, `Tag`, `Address`, and `ApiResponse`. Each schema defines the structure and data types expected for API requests and responses.

## Contact

For any questions or issues, you can reach out to the API team at:

- **Email**: [apiteam@swagger.io](mailto:apiteam@swagger.io)

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](http://www.apache.org/licenses/LICENSE-2.0.html) file for more information.
