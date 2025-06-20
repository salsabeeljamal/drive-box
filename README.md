# DriveBox - Third-Party Cloud Storage Integration

A comprehensive full-stack application that integrates with multiple cloud storage providers including Google Drive, GitHub, and Dropbox using OAuth2 authentication. The system consists of a Phoenix/Elixir API backend and a modern Next.js frontend.

## 🏗️ Architecture

**Backend (Phoenix/Elixir)**: Provides API-first architecture with unified endpoints for all cloud storage providers  
**Frontend (Next.js/React)**: Modern web interface for seamless file management across all connected services

## ✨ Features

- **Multi-Provider Authentication**: Seamlessly connect with Google Drive, GitHub, and Dropbox using OAuth2
- **Unified API**: Single API interface for all supported cloud storage providers
- **Modern Web Interface**: Responsive React frontend with intuitive file management
- **File Operations**: Upload, download, list, and manage files across all platforms
- **Persistent Connections**: Once connected, maintain authentication across sessions
- **RESTful API**: Clean, well-documented API endpoints for all operations
- **Token Management**: Automatic token refresh and management

## 🚀 Quick Start

### Prerequisites

**Backend Requirements:**
- Elixir 1.15+
- Phoenix 1.8+
- PostgreSQL 14+

**Frontend Requirements:**
- Node.js 18+
- npm or yarn

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd drive-box
   ```

2. **Backend Setup**
   ```bash
   # Install Elixir dependencies
   mix deps.get
   
   # Install Node.js dependencies for Phoenix assets
   npm install --prefix assets
   
   # Set up the database
   mix ecto.create
   mix ecto.migrate
   ```

3. **Frontend Setup**
   ```bash
   # Navigate to frontend directory
   cd drive_box_frontend
   
   # Install frontend dependencies
   npm install
   ```

4. **Environment Configuration**

   **Backend (.env in project root):**
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

   **Frontend (.env.local in drive_box_frontend/):**
   ```env
   NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
   ```

5. **OAuth Application Setup**

   See [OAUTH_SETUP.md](OAUTH_SETUP.md) for detailed OAuth configuration instructions for each provider.

## 🏃 Running the Application

### Development Mode

**Start Backend (Terminal 1):**
```bash
# From project root
mix phx.server
# Backend runs on http://localhost:4000
```

**Start Frontend (Terminal 2):**
```bash
# From project root
cd drive_box_frontend
npm run dev
# Frontend runs on http://localhost:3000
```

### Production Mode

**Backend:**
```bash
MIX_ENV=prod mix phx.server
```

**Frontend:**
```bash
cd drive_box_frontend
npm run build
npm start
```

## 📱 Frontend Usage

### Access the Application
1. Open your browser to [http://localhost:3000](http://localhost:3000)
2. Click "Connect" for any supported provider (Google Drive, GitHub, Dropbox)
3. Complete OAuth authentication
4. Access your files through the dashboard

### Frontend Features
- **Dashboard Interface**: Unified view of all connected services
- **Provider Tabs**: Switch between Google Drive, GitHub, and Dropbox
- **File Browser**: Browse files and folders with intuitive navigation
- **Download Files**: Direct download from Google Drive and Dropbox
- **Repository Access**: View and access GitHub repositories
- **Account Management**: Connect/disconnect providers as needed

### Frontend Tech Stack
- **Next.js 14** with App Router
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **React Query** for data fetching
- **Axios** for API communication

## 🔧 Backend API Usage

### API Base URL
```
http://localhost:4000
```

### Authentication Flow

#### 1. Initiate OAuth
```http
GET /auth/{provider}
```
**Providers**: `google`, `github`, `dropbox`

#### 2. OAuth Callback (handled automatically)
```http
GET /auth/{provider}/callback?code=...&state=...
```

#### 3. Get Connected Providers
```http
GET /auth/
Authorization: Bearer {token}
```

### API Examples

#### Upload to Google Drive
```bash
curl -X POST http://localhost:4000/api/google/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/file.txt"
```

#### List GitHub Repositories
```bash
curl -X GET http://localhost:4000/api/github/repositories \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Download from Dropbox
```bash
curl -X GET "http://localhost:4000/api/dropbox/files/download?path=/file.txt" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🌐 Supported Providers

### Google Drive
- ✅ List files and folders
- ✅ Upload/download files
- ✅ File metadata retrieval
- ✅ Folder operations

### GitHub
- ✅ Repository management
- ✅ File operations (read, create, update)
- ✅ Repository contents listing
- ✅ User profile information

### Dropbox
- ✅ File and folder operations
- ✅ Upload/download files
- ✅ Metadata retrieval
- ✅ Account information

## 📚 Detailed API Documentation

For comprehensive API documentation including all endpoints and examples, see [SWAGGER_DOCUMENTATION.md](SWAGGER_DOCUMENTATION.md)

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

## 🗂️ Project Structure

```
drive_box/
├── 🔧 Backend (Phoenix/Elixir)
│   ├── lib/
│   │   ├── drive_box/           # Core business logic
│   │   │   ├── services/        # External API integrations
│   │   │   └── users/           # User management
│   │   └── drive_box_web/       # Web layer
│   │       ├── controllers/     # API endpoints
│   │       ├── auth/            # Authentication logic
│   │       └── plugs/           # Middleware
│   ├── config/                  # Configuration files
│   ├── priv/                    # Database migrations
│   └── test/                    # Test files
│
└── 🎨 Frontend (Next.js)
    ├── src/
    │   ├── app/                 # Next.js App Router
    │   │   ├── auth/            # OAuth callback handling
    │   │   ├── dashboard/       # Main dashboard
    │   │   └── page.tsx         # Homepage
    │   ├── contexts/            # React contexts
    │   └── lib/                 # Utilities and API client
    ├── public/                  # Static assets
    └── tailwind.config.js       # Styling configuration
