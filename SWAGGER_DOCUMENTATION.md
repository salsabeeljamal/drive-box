# Swagger UI Documentation

## Overview

Your DriveBox API now includes comprehensive Swagger UI documentation for all endpoints. The API provides access to Google Drive, GitHub, and Dropbox services with proper authentication and detailed schema definitions.

## Accessing Swagger UI

### Local Development
- **Swagger UI Interface**: http://localhost:4000/swaggerui
- **OpenAPI Specification (JSON)**: http://localhost:4000/api/openapi

### Features

1. **Interactive API Testing**: Test all endpoints directly from the browser
2. **Authentication Support**: Built-in JWT Bearer token authentication
3. **Comprehensive Schemas**: Detailed request/response schemas for all endpoints
4. **Provider-Specific Endpoints**: Organized by service (Google Drive, GitHub, Dropbox)

## API Endpoints Overview

### Google Drive API
- `GET /api/google/files` - List files
- `GET /api/google/files/{file_id}` - Get file details
- `GET /api/google/files/{file_id}/download` - Download file
- `POST /api/google/files/upload` - Upload file

### GitHub API
- `GET /api/github/repositories` - List repositories
- `GET /api/github/repositories/{owner}/{repo}` - Get repository details
- `GET /api/github/repositories/{owner}/{repo}/contents` - List repository contents
- `GET /api/github/repositories/{owner}/{repo}/contents/*path` - Get file content
- `POST /api/github/repositories/{owner}/{repo}/contents/*path` - Create file
- `GET /api/github/profile` - Get user profile

### Dropbox API
- `GET /api/dropbox/files` - List files
- `GET /api/dropbox/files/metadata` - Get file metadata
- `GET /api/dropbox/files/download` - Download file
- `POST /api/dropbox/files/upload` - Upload file
- `POST /api/dropbox/files/create_folder` - Create folder
- `DELETE /api/dropbox/files` - Delete file
- `GET /api/dropbox/account` - Get account info

## Authentication

All protected API endpoints require a JWT Bearer token:

```
Authorization: Bearer <your-jwt-token>
```

You can obtain a token through the authentication endpoints:
- `GET /api/auth/{provider}/authorize` - Start OAuth flow
- `GET /api/auth/{provider}/callback` - Complete OAuth flow

## Using Swagger UI

1. **Start the server**: `mix phx.server`
2. **Open browser**: Navigate to http://localhost:4000/swaggerui
3. **Authenticate**: Click "Authorize" and enter your JWT token
4. **Test endpoints**: Expand any endpoint and click "Try it out"
5. **View responses**: See real-time responses and examples

## Schema Definitions

The API includes comprehensive schema definitions for:
- **User**: User account information
- **FileInfo**: File metadata from cloud storage
- **Repository**: GitHub repository information
- **GitHubContent**: Repository content items
- **GitHubProfile**: User profile information
- **DropboxAccount**: Dropbox account details
- **Error**: Standard error responses

## Technical Details

- **OpenAPI Version**: 3.0.0
- **Specification Framework**: OpenApiSpex
- **UI Framework**: Swagger UI 5.17.14
- **Authentication**: JWT Bearer tokens
- **Response Format**: JSON

## Development Notes

- All endpoints include proper parameter validation
- Request/response examples are provided for each endpoint
- Error responses follow a consistent schema
- Authentication is required for all protected routes
- File uploads support multipart/form-data
- Download endpoints return binary data with appropriate content types 