import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

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
  timestamps: false,
});

export { ProductInfo }; 