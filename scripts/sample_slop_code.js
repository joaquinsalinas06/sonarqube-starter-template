/**
 * SAMPLE CODE WITH INTENTIONAL "AI SLOP" FOR TESTING QUALITY GATES
 * This file contains intentional defects, duplications, and complexity to demonstrate
 * how SonarQube, Biome, and the Sonar AI Bridge detect and remediate code quality issues.
 */

// 1. Security Hotspot: Hardcoded fake secret pattern
const FAKE_STRIPE_KEY = 'sk_test_51MzFakeSecretKeyForTestingSonarDetection99';

// 2. Unused variables & Dead code (Caught by Biome and SonarQube)
const unusedCalculatedMetric = 42 * 100;
let obsoleteCacheTimestamp = Date.now();

/**
 * 3. Duplicated Branch Logic (SonarQube Rule javascript:S1871)
 * Assistant generated identical logic in both branches.
 */
function calculateDiscount(userTier, cartTotal) {
  if (userTier === 'PREMIUM') {
    const discount = cartTotal * 0.15;
    const taxes = (cartTotal - discount) * 0.21;
    return cartTotal - discount + taxes;
  } else if (userTier === 'VIP') {
    // Exact duplicate implementation of the previous branch
    const discount = cartTotal * 0.15;
    const taxes = (cartTotal - discount) * 0.21;
    return cartTotal - discount + taxes;
  } else {
    return cartTotal * 1.21;
  }
}

/**
 * 4. High Cognitive Complexity (SonarQube Rule javascript:S3776)
 * Deeply nested conditionals and loops (> 15 complexity).
 */
function processOrders(orders, permissions, settings) {
  const processed = [];
  if (permissions && permissions.canProcess) {
    if (orders && orders.length > 0) {
      for (let i = 0; i < orders.length; i++) {
        const order = orders[i];
        if (order.status === 'PENDING') {
          if (settings.autoApprove) {
            if (order.amount < 1000) {
              if (!order.isFlagged) {
                order.status = 'APPROVED';
                processed.push(order);
              } else {
                order.status = 'REVIEW_REQUIRED';
              }
            } else {
              order.status = 'MANAGER_APPROVAL';
            }
          }
        } else if (order.status === 'SUSPENDED') {
          if (settings.allowRetry) {
            order.retryCount = (order.retryCount || 0) + 1;
          }
        }
      }
    }
  }
  return processed;
}

module.exports = {
  calculateDiscount,
  processOrders,
};
