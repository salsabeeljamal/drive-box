'use client';

import { useEffect, useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { api } from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';

function AuthCallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { refreshProviders } = useAuth();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [error, setError] = useState<string>('');

  useEffect(() => {
    const handleCallback = async () => {
      try {
        const code = searchParams.get('code');
        const state = searchParams.get('state');
        const error = searchParams.get('error');
        
        // Handle OAuth errors
        if (error) {
          throw new Error(`OAuth error: ${error}`);
        }
        
        // Try to get provider from URL params, localStorage, or detect from referrer
        let provider = searchParams.get('provider') || localStorage.getItem('oauth_provider');
        
        // If still no provider, try to detect from the current URL or referrer
        if (!provider && typeof window !== 'undefined') {
          const currentPath = window.location.pathname;
          if (currentPath.includes('/google/')) {
            provider = 'google';
          } else if (currentPath.includes('/github/')) {
            provider = 'github';
          } else if (currentPath.includes('/dropbox/')) {
            provider = 'dropbox';
          }
        }

        if (!code || !state || !provider) {
          throw new Error('Missing required parameters (code, state, or provider)');
        }

        const response = await api.handleCallback(provider, code, state);
        
        if (response.token) {
          api.setToken(response.token);
          await refreshProviders();
          setStatus('success');
          
          // Redirect to dashboard after a brief delay
          setTimeout(() => {
            router.push('/dashboard');
          }, 2000);
        } else {
          throw new Error('No token received');
        }
      } catch (err) {
        console.error('Callback error:', err);
        setError(err instanceof Error ? err.message : 'Authentication failed');
        setStatus('error');
        
        // Redirect to home after showing error
        setTimeout(() => {
          router.push('/');
        }, 3000);
      }
    };

    handleCallback();
  }, [searchParams, router, refreshProviders]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full bg-white rounded-lg shadow-md p-8 text-center">
        {status === 'loading' && (
          <>
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">
              Completing Authentication...
            </h2>
            <p className="text-gray-600">
              Please wait while we connect your account.
            </p>
          </>
        )}

        {status === 'success' && (
          <>
            <div className="text-green-500 text-6xl mb-4">✅</div>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">
              Authentication Successful!
            </h2>
            <p className="text-gray-600">
              Redirecting you to the dashboard...
            </p>
          </>
        )}

        {status === 'error' && (
          <>
            <div className="text-red-500 text-6xl mb-4">❌</div>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">
              Authentication Failed
            </h2>
            <p className="text-gray-600 mb-4">
              {error || 'An error occurred during authentication.'}
            </p>
            <p className="text-sm text-gray-500">
              Redirecting you back to the home page...
            </p>
          </>
        )}
      </div>
    </div>
  );
}

export default function AuthCallback() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    }>
      <AuthCallbackContent />
    </Suspense>
  );
} 