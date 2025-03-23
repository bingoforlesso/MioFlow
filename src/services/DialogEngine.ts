import { ProductService } from './ProductService';

interface DialogSlot {
  brand?: string;
  specification?: string;
  pressure?: string;
  color?: string;
  length?: string;
}

export class DialogEngine {
  private productService: ProductService;

  constructor() {
    this.productService = new ProductService();
  }

  async parseSlots(text: string): Promise<DialogSlot> {
    // 简单的槽位解析逻辑
    const slots: DialogSlot = {};
    
    // 品牌匹配
    const brandMatch = text.match(/(联塑|伟星|金德)/);
    if (brandMatch) {
      slots.brand = brandMatch[0];
    }

    // 规格匹配
    const specMatch = text.match(/dn\d+/i);
    if (specMatch) {
      slots.specification = specMatch[0].toLowerCase();
    }

    // 压力匹配
    const pressureMatch = text.match(/(\d+\.?\d*)MPa/i);
    if (pressureMatch) {
      slots.pressure = pressureMatch[0].toUpperCase();
    }

    return slots;
  }

  async processUserInput(text: string) {
    // 1. 解析槽位
    const slots = await this.parseSlots(text);

    // 2. 查询商品
    const products = await this.productService.searchProducts(slots);

    // 3. 处理查询结果
    if (products.length === 0) {
      return {
        type: 'NO_MATCH',
        message: '未找到匹配的商品，请检查输入是否正确'
      };
    }

    if (products.length === 1) {
      return {
        type: 'UNIQUE_MATCH',
        product: products[0]
      };
    }

    // 多个匹配项，需要用户进一步选择
    return {
      type: 'MULTIPLE_MATCHES',
      products: products,
      missingAttributes: this.getMissingAttributes(products)
    };
  }

  private getMissingAttributes(products: any[]) {
    const attributes = new Set<string>();
    
    // 比较所有产品，找出差异属性
    products.forEach(product => {
      if (product.color) attributes.add('color');
      if (product.length) attributes.add('length');
    });

    return Array.from(attributes);
  }
}