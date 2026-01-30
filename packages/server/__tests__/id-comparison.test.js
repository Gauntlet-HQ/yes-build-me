/**
 * Tests for Issue #7: Campaign owner detection fails with string ID comparison
 * 
 * This test suite validates that ID comparisons work correctly across different
 * JavaScript types (Number, String, BigInt) that can occur when data flows
 * between SQLite (better-sqlite3), Express, and the frontend.
 */

import { describe, it, expect } from 'vitest'

/**
 * Helper function that mirrors the fix applied in campaigns.js
 * This is the pattern used to safely compare IDs regardless of type
 */
function isOwner(userId, campaignUserId) {
  return userId != null && Number(userId) === Number(campaignUserId)
}

describe('ID Comparison - Type Coercion', () => {
  describe('Number vs Number (baseline)', () => {
    it('should match when both are the same number', () => {
      expect(isOwner(1, 1)).toBe(true)
      expect(isOwner(42, 42)).toBe(true)
      expect(isOwner(999999, 999999)).toBe(true)
    })

    it('should not match when numbers differ', () => {
      expect(isOwner(1, 2)).toBe(false)
      expect(isOwner(42, 43)).toBe(false)
    })
  })

  describe('String vs Number (common API scenario)', () => {
    it('should match when string ID equals numeric ID', () => {
      expect(isOwner('1', 1)).toBe(true)
      expect(isOwner(1, '1')).toBe(true)
      expect(isOwner('42', 42)).toBe(true)
      expect(isOwner('999999', 999999)).toBe(true)
    })

    it('should not match when string ID differs from numeric ID', () => {
      expect(isOwner('1', 2)).toBe(false)
      expect(isOwner('42', 43)).toBe(false)
    })
  })

  describe('String vs String', () => {
    it('should match when both strings represent same number', () => {
      expect(isOwner('1', '1')).toBe(true)
      expect(isOwner('42', '42')).toBe(true)
    })

    it('should not match when strings represent different numbers', () => {
      expect(isOwner('1', '2')).toBe(false)
    })
  })

  describe('BigInt vs Number (SQLite better-sqlite3 scenario)', () => {
    it('should match when BigInt equals Number', () => {
      expect(isOwner(BigInt(1), 1)).toBe(true)
      expect(isOwner(1, BigInt(1))).toBe(true)
      expect(isOwner(BigInt(42), 42)).toBe(true)
      expect(isOwner(BigInt(999999), 999999)).toBe(true)
    })

    it('should not match when BigInt differs from Number', () => {
      expect(isOwner(BigInt(1), 2)).toBe(false)
      expect(isOwner(BigInt(42), 43)).toBe(false)
    })
  })

  describe('BigInt vs String', () => {
    it('should match when BigInt equals String representation', () => {
      expect(isOwner(BigInt(1), '1')).toBe(true)
      expect(isOwner('1', BigInt(1))).toBe(true)
      expect(isOwner(BigInt(42), '42')).toBe(true)
    })
  })

  describe('BigInt vs BigInt', () => {
    it('should match when both BigInts are equal', () => {
      expect(isOwner(BigInt(1), BigInt(1))).toBe(true)
      expect(isOwner(BigInt(42), BigInt(42))).toBe(true)
    })

    it('should not match when BigInts differ', () => {
      expect(isOwner(BigInt(1), BigInt(2))).toBe(false)
    })
  })

  describe('Null/Undefined handling (unauthenticated users)', () => {
    it('should return false when userId is null', () => {
      expect(isOwner(null, 1)).toBe(false)
      expect(isOwner(null, '1')).toBe(false)
      expect(isOwner(null, BigInt(1))).toBe(false)
    })

    it('should return false when userId is undefined', () => {
      expect(isOwner(undefined, 1)).toBe(false)
      expect(isOwner(undefined, '1')).toBe(false)
    })

    it('should handle null campaignUserId gracefully', () => {
      // This shouldn't happen in practice, but should not throw
      expect(isOwner(1, null)).toBe(false)
      expect(isOwner(1, undefined)).toBe(false)
    })
  })

  describe('Edge cases', () => {
    it('should handle zero IDs', () => {
      expect(isOwner(0, 0)).toBe(true)
      expect(isOwner('0', 0)).toBe(true)
      expect(isOwner(0, '0')).toBe(true)
    })

    it('should handle large IDs', () => {
      const largeId = 9007199254740991 // Number.MAX_SAFE_INTEGER
      expect(isOwner(largeId, largeId)).toBe(true)
      expect(isOwner(String(largeId), largeId)).toBe(true)
    })

    it('should not match with NaN-producing values', () => {
      expect(isOwner('abc', 1)).toBe(false)
      expect(isOwner(1, 'abc')).toBe(false)
      expect(isOwner('abc', 'abc')).toBe(false) // NaN !== NaN
    })
  })
})

describe('Original Bug Reproduction', () => {
  it('demonstrates the original bug with strict equality', () => {
    // This is what the OLD code did - strict equality fails with type mismatch
    const userId = 1          // Number from auth context
    const campaignUserId = '1' // String from API/URL params
    
    // OLD behavior (broken):
    expect(userId === campaignUserId).toBe(false) // BUG!
    
    // NEW behavior (fixed):
    expect(isOwner(userId, campaignUserId)).toBe(true) // FIXED!
  })

  it('demonstrates BigInt mismatch from SQLite', () => {
    // better-sqlite3 can return BigInt for INTEGER columns
    const userId = 1              // Number from JWT decode
    const campaignUserId = BigInt(1) // BigInt from SQLite
    
    // OLD behavior (broken):
    expect(userId === campaignUserId).toBe(false) // BUG!
    
    // NEW behavior (fixed):
    expect(isOwner(userId, campaignUserId)).toBe(true) // FIXED!
  })
})

