import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';
import Order from './order.js';
import { ProductInfo } from './product.js';

const OrderItem = sequelize.define('OrderItem', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  orderId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Order,
      key: 'id'
    }
  },
  productId: {
    type: DataTypes.STRING,
    allowNull: false,
    references: {
      model: ProductInfo,
      key: 'id'
    }
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  attributes: {
    type: DataTypes.JSON,
    allowNull: true,
  },
}, {
  timestamps: true,
  underscored: true,
});

// 设置关联关系
Order.hasMany(OrderItem);
OrderItem.belongsTo(Order);
OrderItem.belongsTo(ProductInfo);

export default OrderItem; 