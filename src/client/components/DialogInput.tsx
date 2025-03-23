import React, { useState } from 'react';
import { Input, Button, Card, Space, message } from 'antd';
import { SendOutlined } from '@ant-design/icons';

interface DialogInputProps {
  onSend: (text: string) => Promise<void>;
}

export const DialogInput: React.FC<DialogInputProps> = ({ onSend }) => {
  const [text, setText] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    if (!text.trim()) {
      message.warning('请输入商品信息');
      return;
    }

    setLoading(true);
    try {
      await onSend(text);
      setText('');
    } catch (error) {
      message.error('发送失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <Space.Compact style={{ width: '100%' }}>
        <Input
          placeholder="请输入商品信息，如：联塑 dn110 0.6MPa"
          value={text}
          onChange={e => setText(e.target.value)}
          onPressEnter={handleSend}
        />
        <Button 
          type="primary"
          icon={<SendOutlined />}
          loading={loading}
          onClick={handleSend}
        >
          发送
        </Button>
      </Space.Compact>
    </Card>
  );
};