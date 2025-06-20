import axios, { AxiosInstance, AxiosError } from 'axios';

export interface AuthResponse {
  token: string;
  user: {
    id: string;
    email: string;
    name: string;
  };
}

export interface FileInfo {
  id: string;
  name: string;
  mimeType: string;
  size: number;
  createdTime: string;
  modifiedTime: string;
  webViewLink?: string;
  downloadUrl?: string;
}

export interface Repository {
  id: string;
  name: string;
  fullName: string;
  description: string;
  private: boolean;
  htmlUrl: string;
  cloneUrl: string;
  language: string;
  updatedAt: string;
}

export interface DropboxAccount {
  accountId: string;
  name: {
    givenName: string;
    surname: string;
    displayName: string;
  };
  email: string;
}

export interface ConnectedProvider {
  id: string;
  provider: string;
  connected_at: string;
  user_info: string;
}

export interface DropboxFile {
  name: string;
  path_lower: string;
  size?: number;
  client_modified?: string;
}

class DriveBoxAPI {
  private api: AxiosInstance;
  private token: string | null = null;

  constructor() {
    this.api = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:4000',
      timeout: 30000,
      withCredentials: true, // Enable cookies for session handling
    });

    // Request interceptor to add auth token
    this.api.interceptors.request.use((config) => {
      if (this.token) {
        config.headers.Authorization = `Bearer ${this.token}`;
      }
      return config;
    });

    // Response interceptor for error handling
    this.api.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        console.error('API Request Error:', {
          url: error.config?.url,
          method: error.config?.method,
          status: error.response?.status,
          data: error.response?.data,
          message: error.message
        });

        if (error.response?.status === 401) {
          this.clearToken();
          // Only redirect if we're not already on the home page
          if (typeof window !== 'undefined' && window.location.pathname !== '/') {
            window.location.href = '/';
          }
        }
        return Promise.reject(error);
      }
    );

    // Load token from localStorage on initialization
    if (typeof window !== 'undefined') {
      this.token = localStorage.getItem('driveBoxToken');
    }
  }

  setToken(token: string) {
    this.token = token;
    if (typeof window !== 'undefined') {
      localStorage.setItem('driveBoxToken', token);
    }
  }

  clearToken() {
    this.token = null;
    if (typeof window !== 'undefined') {
      localStorage.removeItem('driveBoxToken');
    }
  }

  // Authentication methods
  async getAuthUrl(provider: string): Promise<{ authorize_url: string }> {
    // Don't send auth token for initial authorization request
    const response = await this.api.get(`/api/auth/${provider}/authorize`, {
      headers: {
        Authorization: undefined, // Override the interceptor
      }
    });
    return response.data;
  }

  async handleCallback(provider: string, code: string, state: string): Promise<AuthResponse> {
    // Don't send auth token for callback request
    const response = await this.api.get(`/api/auth/${provider}/callback`, {
      params: { code, state },
      headers: {
        Authorization: undefined, // Override the interceptor
      }
    });
    return response.data;
  }

  async getConnectedProviders(): Promise<ConnectedProvider[]> {
    const response = await this.api.get<{ providers: ConnectedProvider[] }>('/api/auth/');
    return response.data.providers || [];
  }

  async disconnectProvider(provider: string): Promise<{ message: string }> {
    const response = await this.api.delete(`/api/auth/${provider}`);
    return response.data;
  }

  // Google Drive methods
  async getGoogleFiles(params?: {
    limit?: number;
    offset?: number;
    sort?: string;
    order?: string;
  }): Promise<{ files: FileInfo[] }> {
    const response = await this.api.get('/api/google/files', { params });
    return response.data;
  }

  async getGoogleFile(fileId: string): Promise<{ file: FileInfo }> {
    const response = await this.api.get(`/api/google/files/${fileId}`);
    return response.data;
  }

  async downloadGoogleFile(fileId: string): Promise<Blob> {
    const response = await this.api.get(`/api/google/files/${fileId}/download`, {
      responseType: 'blob'
    });
    return response.data;
  }

  async uploadGoogleFile(file: File, options?: {
    parents?: string[];
    description?: string;
  }): Promise<{ file: FileInfo; message: string }> {
    const formData = new FormData();
    formData.append('file', file);
    if (options?.parents) {
      formData.append('parents', JSON.stringify(options.parents));
    }
    if (options?.description) {
      formData.append('description', options.description);
    }

    const response = await this.api.post('/api/google/files/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  // GitHub methods
  async getGitHubRepositories(params?: {
    limit?: number;
    offset?: number;
  }): Promise<{ repositories: Repository[] }> {
    const response = await this.api.get('/api/github/repositories', { params });
    return response.data;
  }

  async getGitHubRepository(owner: string, repo: string): Promise<{ repository: Repository }> {
    const response = await this.api.get(`/api/github/repositories/${owner}/${repo}`);
    return response.data;
  }

  async getGitHubContents(owner: string, repo: string, path?: string): Promise<unknown> {
    const url = path 
      ? `/api/github/repositories/${owner}/${repo}/contents/${path}`
      : `/api/github/repositories/${owner}/${repo}/contents`;
    const response = await this.api.get(url);
    return response.data;
  }

  async getGitHubProfile(): Promise<unknown> {
    const response = await this.api.get('/api/github/profile');
    return response.data;
  }

  // Dropbox methods
  async getDropboxFiles(params?: {
    path?: string;
    recursive?: boolean;
  }): Promise<{ files: DropboxFile[] }> {
    const response = await this.api.get('/api/dropbox/files', { params });
    return response.data;
  }

  async getDropboxFileMetadata(path: string): Promise<DropboxFile> {
    const response = await this.api.get('/api/dropbox/files/metadata', {
      params: { path }
    });
    return response.data;
  }

  async downloadDropboxFile(path: string): Promise<Blob> {
    const response = await this.api.get('/api/dropbox/files/download', {
      params: { path },
      responseType: 'blob'
    });
    return response.data;
  }

  async uploadDropboxFile(path: string, file: File): Promise<DropboxFile> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('path', path);

    const response = await this.api.post('/api/dropbox/files/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async createDropboxFolder(path: string): Promise<{ path: string; name: string }> {
    const response = await this.api.post('/api/dropbox/files/create_folder', {
      path
    });
    return response.data;
  }

  async deleteDropboxFile(path: string): Promise<{ message: string }> {
    const response = await this.api.delete('/api/dropbox/files', {
      params: { path }
    });
    return response.data;
  }

  async getDropboxAccountInfo(): Promise<DropboxAccount> {
    const response = await this.api.get('/api/dropbox/account');
    return response.data;
  }
}

export const api = new DriveBoxAPI();
export default api; 