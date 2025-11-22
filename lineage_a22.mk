#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from a22 device
$(call inherit-product, device/samsung/a22/device.mk)

PRODUCT_DEVICE := a22
PRODUCT_NAME := lineage_a22
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A225F
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung-ss

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a22nsxx-user 13 TP1A.220624.014 A225FXXSBDYE1 release-keys"

BUILD_FINGERPRINT := samsung/a22nsxx/a22:13/TP1A.220624.014/A225FXXSBDYE1:user/release-keys
