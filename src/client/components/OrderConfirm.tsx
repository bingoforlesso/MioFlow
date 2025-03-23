import React, { useState, useEffect } from 'react';
import { Card, Steps, Button, Form, Select, Radio, Space, message } from 'antd';
import type { RadioChangeEvent } from 'antd';

interface Address {
  id: number;
  tag: string;
  contact_name: string;
  phone: string;
  full_address: string;
}

interface Dealer {
  id: number;
  name: string;
  contact_phone: string;
  rating: number;
}

interface OrderConfirmProps {
  userId: string;
  items: any[];
  onSubmit: (orderData: any) => Promise<void>;
}

export const OrderConfirm: React.FC<OrderConfirmProps> = ({
  userId,
  items,
  onSubmit
}) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [addresses, setAddresses] = useState<Address[]>([]);
  const [dealers, setDealers] = useState<Dealer[]>([]);
  const [selectedAddress, setSelectedAddress] = useState<number>();
  const [selectedDealer, setSelectedDealer] = useState<number>();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchAddresses();
  }, [userId]);

  const fetchAddresses = async () => {
    try {
      const response = await fetch(`/api/addresses/${userId}`);
      const data = await response.json();
      setAddresses(data);
    } catch (error) {
      message.error('获取地址列表失败');
    }
  };

  const fetchDealers = async (addressId: number) => {
    try {
      const response = await fetch(`/api/dealers/nearby/${addressId}`);
      const data = await response.json();
      setDealers(data);
    } catch (error) {
      message.error('获取经销商列表失败');
    }
  };

  const handleAddressSelect = (e: RadioChangeEvent) => {
    setSelectedAddress(e.target.value);
    fetchDealers(e.target.value);
  };

  const handleDealerSelect = (e: RadioChangeEvent) => {
    setSelectedDealer(e.target.value);
  };

  const handleSubmit = async () => {
    if (!selectedAddress || !selectedDealer) {
      message.error('请选择配送地址和经销商');
      return;
    }

    setLoading(true);
    try {
      await onSubmit({
        userId,
        addressId: selectedAddress,
        dealerId: selectedDealer,
        items
      });
      message.success('订单提交成功');
    } catch (error) {
      message.error('订单提交失败');
    } finally {
      setLoading(false);
    }
  };

  const steps = [
    {
      title: '选择地址',
      content: (
        <Card title="配送地址">
          <Radio.Group onChange={handleAddressSelect} value={selectedAddress}>
            <Space direction="vertical">
              {addresses.map(address => (
                <Radio key={address.id} value={address.id}>
                  <Space direction="vertical">
                    <div>
                      {address.tag && <span>[{address.tag}] </span>}
                      {address.contact_name} {address.phone}
                    </div>
                    <div>{address.full_address}</div>
                  </Space>
                </Radio>
              ))}
            </Space>
          </Radio.Group>
        </Card>
      ),
    },
    {
      title: '选择经销商',
      content: (
        <Card title="服务经销商">
          <Radio.Group onChange={handleDealerSelect} value={selectedDealer}>
            <Space direction="vertical">
              {dealers.map(dealer => (
                <Radio key={dealer.id} value={dealer.id}>
                  <Space direction="vertical">
                    <div>{dealer.name}</div>
                    <div>联系电话：{dealer.contact_phone}</div>
                    <div>评分：{dealer.rating}分</div>
                  </Space>
                </Radio>
              ))}
            </Space>
          </Radio.Group>
        </Card>
      ),
    },
    {
      title: '确认订单',
      content: (
        <Card title="订单信息">
          <div>
            {items.map(item => (
              <div key={item.id} style={{ marginBottom: 16 }}>
                <Space>
                  <span>{item.product_name}</span>
                  <span>x{item.quantity}</span>
                  <span>¥{(item.price * item.quantity).toFixed(2)}</span>
                </Space>
              </div>
            ))}
            <div style={{ borderTop: '1px solid #f0f0f0', paddingTop: 16 }}>
              总计：¥
              {items
                .reduce((sum, item) => sum + item.price * item.quantity, 0)
                .toFixed(2)}
            </div>
          </div>
        </Card>
      ),
    },
  ];

  return (
    <div>
      <Steps current={currentStep} items={steps} style={{ marginBottom: 24 }} />
      <div>{steps[currentStep].content}</div>
      <div style={{ marginTop: 24 }}>
        {currentStep > 0 && (
          <Button style={{ marginRight: 8 }} onClick={() => setCurrentStep(c => c - 1)}>
            上一步
          </Button>
        )}
        {currentStep < steps.length - 1 && (
          <Button type="primary" onClick={() => setCurrentStep(c => c + 1)}>
            下一步
          </Button>
        )}
        {currentStep === steps.length - 1 && (
          <Button type="primary" loading={loading} onClick={handleSubmit}>
            提交订单
          </Button>
        )}
      </div>
    </div>
  );
};