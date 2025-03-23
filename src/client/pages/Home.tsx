import React, { useState } from 'react';
import { Layout, Menu, Badge, Modal, message } from 'antd';
import { ShoppingCartOutlined } from '@ant-design/icons';
import { DialogInput } from '../components/DialogInput';
import { ProductCard } from '../components/ProductCard';
import { Cart } from '../components/Cart';
import { OrderConfirm } from '../components/OrderConfirm';

const { Header, Content } = Layout;

export const Home: React.FC = () => {
  const [searchResult, setSearchResult] = useState<any>(null);
  const [cartVisible, setCartVisible] = useState(false);
  const [orderVisible, setOrderVisible] = useState(false);
  const [selectedItems, setSelectedItems] = useState<any[]>([]);
  const userId = 'test-user'; // 实际应用中应该从登录状态获取

  const handleSearch = async (text: string) => {
    try {
      const response = await fetch('/api/dialog/parse', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text })
      });
      const result = await response.json();
      setSearchResult(result);
    } catch (error) {
      message.error('搜索失败');
    }
  };

  const handleAddToCart = async (product: any) => {
    try {
      await fetch('/api/cart/add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId,
          productCode: product.code,
          quantity: 1
        })
      });
      message.success('已添加到购物车');
    } catch (error) {
      message.error('添加失败');
    }
  };

  const handleCheckout = (items: any[]) => {
    setSelectedItems(items);
    setCartVisible(false);
    setOrderVisible(true);
  };

  const handleOrderSubmit = async (orderData: any) => {
    try {
      const response = await fetch('/api/order/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderData)
      });
      const result = await response.json();
      
      if (result.success) {
        setOrderVisible(false);
        Modal.success({
          title: '下单成功',
          content: (
            <div>
              <p>订单号：{result.orderNo}</p>
              <p>请保持手机畅通，经销商稍后会与您联系</p>
            </div>
          )
        });
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      message.error('提交订单失败');
    }
  };

  return (
    <Layout>
      <Header style={{ background: '#fff', padding: '0 50px' }}>
        <div style={{ float: 'left', fontSize: '20px', fontWeight: 'bold' }}>
          MioFlow
        </div>
        <div style={{ float: 'right' }}>
          <Badge count={5}>
            <ShoppingCartOutlined 
              style={{ fontSize: '24px', cursor: 'pointer' }}
              onClick={() => setCartVisible(true)}
            />
          </Badge>
        </div>
      </Header>
      <Content style={{ padding: '50px', minHeight: 'calc(100vh - 64px)' }}>
        <DialogInput onSend={handleSearch} />
        
        {searchResult && (
          <div style={{ marginTop: 24 }}>
            {searchResult.type === 'UNIQUE_MATCH' && (
              <ProductCard
                product={searchResult.product}
                onAddToCart={() => handleAddToCart(searchResult.product)}
              />
            )}
            {searchResult.type === 'MULTIPLE_MATCHES' && (
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 16 }}>
                {searchResult.products.map((product: any) => (
                  <ProductCard
                    key={product.code}
                    product={product}
                    onAddToCart={() => handleAddToCart(product)}
                  />
                ))}
              </div>
            )}
            {searchResult.type === 'NO_MATCH' && (
              <div style={{ textAlign: 'center', color: '#999' }}>
                未找到匹配的商品
              </div>
            )}
          </div>
        )}
      </Content>

      <Modal
        title="购物车"
        open={cartVisible}
        onCancel={() => setCartVisible(false)}
        footer={null}
        width={800}
      >
        <Cart userId={userId} onCheckout={handleCheckout} />
      </Modal>

      <Modal
        title="确认订单"
        open={orderVisible}
        onCancel={() => setOrderVisible(false)}
        footer={null}
        width={800}
      >
        <OrderConfirm
          userId={userId}
          items={selectedItems}
          onSubmit={handleOrderSubmit}
        />
      </Modal>
    </Layout>
  );
};