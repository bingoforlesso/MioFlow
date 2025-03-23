import React from 'react';
import { Form, Input, Button, Card, message } from 'antd';
import { UserOutlined, LockOutlined, MailOutlined, PhoneOutlined } from '@ant-design/icons';

interface RegisterProps {
  onSuccess: () => void;
  onLoginClick: () => void;
}

export const Register: React.FC<RegisterProps> = ({ onSuccess, onLoginClick }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = React.useState(false);

  const handleSubmit = async (values: any) => {
    if (values.password !== values.confirmPassword) {
      message.error('两次输入的密码不一致');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: values.username,
          password: values.password,
          email: values.email,
          phone: values.phone
        })
      });

      const data = await response.json();
      if (!response.ok) {
        throw new Error(data.message || '注册失败');
      }

      message.success('注册成功');
      onSuccess();
    } catch (error) {
      message.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card title="注册" style={{ maxWidth: 400, margin: '40px auto' }}>
      <Form
        form={form}
        onFinish={handleSubmit}
        layout="vertical"
      >
        <Form.Item
          name="username"
          rules={[
            { required: true, message: '请输入用户名' },
            { min: 3, message: '用户名至少3个字符' }
          ]}
        >
          <Input 
            prefix={<UserOutlined />}
            placeholder="用户名"
            size="large"
          />
        </Form.Item>

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

        <Form.Item
          name="phone"
          rules={[
            { required: true, message: '请输入手机号' },
            { pattern: /^1[3-9]\d{9}$/, message: '请输入有效的手机号' }
          ]}
        >
          <Input
            prefix={<PhoneOutlined />}
            placeholder="手机号"
            size="large"
          />
        </Form.Item>

        <Form.Item
          name="password"
          rules={[
            { required: true, message: '请输入密码' },
            { min: 6, message: '密码至少6个字符' }
          ]}
        >
          <Input.Password
            prefix={<LockOutlined />}
            placeholder="密码"
            size="large"
          />
        </Form.Item>

        <Form.Item
          name="confirmPassword"
          rules={[
            { required: true, message: '请确认密码' },
            ({ getFieldValue }) => ({
              validator(_, value) {
                if (!value || getFieldValue('password') === value) {
                  return Promise.resolve();
                }
                return Promise.reject(new Error('两次输入的密码不一致'));
              },
            }),
          ]}
        >
          <Input.Password
            prefix={<LockOutlined />}
            placeholder="确认密码"
            size="large"
          />
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit" loading={loading} block>
            注册
          </Button>
        </Form.Item>

        <div style={{ textAlign: 'center' }}>
          <Button type="link" onClick={onLoginClick}>
            已有账号？立即登录
          </Button>
        </div>
      </Form>
    </Card>
  );
};