import React, { createContext, useContext, useState, useEffect } from 'react';

interface AuthContextType {
  isAuthenticated: boolean;
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  login: (userData: LoginResponse, rememberMe?: boolean) => void;
  logout: () => void;
  refreshAccessToken: () => Promise<void>;
}

interface User {
  id: string;
  username: string;
  email: string;
}

interface LoginResponse {
  user: User;
  access_token: string;
  refresh_token: string;
  token_type: string;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);

  useEffect(() => {
    // 从localStorage检查认证状态
    const storedToken = localStorage.getItem('auth_token');
    const storedRefreshToken = localStorage.getItem('refresh_token');
    const storedUser = localStorage.getItem('user');
    
    if (storedToken && storedRefreshToken && storedUser) {
      setToken(storedToken);
      setRefreshToken(storedRefreshToken);
      setUser(JSON.parse(storedUser));
      setIsAuthenticated(true);
    }
  }, []);

  const login = (userData: LoginResponse, rememberMe: boolean = false) => {
    setUser(userData.user);
    setToken(userData.access_token);
    setRefreshToken(userData.refresh_token);
    setIsAuthenticated(true);

    if (rememberMe) {
      // 如果选择"记住我"，则将认证信息存储在localStorage中
      localStorage.setItem('auth_token', userData.access_token);
      localStorage.setItem('refresh_token', userData.refresh_token);
      localStorage.setItem('user', JSON.stringify(userData.user));
    } else {
      // 否则使用sessionStorage（浏览器关闭后清除）
      sessionStorage.setItem('auth_token', userData.access_token);
      sessionStorage.setItem('refresh_token', userData.refresh_token);
      sessionStorage.setItem('user', JSON.stringify(userData.user));
    }
  };

  const logout = async () => {
    try {
      // 调用登出API
      if (token) {
        await fetch('/api/auth/logout', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });
      }
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      // 清除所有认证状态
      setUser(null);
      setToken(null);
      setRefreshToken(null);
      setIsAuthenticated(false);
      localStorage.removeItem('auth_token');
      localStorage.removeItem('refresh_token');
      localStorage.removeItem('user');
      sessionStorage.removeItem('auth_token');
      sessionStorage.removeItem('refresh_token');
      sessionStorage.removeItem('user');
    }
  };

  const refreshAccessToken = async () => {
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    try {
      const response = await fetch('/api/auth/refresh-token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ refresh_token: refreshToken }),
      });

      if (!response.ok) {
        throw new Error('Token refresh failed');
      }

      const data = await response.json();
      setToken(data.access_token);

      // 更新存储
      if (localStorage.getItem('auth_token')) {
        localStorage.setItem('auth_token', data.access_token);
      } else {
        sessionStorage.setItem('auth_token', data.access_token);
      }
    } catch (error) {
      console.error('Token refresh error:', error);
      // 如果刷新令牌失败，登出用户
      await logout();
      throw error;
    }
  };

  return (
    <AuthContext.Provider 
      value={{ 
        isAuthenticated, 
        user, 
        token, 
        refreshToken,
        login, 
        logout,
        refreshAccessToken
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};