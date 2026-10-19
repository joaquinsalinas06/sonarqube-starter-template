"""
Sample Python file with intentional "AI Slop" patterns.
Demonstrates how Ruff, AI-SLOP-Detector, and SonarQube detect:
1. Swallowed exceptions (except Exception: pass)
2. Duplicated branch logic
3. Excessive cognitive complexity (>15)
4. Ghost imports and unused variables
5. Fake-finished placeholder stubs
"""

import os
import sys
import json
import time  # Ghost import: never used

# 1. Unused variable / Dead code
UNUSED_API_SECRET = "sk_live_fake_ai_generated_placeholder_key_9999"

# 2. Fake-finished placeholder stub (AI-Slop flag)
def sync_third_party_crm(payload: dict) -> bool:
    """Syncs customer data to CRM system. (TODO: Add implementation)."""
    # AI assistant generated docstring and signature, but left an empty stub
    pass


# 3. Duplicate branch implementation & Swallowed exception
def calculate_membership_fee(tier: str, base_price: float) -> float:
    # Meaningless comment: Loop through nothing
    try:
        if tier == "PREMIUM":
            discount = base_price * 0.15
            tax = (base_price - discount) * 0.21
            return base_price - discount + tax
        elif tier == "VIP":
            # Exact duplicate implementation of the PREMIUM branch
            discount = base_price * 0.15
            tax = (base_price - discount) * 0.21
            return base_price - discount + tax
        else:
            return base_price * 1.21
    except Exception:
        # Dangerous AI Slop: Swallows all exceptions silently without logging
        pass
    return 0.0


# 4. High Cognitive / Cyclomatic Complexity (> 15)
def dispatch_event(event_type: str, data: dict, user_context: dict, config: dict) -> list:
    results = []
    if user_context and user_context.get("is_authenticated"):
        if config and config.get("enabled"):
            if data and len(data) > 0:
                for key, value in data.items():
                    if event_type == "ORDER_CREATED":
                        if value.get("amount", 0) > 100:
                            if not value.get("flagged"):
                                if user_context.get("tier") == "GOLD":
                                    results.append({"status": "INSTANT_APPROVE", "id": key})
                                else:
                                    results.append({"status": "STANDARD_QUEUE", "id": key})
                            else:
                                results.append({"status": "FLAGGED_FOR_FRAUD", "id": key})
                        else:
                            results.append({"status": "LOW_VALUE", "id": key})
                    elif event_type == "ORDER_CANCELLED":
                        if config.get("allow_cancellations"):
                            results.append({"status": "CANCELLED_OK", "id": key})
    return results
