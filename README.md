# DriveBox - Third-Party Cloud Storage Integration

A comprehensive API-first application built with Phoenix/Elixir that integrates with multiple cloud storage providers including Google Drive, GitHub, and Dropbox using OAuth2 authentication.

## Features

- **Multi-Provider Authentication**: Seamlessly connect with Google Drive, GitHub, and Dropbox using OAuth2
- **Unified API**: Single API interface for all supported cloud storage providers
- **File Operations**: Upload, download, list, and manage files across all platforms
- **Persistent Connections**: Once connected, maintain authentication across sessions
- **RESTful API**: Clean, well-documented API endpoints for all operations
- **Token Management**: Automatic token refresh and management

## Supported Providers

### Google Drive
- List files and folders
- Upload/download files
- File metadata retrieval
- Folder operations

### GitHub
- Repository management
- File operations (read, create, update)
- Repository contents listing
- User profile information

### Dropbox
- File and folder operations
- Upload/download files
- Metadata retrieval
- Account information

## Prerequisites

- Elixir 1.15+
- Phoenix 1.8+
- PostgreSQL 14+
- Node.js 18+ (for assets)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd drive-box
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   npm install --prefix assets
   ```

3. **Set up environment variables**
   Create a `.env` file in the project root:
   ```env
   # Google Drive OAuth
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret

   # GitHub OAuth
   GITHUB_CLIENT_ID=your_github_client_id
   GITHUB_CLIENT_SECRET=your_github_client_secret

   # Dropbox OAuth
   DROPBOX_CLIENT_ID=your_dropbox_client_id
   DROPBOX_CLIENT_SECRET=your_dropbox_client_secret

   # Database
   DATABASE_URL=postgres://username:password@localhost/drive_box_dev
   ```

4. **Set up OAuth Applications**

   ### Google Drive
   1. Go to [Google Cloud Console](https://console.cloud.google.com/)
   2. Create a new project or select existing
   3. Enable Google Drive API
   4. Create OAuth 2.0 credentials
   5. Add `http://localhost:4000/auth/google/callback` to redirect URIs

   ### GitHub
   1. Go to GitHub Settings > Developer settings > OAuth Apps
   2. Create a new OAuth App
   3. Set Authorization callback URL to `http://localhost:4000/auth/github/callback`

   ### Dropbox
   1. Go to [Dropbox App Console](https://www.dropbox.com/developers/apps)
   2. Create a new app
   3. Add `http://localhost:4000/auth/dropbox/callback` to redirect URIs

5. **Set up the database**
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

6. **Start the server**
   ```bash
   mix phx.server
   ```

## API Documentation

### Authentication Endpoints

#### Initiate OAuth Flow
```http
GET /auth/{provider}
```
**Providers**: `google`, `github`, `dropbox`

**Response**:
```json
{
  "authorize_url": "https://provider.com/oauth/authorize?..."
}
```

#### OAuth Callback
```http
GET /auth/{provider}/callback?code=...&state=...
```

**Response**:
```json
{
  "message": "Authentication successful",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name"
  },
  "provider": {
    "id": "provider_id",
    "provider": "google",
    "connected_at": "2024-01-01T00:00:00Z"
  },
  "token": "user_auth_token"
}
```

#### Get Connected Providers
```http
GET /auth/
Authorization: Bearer {token}
```

#### Disconnect Provider
```http
DELETE /auth/{provider}
Authorization: Bearer {token}
```

### Google Drive API

#### List Files
```http
GET /api/google/files
Authorization: Bearer {token}
```

#### Get File Details
```http
GET /api/google/files/{file_id}
Authorization: Bearer {token}
```

#### Download File
```http
GET /api/google/files/{file_id}/download
Authorization: Bearer {token}
```

#### Upload File
```http
POST /api/google/files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [binary file data]
parents: ["folder_id"] (optional)
```

### GitHub API

#### List Repositories
```http
GET /api/github/repositories
Authorization: Bearer {token}
```

#### Get Repository
```http
GET /api/github/repositories/{owner}/{repo}
Authorization: Bearer {token}
```

#### List Repository Contents
```http
GET /api/github/repositories/{owner}/{repo}/contents
Authorization: Bearer {token}
```

#### Get File Content
```http
GET /api/github/repositories/{owner}/{repo}/contents/{path}
Authorization: Bearer {token}
```

#### Create File
```http
POST /api/github/repositories/{owner}/{repo}/contents/{path}
Authorization: Bearer {token}
Content-Type: application/json

{
  "content": "file content",
  "message": "commit message",
  "branch": "main" (optional)
}
```

#### Get User Profile
```http
GET /api/github/profile
Authorization: Bearer {token}
```

### Dropbox API

#### List Files
```http
GET /api/dropbox/files?path=/folder/path
Authorization: Bearer {token}
```

#### Get File Metadata
```http
GET /api/dropbox/files/metadata?path=/file/path
Authorization: Bearer {token}
```

#### Download File
```http
GET /api/dropbox/files/download?path=/file/path
Authorization: Bearer {token}
```

#### Upload File
```http
POST /api/dropbox/files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

path: /destination/path
file: [binary file data]
mode: add|overwrite (optional)
autorename: true|false (optional)
```

#### Create Folder
```http
POST /api/dropbox/files/create_folder
Authorization: Bearer {token}
Content-Type: application/json

{
  "path": "/folder/path",
  "autorename": false
}
```

#### Delete File/Folder
```http
DELETE /api/dropbox/files?path=/file/path
Authorization: Bearer {token}
```

#### Get Account Info
```http
GET /api/dropbox/account
Authorization: Bearer {token}
```

## Usage Examples

### 1. Connect to Google Drive
```bash
# Get authorization URL
curl -X GET http://localhost:4000/auth/google

# User visits the URL and authorizes
# Callback happens automatically
# Use the returned token for subsequent API calls
```

### 2. Upload file to Google Drive
```bash
curl -X POST http://localhost:4000/api/google/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/local/file.txt"
```

### 3. List GitHub repositories
```bash
curl -X GET http://localhost:4000/api/github/repositories \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Upload file to Dropbox
```bash
curl -X POST http://localhost:4000/api/dropbox/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "path=/uploaded_file.txt" \
  -F "file=@/path/to/local/file.txt"
```

## Architecture

### Core Components

- **Authentication Layer**: Handles OAuth2 flows for all providers
- **Service Layer**: Implements provider-specific API clients
- **API Layer**: Provides unified REST endpoints
- **Database Layer**: Stores user data and authentication tokens

### Key Modules

- `DriveBox.Users.User`: User management
- `DriveBox.Users.UserIdentity`: Provider authentication storage
- `DriveBox.Services.GoogleDriveAPI`: Google Drive integration
- `DriveBox.Services.GitHubAPI`: GitHub integration
- `DriveBox.Services.DropboxAPI`: Dropbox integration
- `DriveBoxWeb.AuthController`: Authentication endpoints
- `DriveBoxWeb.APIController`: Unified API endpoints

## Development

### Running Tests
```bash
mix test
```

### Code Formatting
```bash
mix format
```

### Database Operations
```bash
# Create database
mix ecto.create

# Run migrations
mix ecto.migrate

# Reset database
mix ecto.reset
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the documentation
2. Search existing issues
3. Create a new issue with detailed information

## Roadmap

- [ ] Add support for OneDrive
- [ ] Implement file syncing between providers
- [ ] Add webhook support for real-time updates
- [ ] Implement file versioning
- [ ] Add admin dashboard
- [ ] Performance optimization and caching
