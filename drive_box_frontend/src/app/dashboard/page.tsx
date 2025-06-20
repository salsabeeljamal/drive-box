'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
// eslint-disable-next-line @typescript-eslint/no-unused-vars
import { api, FileInfo, Repository, DropboxFile } from '@/lib/api';
import { formatFileSize, formatDate, getFileIcon, downloadBlob } from '@/lib/utils';

export default function Dashboard() {
  const { isAuthenticated, loading, connectedProviders, logout, disconnectProvider } = useAuth();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<string>('');

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.push('/');
    } else if (!loading && connectedProviders.length > 0) {
      setActiveTab(connectedProviders[0].provider);
    }
  }, [isAuthenticated, loading, connectedProviders, router]);

  // Google Drive data
  const { data: googleFiles, isLoading: googleLoading, error: googleError } = useQuery({
    queryKey: ['google-files'],
    queryFn: () => api.getGoogleFiles({ limit: 20 }),
    enabled: connectedProviders.some(p => p.provider === 'google'),
  });

  // GitHub data
  const { data: githubRepos, isLoading: githubLoading, error: githubError } = useQuery({
    queryKey: ['github-repos'],
    queryFn: () => api.getGitHubRepositories({ limit: 20 }),
    enabled: connectedProviders.some(p => p.provider === 'github'),
  });

  // Dropbox data
  const { data: dropboxFiles, isLoading: dropboxLoading, error: dropboxError } = useQuery({
    queryKey: ['dropbox-files'],
    queryFn: () => api.getDropboxFiles({}),
    enabled: connectedProviders.some(p => p.provider === 'dropbox'),
  });

  const handleDownload = async (provider: string, fileId: string, fileName: string) => {
    try {
      let blob: Blob;
      
      if (provider === 'google') {
        blob = await api.downloadGoogleFile(fileId);
      } else if (provider === 'dropbox') {
        blob = await api.downloadDropboxFile(fileId);
      } else {
        return;
      }
      
      downloadBlob(blob, fileName);
    } catch (error) {
      console.error('Download failed:', error);
    }
  };

  const handleDisconnect = async (provider: string) => {
    try {
      await disconnectProvider(provider);
      if (activeTab === provider) {
        const remainingProviders = connectedProviders.filter(p => p.provider !== provider);
        setActiveTab(remainingProviders.length > 0 ? remainingProviders[0].provider : '');
      }
    } catch (error) {
      console.error('Disconnect failed:', error);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-2">Manage your connected cloud storage accounts</p>
        </div>
        <button
          onClick={logout}
          className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-md transition-colors"
        >
          Logout
        </button>
      </div>

      {/* Connected Providers Tabs */}
      <div className="bg-white rounded-lg shadow-md mb-8">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {connectedProviders.map((provider) => (
              <button
                key={provider.provider}
                onClick={() => setActiveTab(provider.provider)}
                className={`py-4 px-2 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === provider.provider
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {provider.provider === 'google' && '🟢 Google Drive'}
                {provider.provider === 'github' && '🐙 GitHub'}
                {provider.provider === 'dropbox' && '📦 Dropbox'}
              </button>
            ))}
          </nav>
        </div>

        {/* Content Area */}
        <div className="p-6">
          {activeTab === 'google' && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-semibold">Google Drive Files</h2>
                <button
                  onClick={() => handleDisconnect('google')}
                  className="text-red-500 hover:text-red-700 text-sm"
                >
                  Disconnect
                </button>
              </div>
              
              {googleLoading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
              ) : googleError ? (
                <div className="text-red-500 text-center py-8">
                  Failed to load Google Drive files
                </div>
              ) : (
                <div className="space-y-3">
                  {googleFiles?.files.map((file) => (
                    <div key={file.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center space-x-3">
                        <span className="text-2xl">{getFileIcon(file.mimeType)}</span>
                        <div>
                          <h3 className="font-medium text-gray-900">{file.name}</h3>
                          <p className="text-sm text-gray-500">
                            {formatFileSize(file.size)} • {formatDate(file.modifiedTime)}
                          </p>
                        </div>
                      </div>
                      <button
                        onClick={() => handleDownload('google', file.id, file.name)}
                        className="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm transition-colors"
                      >
                        Download
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeTab === 'github' && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-semibold">GitHub Repositories</h2>
                <button
                  onClick={() => handleDisconnect('github')}
                  className="text-red-500 hover:text-red-700 text-sm"
                >
                  Disconnect
                </button>
              </div>
              
              {githubLoading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
              ) : githubError ? (
                <div className="text-red-500 text-center py-8">
                  Failed to load GitHub repositories
                </div>
              ) : (
                <div className="space-y-3">
                  {githubRepos?.repositories.map((repo) => (
                    <div key={repo.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center space-x-3">
                        <span className="text-2xl">📁</span>
                        <div>
                          <h3 className="font-medium text-gray-900">{repo.name}</h3>
                          <p className="text-sm text-gray-500">
                            {repo.description || 'No description'} • {repo.language || 'Unknown language'}
                          </p>
                          <p className="text-xs text-gray-400">
                            Updated {formatDate(repo.updatedAt)}
                          </p>
                        </div>
                      </div>
                      <a
                        href={repo.htmlUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="bg-gray-800 hover:bg-gray-900 text-white px-3 py-1 rounded text-sm transition-colors"
                      >
                        View on GitHub
                      </a>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeTab === 'dropbox' && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-semibold">Dropbox Files</h2>
                <button
                  onClick={() => handleDisconnect('dropbox')}
                  className="text-red-500 hover:text-red-700 text-sm"
                >
                  Disconnect
                </button>
              </div>
              
              {dropboxLoading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
              ) : dropboxError ? (
                <div className="text-red-500 text-center py-8">
                  Failed to load Dropbox files
                </div>
              ) : (
                <div className="space-y-3">
                  {dropboxFiles?.files.map((file, index) => (
                    <div key={index} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center space-x-3">
                        <span className="text-2xl">📄</span>
                        <div>
                          <h3 className="font-medium text-gray-900">{file.name || 'Unknown file'}</h3>
                          <p className="text-sm text-gray-500">
                            {file.size ? formatFileSize(file.size) : 'Unknown size'}
                          </p>
                        </div>
                      </div>
                      <button
                        onClick={() => handleDownload('dropbox', file.path_lower, file.name)}
                        className="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm transition-colors"
                      >
                        Download
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
} 