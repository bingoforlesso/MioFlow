import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || '127.0.0.1',
  port: Number(process.env.REDIS_PORT) || 6379,
  password: process.env.REDIS_PASSWORD,
  db: Number(process.env.REDIS_DB) || 0,
});

export const cache = {
  async get(key: string): Promise<string | null> {
    try {
      return await redis.get(key);
    } catch (error) {
      console.error('Redis get error:', error);
      return null;
    }
  },

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    try {
      if (ttlSeconds) {
        await redis.setex(key, ttlSeconds, value);
      } else {
        await redis.set(key, value);
      }
    } catch (error) {
      console.error('Redis set error:', error);
    }
  },

  async del(key: string): Promise<void> {
    try {
      await redis.del(key);
    } catch (error) {
      console.error('Redis del error:', error);
    }
  },

  async hget(hash: string, field: string): Promise<string | null> {
    try {
      return await redis.hget(hash, field);
    } catch (error) {
      console.error('Redis hget error:', error);
      return null;
    }
  },

  async hset(hash: string, field: string, value: string): Promise<void> {
    try {
      await redis.hset(hash, field, value);
    } catch (error) {
      console.error('Redis hset error:', error);
    }
  },

  async hdel(hash: string, field: string): Promise<void> {
    try {
      await redis.hdel(hash, field);
    } catch (error) {
      console.error('Redis hdel error:', error);
    }
  }
};