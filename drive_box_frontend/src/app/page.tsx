'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

const providers = [
  {
    name: 'google',
    display: 'Google Drive',
    icon: '🟢',
    description: 'Access your Google Drive files and folders',
    color: 'bg-blue-500 hover:bg-blue-600'
  },
  {
    name: 'github',
    display: 'GitHub',
    icon: '🐙',
    description: 'Browse your GitHub repositories and files',
    color: 'bg-gray-800 hover:bg-gray-900'
  },
  {
    name: 'dropbox',
    display: 'Dropbox',
    icon: '📦',
    description: 'Manage your Dropbox files and folders',
    color: 'bg-blue-600 hover:bg-blue-700'
  }
];

export default function Home() {
  const { isAuthenticated, loading, login, connectedProviders } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && isAuthenticated) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, loading, router]);

  const handleConnect = async (provider: string) => {
    try {
      await login(provider);
    } catch (error) {
      console.error('Connection failed:', error);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-12">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          Welcome to DriveBox
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Connect your cloud storage accounts and manage all your files from one place
        </p>
      </div>

      <div className="grid md:grid-cols-3 gap-6">
        {providers.map((provider) => {
          const isConnected = connectedProviders.some(p => p.provider === provider.name);
          
          return (
            <div
              key={provider.name}
              className="bg-white rounded-lg shadow-md p-6 border border-gray-200 hover:shadow-lg transition-shadow"
            >
              <div className="text-center">
                <div className="text-4xl mb-4">{provider.icon}</div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  {provider.display}
                </h3>
                <p className="text-gray-600 mb-6">{provider.description}</p>
                
                {isConnected ? (
                  <div className="flex items-center justify-center text-green-600 mb-4">
                    <span className="text-sm font-medium">✅ Connected</span>
                  </div>
                ) : (
                  <button
                    onClick={() => handleConnect(provider.name)}
                    className={`w-full text-white font-medium py-2 px-4 rounded-md transition-colors ${provider.color}`}
                  >
                    Connect {provider.display}
                  </button>
                )}
              </div>
            </div>
          );
        })}
      </div>

      <div className="mt-12 text-center">
        <div className="bg-white rounded-lg shadow-md p-6 border border-gray-200">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Features</h2>
          <div className="grid md:grid-cols-3 gap-6 text-left">
            <div>
              <h3 className="font-semibold text-gray-900 mb-2">🔒 Secure Access</h3>
              <p className="text-gray-600 text-sm">
                OAuth 2.0 authentication ensures your data stays secure
              </p>
            </div>
            <div>
              <h3 className="font-semibold text-gray-900 mb-2">🚀 Fast Performance</h3>
              <p className="text-gray-600 text-sm">
                Built with modern technologies for optimal speed
              </p>
            </div>
            <div>
              <h3 className="font-semibold text-gray-900 mb-2">📱 Responsive Design</h3>
              <p className="text-gray-600 text-sm">
                Works seamlessly on desktop, tablet, and mobile devices
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