```

## 🧪 Development & Testing

### Backend Development
```bash
# Run tests
mix test

# Code formatting
mix format

# Database operations
mix ecto.create
mix ecto.migrate
mix ecto.reset

# Interactive shell
iex -S mix
```

### Frontend Development
```bash
cd drive_box_frontend

# Development server
npm run dev

# Build for production
npm run build

# Run linting
npm run lint

# Type checking
npm run type-check
```

## 🔐 Security Features

- **OAuth2 Flow**: Secure authentication with major providers
- **JWT Tokens**: Stateless authentication for API access
- **Token Refresh**: Automatic token renewal
- **CORS Protection**: Configurable cross-origin request handling
- **Input Validation**: Comprehensive request validation
- **Rate Limiting**: Built-in protection against abuse

## 📖 Documentation

- **API Documentation**: [SWAGGER_DOCUMENTATION.md](SWAGGER_DOCUMENTATION.md)
- **OAuth Setup**: [OAUTH_SETUP.md](OAUTH_SETUP.md)
- **Frontend Setup**: [drive_box_frontend/README.md](drive_box_frontend/README.md)
- **Deployment**: [drive_box_frontend/DEPLOYMENT.md](drive_box_frontend/DEPLOYMENT.md)

## 🚀 Deployment

### Backend Deployment
```bash
# Production build
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.server
```

### Frontend Deployment
```bash
cd drive_box_frontend
npm run build
npm start
```

### Environment Variables for Production
- Set all OAuth credentials
- Configure database URL
- Set frontend API base URL
- Configure CORS settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`mix test` for backend, `npm test` for frontend)
6. Format code (`mix format` for backend, `npm run lint` for frontend)
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support & Troubleshooting

### Common Issues
- **OAuth Callback Errors**: Check redirect URLs in provider settings
- **Database Connection**: Verify PostgreSQL is running and credentials are correct
- **Frontend API Errors**: Ensure backend is running on correct port
- **CORS Issues**: Check CORS configuration in Phoenix

### Getting Help
1. Check the documentation files
2. Search existing issues on GitHub
3. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details

## 🗺️ Roadmap

### Short Term
- [ ] Add file upload progress indicators
- [ ] Implement file search functionality
- [ ] Add bulk file operations
- [ ] Improve error handling and user feedback

### Medium Term
- [ ] Add support for OneDrive
- [ ] Implement file syncing between providers
- [ ] Add webhook support for real-time updates
- [ ] Mobile app development

### Long Term
- [ ] File versioning system
- [ ] Admin dashboard and analytics
- [ ] Performance optimization and caching
- [ ] Enterprise features and multi-tenancy

---

**Made with ❤️ using Phoenix + Next.js**
