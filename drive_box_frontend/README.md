# DriveBox Frontend

A modern Next.js frontend application for the DriveBox unified cloud storage platform. This frontend connects to the DriveBox Elixir API to provide a seamless interface for managing files across Google Drive, GitHub, and Dropbox.

## Features

- 🔐 **OAuth 2.0 Authentication** - Secure login with Google, GitHub, and Dropbox
- 📁 **Unified File Management** - Browse and download files from all connected services
- 🎨 **Modern UI** - Built with Tailwind CSS and responsive design
- ⚡ **Fast Performance** - Optimized with React Query for data fetching
- 📱 **Mobile Friendly** - Works seamlessly across all devices

## Tech Stack

- **Next.js 14** - React framework with App Router
- **TypeScript** - Type safety and better developer experience
- **Tailwind CSS** - Utility-first CSS framework
- **React Query** - Data fetching and state management
- **Axios** - HTTP client for API calls

## Prerequisites

- Node.js 18+ 
- npm or yarn
- DriveBox API server running (see main project README)

## Getting Started

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up environment variables**
   Create a `.env.local` file in the root directory:
   ```env
   NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   Navigate to [http://localhost:3000](http://localhost:3000)

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXT_PUBLIC_API_BASE_URL` | Base URL for the DriveBox API | `http://localhost:4000` |

## Usage

### Authentication Flow

1. Visit the homepage
2. Click "Connect" for any of the supported providers (Google Drive, GitHub, Dropbox)
3. Complete OAuth authentication with the provider
4. You'll be redirected back to the application dashboard

### Dashboard Features

- **Provider Tabs** - Switch between connected services
- **File Browsing** - View files and repositories from each service
- **Download Files** - Download files directly from Google Drive and Dropbox
- **Repository Links** - Open GitHub repositories in new tabs
- **Account Management** - Disconnect providers as needed

## API Integration

The frontend communicates with the DriveBox API through the following endpoints:

### Authentication
- `GET /api/auth/{provider}/authorize` - Get OAuth authorization URL
- `GET /api/auth/{provider}/callback` - Handle OAuth callback
- `GET /api/auth/` - Get connected providers
- `DELETE /api/auth/{provider}` - Disconnect provider

### Google Drive
- `GET /api/google/files` - List files
- `GET /api/google/files/{fileId}` - Get file details
- `GET /api/google/files/{fileId}/download` - Download file

### GitHub
- `GET /api/github/repositories` - List repositories
- `GET /api/github/repositories/{owner}/{repo}` - Get repository details

### Dropbox
- `GET /api/dropbox/files` - List files
- `GET /api/dropbox/files/download` - Download file

## Project Structure

```
drive_box_frontend/
├── src/
│   ├── app/                    # Next.js App Router pages
│   │   ├── auth/
│   │   │   └── callback/       # OAuth callback handling
│   │   ├── dashboard/          # Main dashboard page
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Homepage
│   │   └── providers.tsx       # React Query provider
│   ├── contexts/
│   │   └── AuthContext.tsx     # Authentication context
│   ├── lib/
│   │   ├── api.ts              # API client
│   │   └── utils.ts            # Utility functions
│   └── components/             # Reusable components (future)
├── public/                     # Static assets
├── tailwind.config.js          # Tailwind configuration
├── next.config.js              # Next.js configuration
└── package.json
```

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

### Adding New Features

1. **New API Endpoints** - Add methods to `src/lib/api.ts`
2. **New Pages** - Create in `src/app/` directory
3. **New Components** - Add to `src/components/` directory
4. **Styling** - Use Tailwind CSS classes

## Deployment

### Vercel (Recommended)

1. Push your code to GitHub
2. Connect your repository to Vercel
3. Set environment variables in Vercel dashboard
4. Deploy automatically on push

### Other Platforms

1. Build the application:
   ```bash
   npm run build
   ```

2. Start the production server:
   ```bash
   npm start
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is part of the DriveBox application. See the main project for license information.

## Support

For issues and questions:
1. Check the main DriveBox project documentation
2. Create an issue in the main repository
3. Check the API documentation for endpoint details
