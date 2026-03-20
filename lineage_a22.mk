#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit common a22 device config
$(call inherit-product, device/samsung/a22/common_a22.mk)

PRODUCT_NAME := lineage_a22