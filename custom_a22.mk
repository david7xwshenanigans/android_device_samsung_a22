# SPDX-License-Identifier: Apache-2.0


# Inherit some common PixelOS stuff.
$(call inherit-product, vendor/custom/config/common_full_phone.mk)

# Inherit common a22 device config
$(call inherit-product, device/samsung/a22/common_a22.mk)

PRODUCT_NAME := custom_a22