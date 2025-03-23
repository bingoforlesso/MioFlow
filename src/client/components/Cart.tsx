import React, { useState, useEffect } from 'react';
import { Table, Button, InputNumber, Space, message, Modal } from 'antd';
import { DeleteOutlined, ShoppingCartOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';

interface CartItem {
  id: number;
  product_code: string;
  product_name: string;
  specification: string;
  quantity: number;
  price: number;
  selected_attrs: {
    color?: string;
    length?: string;
  };
}

interface CartProps {
  userId: string;
  onCheckout: (items: CartItem[]) => void;
}

export const Cart: React.FC<CartProps> = ({ userId, onCheckout }) => {
  const [items, setItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedRowKeys, setSelectedRowKeys] = useState<React.Key[]>([]);

  useEffect(() => {
    fetchCartItems();
  }, [userId]);

  const fetchCartItems = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/cart/${userId}`);
      const data = await response.json();
      setItems(data);
    } catch (error) {
      message.error('获取购物车失败');
    } finally {
      setLoading(false);
    }
  };

  const handleQuantityChange = async (id: number, quantity: number) => {
    try {
      await fetch(`/api/cart/update`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id, quantity })
      });
      fetchCartItems();
    } catch (error) {
      message.error('更新数量失败');
    }
  };

  const handleDelete = async (id: number) => {
    Modal.confirm({
      title: '确认删除',
      content: '确定要从购物车中删除该商品吗？',
      onOk: async () => {
        try {
          await fetch(`/api/cart/${id}`, { method: 'DELETE' });
          fetchCartItems();
          message.success('删除成功');
        } catch (error) {
          message.error('删除失败');
        }
      }
    });
  };

  const columns: ColumnsType<CartItem> = [
    {
      title: '商品信息',
      dataIndex: 'product_name',
      render: (text, record) => (
        <Space direction="vertical">
          <div>{text}</div>
          <div style={{ color: '#666' }}>{record.specification}</div>
          {record.selected_attrs.color && (
            <div style={{ color: '#666' }}>颜色：{record.selected_attrs.color}</div>
          )}
          {record.selected_attrs.length && (
            <div style={{ color: '#666' }}>长度：{record.selected_attrs.length}</div>
          )}
        </Space>
      ),
    },
    {
      title: '单价',
      dataIndex: 'price',
      render: (price) => `¥${price.toFixed(2)}`,
      width: 120,
    },
    {
      title: '数量',
      dataIndex: 'quantity',
      width: 120,
      render: (quantity, record) => (
        <InputNumber
          min={1}
          value={quantity}
          onChange={(value) => handleQuantityChange(record.id, value || 1)}
        />
      ),
    },
    {
      title: '小计',
      width: 120,
      render: (_, record) => `¥${(record.price * record.quantity).toFixed(2)}`,
    },
    {
      title: '操作',
      width: 80,
      render: (_, record) => (
        <Button
          type="text"
          danger
          icon={<DeleteOutlined />}
          onClick={() => handleDelete(record.id)}
        />
      ),
    },
  ];

  const totalAmount = items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );

  return (
    <div>
      <Table
        columns={columns}
        dataSource={items}
        rowKey="id"
        loading={loading}
        rowSelection={{
          selectedRowKeys,
          onChange: setSelectedRowKeys,
        }}
        pagination={false}
        footer={() => (
          <div style={{ textAlign: 'right' }}>
            <Space>
              <span>
                已选商品 {selectedRowKeys.length} 件，
                合计：
                <span style={{ color: '#f5222d', fontSize: '20px' }}>
                  ¥{totalAmount.toFixed(2)}
                </span>
              </span>
              <Button
                type="primary"
                icon={<ShoppingCartOutlined />}
                disabled={selectedRowKeys.length === 0}
                onClick={() => onCheckout(
                  items.filter(item => selectedRowKeys.includes(item.id))
                )}
              >
                结算
              </Button>
            </Space>
          </div>
        )}
      />
    </div>
  );
};