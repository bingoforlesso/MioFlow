import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';

import { AuthProvider } from './contexts/AuthContext';
import { Auth } from './components/Auth';
import { PrivateRoute } from './components/PrivateRoute';
import { useAuth } from './contexts/AuthContext';

// 示例受保护的组件
const Dashboard = () => {
  const { user, logout } = useAuth();
  return (
    <div>
      <h1>欢迎, {user?.username}!</h1>
      <button onClick={logout}>退出登录</button>
    </div>
  );
};

const AppRoutes = () => {
  const { isAuthenticated } = useAuth();

  return (
    <Routes>
      <Route 
        path="/auth" 
        element={
          isAuthenticated ? <Navigate to="/dashboard" replace /> : <Auth onAuthSuccess={() => {}} />
        } 
      />
      <Route
        path="/dashboard"
        element={
          <PrivateRoute>
            <Dashboard />
          </PrivateRoute>
        }
      />
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};

const App: React.FC = () => {
  return (
    <ConfigProvider locale={zhCN}>
      <AuthProvider>
        <Router>
          <AppRoutes />
        </Router>
      </AuthProvider>
    </ConfigProvider>
  );
};

export default App;