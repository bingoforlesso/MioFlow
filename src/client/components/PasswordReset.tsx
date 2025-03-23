import React, { useState } from 'react';
import { Form, Input, Button, Card, message } from 'antd';
import { MailOutlined, LockOutlined } from '@ant-design/icons';
import { useLocation, useNavigate } from 'react-router-dom';

export const RequestPasswordReset: React.FC = () => {
  const [loading, setLoading] = useState(false);

  const onSubmit = async (values: { email: string }) => {
    setLoading(true);
    try {
      const response = await fetch('/api/auth/password-reset/request', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(values),
      });

      if (!response.ok) {
        throw new Error('重置密码请求失败');
      }

      message.success('重置密码链接已发送到您的邮箱');
    } catch (error) {
      message.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card title="重置密码" style={{ maxWidth: 400, margin: '40px auto' }}>
      <Form onFinish={onSubmit} layout="vertical">
        <Form.Item
          name="email"
          rules={[
            { required: true, message: '请输入邮箱' },
            { type: 'email', message: '请输入有效的邮箱地址' }
          ]}
        >
          <Input
            prefix={<MailOutlined />}
            placeholder="邮箱"
            size="large"
          />
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit" loading={loading} block>
            发送重置链接
          </Button>
        </Form.Item>
      </Form>
    </Card>
  );
};

export const ResetPassword: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  // 从URL获取重置令牌
  const token = new URLSearchParams(location.search).get('token');

  const onSubmit = async (values: { password: string; confirmPassword: string }) => {
    if (values.password !== values.confirmPassword) {
      message.error('两次输入的密码不一致');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/auth/password-reset/confirm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          token,
          new_password: values.password
        }),
      });

      if (!response.ok) {
        throw new Error('重置密码失败');
      }

      message.success('密码重置成功');
      navigate('/auth'); // 重定向到登录页
    } catch (error) {
      message.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  if (!token) {
    return <div>无效的重置链接</div>;
  }

  return (
    <Card title="设置新密码" style={{ maxWidth: 400, margin: '40px auto' }}>
      <Form onFinish={onSubmit} layout="vertical">
        <Form.Item
          name="password"
          rules={[
            { required: true, message: '请输入新密码' },
            { min: 6, message: '密码至少6个字符' }
          ]}
        >
          <Input.Password
            prefix={<LockOutlined />}
            placeholder="新密码"
            size="large"
          />
        </Form.Item>

        <Form.Item
          name="confirmPassword"
          rules={[
            { required: true, message: '请确认新密码' },
            { min: 6, message: '密码至少6个字符' }
          ]}
        >
          <Input.Password
            prefix={<LockOutlined />}
            placeholder="确认新密码"
            size="large"
          />
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit" loading={loading} block>
            重置密码
          </Button>
        </Form.Item>
      </Form>
    </Card>
  );
};