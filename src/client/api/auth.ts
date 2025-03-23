interface LoginResponse {
  user: {
    id: string;
    username: string;
    email: string;
  };
  token: string;
}

interface LoginData {
  username: string;
  password: string;
}

interface RegisterData {
  username: string;
  password: string;
  email: string;
  phone: string;
}

export const login = async (data: LoginData): Promise<LoginResponse> => {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || '登录失败');
  }

  return response.json();
};

export const register = async (data: RegisterData): Promise<void> => {
  const response = await fetch('/api/auth/register', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || '注册失败');
  }
};

export const checkAuthStatus = async (token: string): Promise<LoginResponse> => {
  const response = await fetch('/api/auth/status', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error('认证已过期');
  }

  return response.json();
};