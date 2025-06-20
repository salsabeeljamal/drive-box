# DriveBox Frontend Troubleshooting Guide

## Issue: OAuth Authentication Error at `getAuthUrl`

### Problem Description
Getting errors on line 115 in `src/lib/api.ts` when calling the OAuth authorization endpoint.

### Root Cause
The issue was identified as a **CORS (Cross-Origin Resource Sharing)** problem. The Phoenix backend wasn't configured to allow requests from the Next.js frontend running on `localhost:3000`.

### ✅ **SOLUTION IMPLEMENTED**

I've already fixed this by:

1. **Added CORS dependency** to `mix.exs`:
   ```elixir
   {:cors_plug, "~> 3.0"}
   ```

2. **Configured CORS in Phoenix endpoint** (`lib/drive_box_web/endpoint.ex`):
   ```elixir
   plug CORSPlug,
     origin: [
       "http://localhost:3000",  # Next.js development server
       "http://127.0.0.1:3000",  # Alternative localhost
     ],
     credentials: true,
     methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
     headers: ["Accept", "Content-Type", "Authorization", "X-Requested-With"]
   ```

3. **Enhanced API client** with better error handling and session support:
   - Added `withCredentials: true` for cookie handling
   - Improved error logging
   - Fixed authorization header handling for OAuth flows

### **Next Steps to Complete Setup**

1. **Restart your Phoenix server** (in the main project directory):
   ```bash
   cd .. # Go back to main project directory
   mix phx.server
   ```

2. **Start the Next.js frontend** (in the frontend directory):
   ```bash
   cd drive_box_frontend
   npm run dev
   ```

3. **Test the integration**:
   - Visit `http://localhost:3000`
   - Try connecting to one of the OAuth providers
   - Check browser console for any remaining errors

### **Verification Steps**

To verify everything is working:

1. **Check Phoenix server logs** - Should show CORS headers being added
2. **Check browser Network tab** - Should see successful OPTIONS preflight requests
3. **Check browser Console** - Should see detailed error logs if issues persist

### **Common Additional Issues**

#### Issue: OAuth Callback Errors
**Solution**: Make sure your OAuth app settings have the correct callback URLs:
- Google: `http://localhost:4000/api/auth/google/callback`
- GitHub: `http://localhost:4000/api/auth/github/callback`
- Dropbox: `http://localhost:4000/api/auth/dropbox/callback`

#### Issue: OAuth Credentials Not Configured
**Solution**: Check your `config/config.exs` and make sure OAuth credentials are set:
```elixir
config :drive_box, :oauth_providers, %{
  google: [
    # Your Google OAuth config
  ],
  github: [
    # Your GitHub OAuth config
  ],
  dropbox: [
    # Your Dropbox OAuth config
  ]
}
```

#### Issue: Session/Cookie Problems
**Solution**: The API client now includes `withCredentials: true` and proper session handling.

### **Debug Commands**

If you still have issues, use these debug commands:

1. **Test API connectivity**:
   ```bash
   curl -X GET "http://localhost:4000/api/openapi" -v
   ```

2. **Test CORS**:
   ```bash
   curl -X OPTIONS "http://localhost:4000/api/auth/google/authorize" \
     -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" -v
   ```

3. **Test OAuth endpoint**:
   ```bash
   curl -X GET "http://localhost:4000/api/auth/google/authorize" \
     -H "Origin: http://localhost:3000" -v
   ```

### **Production Setup**

For production deployment:

1. **Update CORS origins** in `lib/drive_box_web/endpoint.ex`:
   ```elixir
   origin: [
     "https://your-frontend-domain.com",
     "http://localhost:3000"  # Keep for development
   ]
   ```

2. **Update environment variables** in your frontend deployment:
   ```env
   NEXT_PUBLIC_API_BASE_URL=https://your-api-domain.com
   ```

### **Getting Help**

If you still encounter issues:

1. Check the browser console for detailed error messages
2. Check the Phoenix server logs for backend errors
3. Verify your OAuth app configurations
4. Make sure both servers are running on the correct ports

The fix should resolve the CORS issue and allow proper OAuth authentication flow between your Next.js frontend and Phoenix backend. 