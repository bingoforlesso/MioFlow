/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 90200 (9.2.0)
 Source Host           : localhost:3306
 Source Schema         : Lesso

 Target Server Type    : MySQL
 Target Server Version : 90200 (9.2.0)
 File Encoding         : 65001

 Date: 23/03/2025 13:45:26
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for product_info
-- ----------------------------
DROP TABLE IF EXISTS `product_info`;
CREATE TABLE `product_info` (
  `id` varchar(255) NOT NULL COMMENT '产品唯一标识',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '产品编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '产品全称',
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品牌名称',
  `material_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料编码',
  `output_brand` varchar(255) DEFAULT NULL COMMENT '品牌',
  `product_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `model` varchar(255) DEFAULT NULL COMMENT '型号',
  `specification` varchar(255) DEFAULT NULL COMMENT '规格',
  `color` varchar(255) DEFAULT NULL COMMENT '颜色',
  `length` varchar(255) DEFAULT NULL COMMENT '长度',
  `weight` varchar(255) DEFAULT NULL COMMENT '重量',
  `wattage` varchar(255) DEFAULT NULL COMMENT '瓦数',
  `pressure` varchar(255) DEFAULT NULL COMMENT '压力',
  `degree` varchar(255) DEFAULT NULL COMMENT '度数',
  `material` varchar(255) DEFAULT NULL COMMENT '材质',
  PRIMARY KEY (`id`),
  KEY `idx_code` (`code`),
  KEY `idx_material` (`material_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品信息表';

SET FOREIGN_KEY_CHECKS = 1;
