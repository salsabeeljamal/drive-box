'use client';

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { api, ConnectedProvider } from '@/lib/api';

interface AuthContextType {
  isAuthenticated: boolean;
  connectedProviders: ConnectedProvider[];
  loading: boolean;
  login: (provider: string) => Promise<void>;
  logout: () => void;
  disconnectProvider: (provider: string) => Promise<void>;
  refreshProviders: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [connectedProviders, setConnectedProviders] = useState<ConnectedProvider[]>([]);
  const [loading, setLoading] = useState(true);

  const checkAuth = async () => {
    try {
      const token = localStorage.getItem('driveBoxToken');
      if (token) {
        api.setToken(token);
        const providers = await api.getConnectedProviders();
        setConnectedProviders(providers);
        setIsAuthenticated(providers.length > 0);
      }
    } catch (error) {
      console.error('Auth check failed:', error);
      logout();
    } finally {
      setLoading(false);
    }
  };

  const login = async (provider: string) => {
    try {
      console.log('Starting OAuth flow for provider:', provider);
      const { authorize_url } = await api.getAuthUrl(provider);
      console.log('Got authorization URL:', authorize_url);
      
      // Store provider in localStorage for callback handling
      localStorage.setItem('oauth_provider', provider);
      
      window.location.href = authorize_url;
    } catch (error) {
      console.error('Login failed:', error);
      
      // More detailed error handling
      if (error instanceof Error) {
        console.error('Error details:', {
          message: error.message,
          stack: error.stack
        });
      }
      
      throw error;
    }
  };

  const logout = () => {
    api.clearToken();
    setIsAuthenticated(false);
    setConnectedProviders([]);
  };

  const disconnectProvider = async (provider: string) => {
    try {
      await api.disconnectProvider(provider);
      await refreshProviders();
    } catch (error) {
      console.error('Disconnect failed:', error);
      throw error;
    }
  };

  const refreshProviders = async () => {
    try {
      const providers = await api.getConnectedProviders();
      setConnectedProviders(providers);
      setIsAuthenticated(providers.length > 0);
    } catch (error) {
      console.error('Refresh providers failed:', error);
      throw error;
    }
  };

  useEffect(() => {
    checkAuth();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const value = {
    isAuthenticated,
    connectedProviders,
    loading,
    login,
    logout,
    disconnectProvider,
    refreshProviders,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
} 