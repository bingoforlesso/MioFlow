import { db } from '../src/utils/db';

// 在所有测试开始前执行
beforeAll(async () => {
  // 可以在这里设置测试数据库连接
});

// 在所有测试结束后执行
afterAll(async () => {
  // 清理测试数据库连接
  await db.end();
});

// 在每个测试用例开始前执行
beforeEach(async () => {
  // 可以在这里设置测试数据
});

// 在每个测试用例结束后执行
afterEach(async () => {
  // 清理测试数据
});