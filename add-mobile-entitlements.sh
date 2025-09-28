#!/bin/bash

# Add MobileEntitlements property to Auth.swift
AUTH_FILE="KindeManagementAPI/Sources/KindeSDK/Auth/Auth.swift"

if [ -f "$AUTH_FILE" ]; then
    echo "Adding MobileEntitlements property to Auth.swift..."
    
    # Add the MobileEntitlements property after the claims property
    sed -i '' '/public lazy var claims: ClaimsService = ClaimsService(auth: self, logger: logger)/a\
    \
    /// Mobile entitlements system for client-side validation\
    public lazy var entitlements: MobileEntitlements = MobileEntitlements(auth: self, logger: logger)\
' "$AUTH_FILE"
    
    echo "✅ MobileEntitlements property added to Auth.swift"
else
    echo "❌ Auth.swift file not found at $AUTH_FILE"
    exit 1
fi
