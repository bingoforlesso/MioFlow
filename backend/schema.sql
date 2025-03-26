-- 删除已存在的表
DROP TABLE IF EXISTS product_attributes;
DROP TABLE IF EXISTS products;

-- 创建产品表
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    brand VARCHAR(100),
    material VARCHAR(100),
    specification VARCHAR(100),
    color VARCHAR(50),
    length VARCHAR(50),
    weight VARCHAR(50),
    pressure VARCHAR(50),
    degree VARCHAR(50),
    wattage VARCHAR(50),
    product_type VARCHAR(100),
    usage_type VARCHAR(100),
    sub_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_name (name),
    INDEX idx_brand (brand),
    INDEX idx_material (material),
    INDEX idx_specification (specification)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建产品属性表
CREATE TABLE IF NOT EXISTS product_attributes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    attribute VARCHAR(100) NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_attribute (attribute)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建示例数据
INSERT INTO products (code, name, description, brand, material, specification) VALUES
('BV-001', '1/2寸球阀', '标准1/2寸黄铜球阀', '金德', '黄铜', 'DN15'),
('BV-002', '3/4寸球阀', '标准3/4寸不锈钢球阀', '金德', '不锈钢', 'DN20'),
('BV-003', '1寸球阀', '标准1寸铜质球阀', '金德', '铜', 'DN25');

-- 插入产品属性
INSERT INTO product_attributes (product_id, attribute, value) VALUES
(1, '品牌', '金德'),
(1, '材质', '黄铜'),
(1, '规格', 'DN15'),
(2, '品牌', '金德'),
(2, '材质', '不锈钢'),
(2, '规格', 'DN20'),
(3, '品牌', '金德'),
(3, '材质', '铜'),
(3, '规格', 'DN25');