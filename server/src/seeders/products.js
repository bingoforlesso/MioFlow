import Product from '../models/product.js';

export async function seedProducts() {
  try {
    const products = [
      {
        code: 'PIPE-001',
        name: '联塑 PVC-U给水管',
        description: '优质PVC-U给水管，耐腐蚀，使用寿命长',
        image: 'https://example.com/images/pipe-001.jpg',
        price: 158.00,
        stock: 100,
        attributes: {
          '压力': ['0.6MPa', '1.0MPa', '1.6MPa'],
          '规格': ['DN110'],
          '长度': ['4米', '6米'],
          '颜色': ['白色', '灰色']
        }
      },
      {
        code: 'PIPE-002',
        name: '联塑 PPR热水管',
        description: '环保PPR热水管，耐高温，安全可靠',
        image: 'https://example.com/images/pipe-002.jpg',
        price: 68.00,
        stock: 200,
        attributes: {
          '压力': ['1.25MPa', '2.0MPa'],
          '规格': ['DN20', 'DN25', 'DN32'],
          '长度': ['4米'],
          '颜色': ['绿色', '白色']
        }
      },
      {
        code: 'VALVE-001',
        name: '黄铜球阀',
        description: '优质黄铜材质，密封性能好',
        image: 'https://example.com/images/valve-001.jpg',
        price: 35.00,
        stock: 150,
        attributes: {
          '材质': ['黄铜'],
          '类型': ['内丝', '外丝'],
          '规格': ['DN15', 'DN20', 'DN25']
        }
      }
    ];

    await Product.bulkCreate(products);
    console.log('产品数据导入成功');
  } catch (error) {
    console.error('产品数据导入失败:', error);
    throw error;
  }
} 