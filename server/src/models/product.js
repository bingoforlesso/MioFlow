import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  code: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  image: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  stock: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
  },
  attributes: {
    type: DataTypes.JSON,
    allowNull: true,
  },
}, {
  timestamps: true,
  underscored: true,
});

// 定义 ProductInfo 模型，映射到 product_info 表
const ProductInfo = sequelize.define('ProductInfo', {
  id: {
    type: DataTypes.STRING,
    primaryKey: true,
  },
  code: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  brand: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  material_code: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  output_brand: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  product_name: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  model: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  specification: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  color: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  length: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  weight: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  wattage: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  pressure: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  degree: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  material: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
  },
  product_type: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  usage_type: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  sub_type: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'product_info',
  timestamps: false, // 假设表中没有时间戳列
});

export { ProductInfo };
export default Product; 