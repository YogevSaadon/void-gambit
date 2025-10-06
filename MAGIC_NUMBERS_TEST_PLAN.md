# COMPLETE MAGIC NUMBERS REFACTORING TEST PLAN

## **WHAT WAS CHANGED**
All magic numbers extracted from codebase to 12 constant files:
- ✅ **CombatConstants.gd** - Damage multipliers (0.33, 1.5, 0.05, etc.)
- ✅ **EnemyConstants.gd** - All enemy base stats (health, speed, damage)
- ✅ **MovementConstants.gd** - Player/enemy movement values
- ✅ **WeaponConstants.gd** - Fire rates, projectile speeds, ranges
- ✅ **UIConstants.gd** - Flash timings, damage number behavior
- ✅ **DropConstants.gd** - Pickup magnetism, drop values
- ✅ **SpawningConstants.gd** - Wave management, power budgets
- ✅ **StatusConstants.gd** - Infection ticks, stack limits
- ✅ **PerformanceConstants.gd** - Query limits, timer intervals
- ✅ **CollisionLayers.gd** - Cleaned up collision system
- ✅ **ProjectileConstants.gd** - Bullet speeds, lifetimes, explosions
- ✅ **VisualConstants.gd** - Colors, particle effects, flash timings

---

## **CRITICAL TESTS - MUST PASS**

### **1. COLLISION SYSTEM** ✅ (Already tested)
- [x] Player bullets hit enemies
- [x] Enemy bullets hit player  
- [x] No collision errors on startup

### **2. DAMAGE BALANCE** 
- [ ] **Base weapon damage = 20** (unchanged)
- [ ] **Rocket explosions = 30** (20 × 1.5)
- [ ] **Laser ticks = 1** (20 × 0.05)
- [ ] **Bio DPS = 7** (20 ÷ 3.0)
- [ ] **Ship weapons = ~7 damage** (20 × 0.33)

### **3. ENEMY HEALTH & BEHAVIOR**
Test each enemy type has correct stats:
- [ ] **Biter: 20 HP, 120 speed, 12 damage**
- [ ] **Triangle: 40 HP, 100 speed, 15 damage**
- [ ] **Star: 200 HP, 80 speed, 25 damage**
- [ ] **Tank: 80 HP, 85 speed, 20 damage** + charge behavior
- [ ] **MotherShip: 400 HP, 45 speed, 40 damage**

### **4. PROJECTILE SPEEDS**
- [ ] **Player bullets: 1800 speed** (fast)
- [ ] **Enemy bullets: 400 speed** (slower) 
- [ ] **Missiles: 450 speed** (tracking)
- [ ] **Bullet lifetimes: 2-3 seconds**

### **5. MOVEMENT & RANGES**
- [ ] **Player movement feels identical**
- [ ] **Enemy chase ranges work** (250-400 units)
- [ ] **Sawblade enemies orbit correctly**
- [ ] **Tank charge attacks work**

---

## **FUNCTIONALITY TESTS**

### **6. WEAPON SYSTEMS**
- [ ] **All weapon types fire correctly** (Bullet, Laser, Rocket, Bio)
- [ ] **Ship weapons spawn and function**
- [ ] **Weapon upgrades apply properly**
- [ ] **Critical hits work**

### **7. STATUS EFFECTS**
- [ ] **Bio weapon applies infection**
- [ ] **Infection stacks up to 3** with 33% damage increase per stack
- [ ] **DoT ticks every 0.5 seconds**

### **8. UI & VISUAL**
- [ ] **Damage numbers appear/fade correctly**
- [ ] **Attack flashes look the same**
- [ ] **Explosion colors unchanged**
- [ ] **UI animations smooth**

### **9. DROPS & ECONOMY**
- [ ] **Coin magnetism works** (120 unit radius)
- [ ] **Drop collection feels smooth**
- [ ] **Credit values correct** (4x multiplier)

### **10. SPAWNING & WAVES**
- [ ] **Waves last ~60 seconds**
- [ ] **Enemy spawning feels natural**
- [ ] **Golden ships appear mid-wave**
- [ ] **Difficulty progression works**

---

## **PERFORMANCE TESTS**

### **11. NO REGRESSIONS**
- [ ] **Game starts without errors**
- [ ] **No frame drops during combat**
- [ ] **Memory usage unchanged**
- [ ] **All animations smooth**

### **12. PHYSICS QUERIES**
- [ ] **Laser targeting works** (32 result limit)
- [ ] **Ship targeting works**
- [ ] **Bio spread targeting works** (5 target limit)

---

## **QUICK SMOKE TEST SEQUENCE**
1. **Start game** - No console errors
2. **Play Wave 1-2** with all weapon types
3. **Check damage numbers** match expected values
4. **Test all enemy types** appear and behave correctly
5. **Verify UI/visual effects** unchanged
6. **Test ship weapons** and status effects
7. **Check drop collection** and economy

---

## **ROLLBACK PLAN**
If ANY test fails:
1. Git revert to commit before magic number extraction
2. Fix the specific constant causing issues
3. Re-test only that system
4. Commit individual fixes

---

**All constants are now centralized and maintainable! 🎯**
