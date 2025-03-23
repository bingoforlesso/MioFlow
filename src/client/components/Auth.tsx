import React from 'react';
import { Login } from './Login';
import { Register } from './Register';

interface AuthProps {
  onAuthSuccess: (data: { userId: string; token: string }) => void;
}

export const Auth: React.FC<AuthProps> = ({ onAuthSuccess }) => {
  const [isLogin, setIsLogin] = React.useState(true);

  const handleRegisterSuccess = () => {
    setIsLogin(true);
  };

  return isLogin ? (
    <Login
      onSuccess={onAuthSuccess}
      onRegisterClick={() => setIsLogin(false)}
    />
  ) : (
    <Register
      onSuccess={handleRegisterSuccess}
      onLoginClick={() => setIsLogin(true)}
    />
  );
};