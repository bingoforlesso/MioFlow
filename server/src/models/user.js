import { DataTypes } from 'sequelize';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';

export default (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.STRING,
      primaryKey: true,
      defaultValue: () => `U${crypto.randomBytes(4).toString('hex').toUpperCase()}`
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true
    },
    encrypted_password: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING(20),
      allowNull: true
    },
    company_name: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'user',
    timestamps: false,
    hooks: {
      beforeCreate: async (user) => {
        if (user.encrypted_password) {
          user.encrypted_password = crypto.createHash('md5').update(user.encrypted_password).digest('hex');
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('encrypted_password')) {
          user.encrypted_password = crypto.createHash('md5').update(user.encrypted_password).digest('hex');
        }
      }
    }
  });

  return User;
}; 