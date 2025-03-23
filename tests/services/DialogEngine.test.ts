import { DialogEngine } from '../../src/services/DialogEngine';

describe('DialogEngine', () => {
  let dialogEngine: DialogEngine;

  beforeEach(() => {
    dialogEngine = new DialogEngine();
  });

  describe('parseSlots', () => {
    it('should parse brand correctly', async () => {
      const text = '联塑 dn110 0.6MPa';
      const slots = await dialogEngine.parseSlots(text);
      expect(slots.brand).toBe('联塑');
    });

    it('should parse specification correctly', async () => {
      const text = '联塑 dn110 0.6MPa';
      const slots = await dialogEngine.parseSlots(text);
      expect(slots.specification).toBe('dn110');
    });

    it('should parse pressure correctly', async () => {
      const text = '联塑 dn110 0.6MPa';
      const slots = await dialogEngine.parseSlots(text);
      expect(slots.pressure).toBe('0.6MPa');
    });

    it('should handle incomplete input', async () => {
      const text = '联塑 dn110';
      const slots = await dialogEngine.parseSlots(text);
      expect(slots.brand).toBe('联塑');
      expect(slots.specification).toBe('dn110');
      expect(slots.pressure).toBeUndefined();
    });
  });

  describe('processUserInput', () => {
    it('should handle no matches', async () => {
      const text = '不存在的商品';
      const result = await dialogEngine.processUserInput(text);
      expect(result.type).toBe('NO_MATCH');
    });

    it('should handle unique match', async () => {
      // Mock product service to return single product
      const text = '联塑 dn110 0.6MPa 白色 6M';
      const result = await dialogEngine.processUserInput(text);
      expect(result.type).toBe('UNIQUE_MATCH');
      expect(result.product).toBeDefined();
    });

    it('should handle multiple matches', async () => {
      // Mock product service to return multiple products
      const text = '联塑 dn110';
      const result = await dialogEngine.processUserInput(text);
      expect(result.type).toBe('MULTIPLE_MATCHES');
      expect(result.products.length).toBeGreaterThan(1);
      expect(result.missingAttributes).toBeDefined();
    });
  });
});