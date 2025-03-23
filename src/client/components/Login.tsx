import React, { useState } from 'react';
import { Form, Input, Button, Card, message, Checkbox } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import { useAuth } from '../contexts/AuthContext';

interface LoginProps {
  onSuccess: () => void;
  onRegisterClick: () => void;
}

interface LoginForm {
  username: string;
  password: string;
  remember: boolean;
}

export const Login: React.FC<LoginProps> = ({ onSuccess, onRegisterClick }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const [remainingAttempts, setRemainingAttempts] = useState<{
    fifteen_min_remaining?: number;
    daily_remaining?: number;
  }>({});

  const handleSubmit = async (values: LoginForm) => {
    setLoading(true);
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: values.username,
          password: values.password,
          remember_me: values.remember
        })
      });

      const data = await response.json();

      if (!response.ok) {
        // 处理登录尝试限制
        if (response.status === 429) {
          throw new Error(data.detail || '登录尝试次数过多，请稍后重试');
        }

        // 如果响应中包含剩余尝试次数信息
        if (data.detail && data.detail.includes('剩余尝试次数')) {
          const matches = data.detail.match(/15分钟内(\d+)次.*24小时内(\d+)次/);
          if (matches) {
            setRemainingAttempts({
              fifteen_min_remaining: parseInt(matches[1]),
              daily_remaining: parseInt(matches[2])
            });
          }
        }

        throw new Error(data.detail || '登录失败');
      }

      // 登录成功
      login(data, values.remember);
      message.success('登录成功');
      onSuccess();
    } catch (error) {
      message.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card title="登录" style={{ maxWidth: 400, margin: '40px auto' }}>
      <Form
        form={form}
        onFinish={handleSubmit}
        layout="vertical"
      >
        <Form.Item
          name="username"
          rules={[{ required: true, message: '请输入用户名' }]}
        >
          <Input 
            prefix={<UserOutlined />}
            placeholder="用户名"
            size="large"
          />
        </Form.Item>

        <Form.Item
          name="password"
          rules={[{ required: true, message: '请输入密码' }]}
        >
          <Input.Password
            prefix={<LockOutlined />}
            placeholder="密码"
            size="large"
          />
        </Form.Item>

        <Form.Item name="remember" valuePropName="checked">
          <Checkbox>记住我</Checkbox>
        </Form.Item>

        {(remainingAttempts.fifteen_min_remaining !== undefined || 
          remainingAttempts.daily_remaining !== undefined) && (
          <div style={{ marginBottom: 16, color: '#ff4d4f' }}>
            剩余登录尝试次数：
            {remainingAttempts.fifteen_min_remaining !== undefined && 
              `15分钟内还剩 ${remainingAttempts.fifteen_min_remaining} 次`}
            {remainingAttempts.daily_remaining !== undefined && 
              `，24小时内还剩 ${remainingAttempts.daily_remaining} 次`}
          </div>
        )}

        <Form.Item>
          <Button type="primary" htmlType="submit" loading={loading} block>
            登录
          </Button>
        </Form.Item>

        <div style={{ textAlign: 'center' }}>
          <Button type="link" onClick={onRegisterClick}>
            没有账号？立即注册
          </Button>
        </div>
      </Form>
    </Card>
  );
};