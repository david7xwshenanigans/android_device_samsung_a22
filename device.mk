#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Installs gsi keys into ramdisk, to boot a developer GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@7.0-util.vendor \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.audio.effect@7.0-impl \
    libaudioclient_aidl_conversion \
    libaudiofoundation.vendor \
    libbluetooth_audio_session \
    spatializer-aidl-cpp.vendor

PRODUCT_PACKAGES += \
    audio.bluetooth.default \
    audio.primary.default \
    audio.r_submix.default \
    audio.usb.default \
    audio_policy.stub

PRODUCT_PACKAGES += \
    libalsautils \
    libdynproc \
    libhapticgenerator \
    libtinycompress \
    libnbaio_mono

PRODUCT_PACKAGES += \
    libstagefright_bufferpool@2.0.1.vendor \
    libstagefright_foundation

PRODUCT_PACKAGES += \
    android.hardware.soundtrigger@2.0-impl \
    android.hardware.soundtrigger@2.3.vendor

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio@2.0-impl \
    android.hardware.bluetooth.audio@2.1-impl \
    android.hardware.bluetooth@1.1.vendor

# CAS
PRODUCT_PACKAGES += \
    android.hardware.cas@1.2-service-lazy

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0.vendor \
    android.hardware.graphics.allocator@4.0.vendor \
    android.hardware.graphics.common@1.2.vendor \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.mapper@2.1.vendor \
    android.hardware.graphics.mapper@3.0.vendor \
    android.hardware.graphics.mapper@4.0.vendor

PRODUCT_PACKAGES += \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service

PRODUCT_PACKAGES += \
    libgrallocusage.vendor

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.4-service.clearkey \
    android.hardware.drm@1.4.vendor \
    libdrm.vendor\
    libmockdrmcryptoplugin

# Dumpstate
PRODUCT_PACKAGES += \
    android.hardware.dumpstate@1.1.vendor:64

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1.vendor

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# GPS
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.1.vendor \
    android.hardware.gnss@2.1.vendor \
    android.hardware.gnss.measurement_corrections@1.1.vendor \
    android.hardware.gnss.visibility_control@1.0.vendor

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# HIDL
PRODUCT_PACKAGES += \
    libhidltransport \
    libhidltransport.vendor \
    libhwbinder \
    libhwbinder.vendor

# Keymaster
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0-service \
    libkeymaster4_1support.vendor \
    libpuresoftkeymasterdevice.vendor

PRODUCT_PACKAGES += \
    libkeystore-wifi-hidl \
    libkeystore-engine-wifi-hidl

# Media
PRODUCT_PACKAGES += \
    android.hardware.media.c2@1.2.vendor \
    libavservices_minijail_vendor \
    libcodec2_hidl@1.2.vendor \
    libcodec2_soft_common.vendor
    libsfplugin_ccodec_utils.vendor \
    libstagefright_softomx_plugin.vendor

# Neural Networks
PRODUCT_PACKAGES += \
    android.hardware.neuralnetworks@1.3.vendor \
    libtextclassifier_hash.vendor

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc@1.2.vendor

# fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Power
PRODUCT_PACKAGES += \
    android.hardware.power@1.2.vendor

# Radio
PRODUCT_PACKAGES += \
    android.hardware.radio.config@1.2.vendor \
    android.hardware.radio.deprecated@1.0.vendor \
    android.hardware.radio@1.6.vendor

# RenderScript
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# Sensors
PRODUCT_PACKAGES += \
    android.frameworks.sensorservice@1.0.vendor \
    android.hardware.sensors@1.0.vendor \
    android.hardware.sensors@2.0-ScopedWakelock.vendor \
    android.hardware.sensors@2.1.vendor

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sensors/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 30

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb@1.3.vendor

# Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.tetheroffload.config@1.0.vendor \
    android.hardware.tetheroffload.control@1.1.vendor \
    android.hardware.wifi.hostapd@1.3.vendor \
    android.hardware.wifi.supplicant@1.4.vendor \
    android.hardware.wifi@1.5.vendor

# Inherit the proprietary files
$(call inherit-product, vendor/samsung/a22/a22-vendor.mk)
