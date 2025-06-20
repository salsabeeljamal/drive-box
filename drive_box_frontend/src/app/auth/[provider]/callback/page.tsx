'use client';

import { useEffect, Suspense } from 'react';
import { useRouter, useSearchParams, useParams } from 'next/navigation';

function ProviderCallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const params = useParams();

  useEffect(() => {
    const handleProviderCallback = async () => {
      try {
        // Get provider from the URL parameter
        const provider = params.provider as string;
        
        // Get OAuth response parameters
        const code = searchParams.get('code');
        const state = searchParams.get('state');
        const error = searchParams.get('error');

        // Validate provider
        const supportedProviders = ['google', 'github', 'dropbox'];
        if (!provider || !supportedProviders.includes(provider.toLowerCase())) {
          throw new Error(`Unsupported provider: ${provider}`);
        }

        // Handle OAuth errors
        if (error) {
          console.error(`${provider} OAuth error:`, error);
          const errorDescription = searchParams.get('error_description') || error;
          router.push(`/?error=${encodeURIComponent(`${provider} authentication failed: ${errorDescription}`)}`);
          return;
        }

        // Validate required parameters
        if (!code || !state) {
          throw new Error('Missing authorization code or state parameter');
        }

        // Redirect to the generic callback with provider parameter
        const callbackParams = new URLSearchParams({
          code,
          state,
          provider: provider.toLowerCase()
        });
        
        // Add any additional parameters that might be useful
        const scope = searchParams.get('scope');
        if (scope) {
          callbackParams.set('scope', scope);
        }

        console.log(`Processing ${provider} OAuth callback, redirecting to generic handler...`);
        router.push(`/auth/callback?${callbackParams.toString()}`);
        
      } catch (err) {
        console.error('Provider callback error:', err);
        const errorMessage = err instanceof Error ? err.message : 'Authentication failed';
        router.push(`/?error=${encodeURIComponent(errorMessage)}`);
      }
    };

    handleProviderCallback();
  }, [searchParams, router, params]);

  // Get provider name for display
  const provider = params.provider as string;
  const providerName = provider ? provider.charAt(0).toUpperCase() + provider.slice(1) : 'Provider';

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full bg-white rounded-lg shadow-md p-8 text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <h2 className="text-xl font-semibold text-gray-800 mb-2">
          Processing {providerName} Authentication...
        </h2>
        <p className="text-gray-600">
          Please wait while we complete your {providerName} login.
        </p>
      </div>
    </div>
  );
}

export default function ProviderCallback() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    }>
      <ProviderCallbackContent />
    </Suspense>
  );
} 