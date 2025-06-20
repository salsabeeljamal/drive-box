# DriveBox Frontend Setup

## Quick Setup

1. **Navigate to the frontend directory**
   ```bash
   cd drive_box_frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create environment file**
   ```bash
   cp .env.example .env.local
   ```
   
   Or create `.env.local` manually with:
   ```env
   NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
   ```

4. **Start the development server**
   ```bash
   npm run dev
   ```

5. **Open in browser**
   Visit [http://localhost:3000](http://localhost:3000)

## Backend Requirements

Make sure your DriveBox API server is running:

1. **Start the Phoenix server** (from the main project directory):
   ```bash
   mix phx.server
   ```

2. **Verify API is accessible**:
   - API should be running on `http://localhost:4000`
   - Test endpoint: `http://localhost:4000/api/openapi`

## Authentication Setup

The frontend will redirect users to OAuth providers through your API. Make sure you have configured:

1. **Google OAuth** credentials in your API
2. **GitHub OAuth** app settings
3. **Dropbox OAuth** app configuration

## Troubleshooting

### Common Issues

1. **CORS Errors**
   - Ensure your API allows requests from `http://localhost:3000`
   - Check Phoenix CORS configuration

2. **Environment Variables**
   - Make sure `.env.local` is created and contains the correct API URL
   - Restart the dev server after changing environment variables

3. **OAuth Redirect Issues**
   - Verify OAuth callback URLs in provider settings
   - Check that callback URLs point to your API, not the frontend

### Development Tips

- Use browser dev tools to monitor network requests
- Check the browser console for JavaScript errors
- Verify API responses in the Network tab 