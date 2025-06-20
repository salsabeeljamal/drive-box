# OAuth Provider Setup Guide

This guide will help you set up OAuth authentication for Google Drive, GitHub, and Dropbox with your DriveBox application.

## 🔧 Environment Variables

Create a `.env` file in your project root with the following variables:

```bash
# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# GitHub OAuth
GITHUB_CLIENT_ID=your_github_client_id_here
GITHUB_CLIENT_SECRET=your_github_client_secret_here

# Dropbox OAuth
DROPBOX_CLIENT_ID=your_dropbox_app_key_here
DROPBOX_CLIENT_SECRET=your_dropbox_app_secret_here
```

## 🟢 Google OAuth Setup

1. **Go to [Google Cloud Console](https://console.cloud.google.com/)**

2. **Create a new project or select existing one**

3. **Enable APIs:**
   - Go to "APIs & Services" > "Library"
   - Enable "Google Drive API"
   - Enable "Google+ API" (for profile access)

4. **Create OAuth Credentials:**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Application type: "Web application"
   - Name: "DriveBox"
   - Authorized redirect URIs: `http://localhost:4000/auth/google/callback`

5. **Copy your Client ID and Client Secret to `.env`**

## 🟣 GitHub OAuth Setup

1. **Go to [GitHub Settings](https://github.com/settings/applications/new)**

2. **Register a new OAuth App:**
   - Application name: "DriveBox"
   - Homepage URL: `http://localhost:4000`
   - Authorization callback URL: `http://localhost:4000/auth/github/callback`

3. **Copy your Client ID and Client Secret to `.env`**

## 🔵 Dropbox OAuth Setup

1. **Go to [Dropbox App Console](https://www.dropbox.com/developers/apps)**

2. **Create a new app:**
   - Choose API: "Scoped access"
   - Type of access: "Full Dropbox"
   - Name your app: "DriveBox"

3. **Configure your app:**
   - Go to your app's settings
   - Add redirect URI: `http://localhost:4000/auth/dropbox/callback`
   - Set permissions: `account_info.read`, `files.metadata.read`, `files.content.read`, `files.content.write`

4. **Copy your App key and App secret to `.env`**

## 🚀 Running the Application

1. **Load environment variables:**
   ```bash
   source .env
   # or use direnv, or add to your shell profile
   ```

2. **Start the server:**
   ```bash
   mix phx.server
   ```

3. **Access the application:**
   - Login page: `http://localhost:4000/login`
   - Dashboard: `http://localhost:4000/dashboard`
   - API docs: `http://localhost:4000/swaggerui`

## 🔐 Testing Authentication

1. **Visit** `http://localhost:4000/login`

2. **Click on any OAuth provider button:**
   - "Continue with Google"
   - "Continue with GitHub" 
   - "Continue with Dropbox"

3. **Complete the OAuth flow**

4. **You'll be redirected to the dashboard showing connected accounts**

## 🛠️ Production Setup

For production, update the redirect URIs in each OAuth provider to your production domain:

- Google: `https://yourdomain.com/auth/google/callback`
- GitHub: `https://yourdomain.com/auth/github/callback`
- Dropbox: `https://yourdomain.com/auth/dropbox/callback`

## 📝 API Testing

Once authenticated, you can test the API endpoints:

```bash
# Get an auth token (you'll need to implement token generation)
TOKEN="your_auth_token"

# Test Google Drive files
curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/api/google/files

# Test GitHub repositories  
curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/api/github/repositories

# Test Dropbox account
curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/api/dropbox/account
```

## 🐛 Troubleshooting

1. **Invalid redirect URI**: Make sure the redirect URIs match exactly in your OAuth provider settings

2. **Missing scopes**: Ensure you've granted the necessary permissions in each provider

3. **Environment variables not loaded**: Make sure to source your `.env` file before starting the server

4. **Database errors**: Ensure your database is running and migrations are up to date:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

## 🔗 Useful Links

- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [GitHub OAuth Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Dropbox OAuth Documentation](https://developers.dropbox.com/oauth-guide) 