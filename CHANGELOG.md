# Changelog

All notable changes to TeaPot API specifications will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-11-13

### Added - User Service v1.0.0

#### Endpoints
- `POST /users` - Create new user account
- `GET /users` - List users with pagination and search
- `GET /users/{userId}` - Get user by ID
- `PUT /users/{userId}` - Update user profile
- `DELETE /users/{userId}` - Soft delete user
- `POST /users/{userId}/verify` - Verify user account with code
- `GET /health` - Health check endpoint

#### Features
- Multi-tenant architecture with `tenantId` field
- Supplier business profile management
- Email and phone validation (RFC 5322, international format)
- Farm size tracking in hectares
- Location support (lat/long + address)
- Preferred language (English, Sinhala, Tamil)
- Soft delete (isActive flag)
- Account verification (isVerified flag)
- Pagination support for list endpoint
- Search by business name or owner name

#### Schemas
- `CreateUserRequest` - User registration payload
- `UpdateUserRequest` - Profile update payload
- `UserResponse` - User entity response
- `PaginationResponse` - Pagination metadata
- `ErrorResponse` - Standardized error format

#### Validation
- Email: Must be valid email format
- Phone: International format `+[country][number]`
- Business name: 2-200 characters
- Owner name: 2-100 characters
- Farm size: 0.1-10,000 hectares
- Verification code: 6 digits

#### Error Codes
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid JWT)
- `404` - Not Found
- `409` - Conflict (duplicate email/phone)
- `500` - Internal Server Error

#### Security
- JWT Bearer token authentication
- All endpoints require authentication (except health check)

---

## Version History

- **1.0.0** - Initial release with User Service API
