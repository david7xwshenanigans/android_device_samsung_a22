#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=a22
VENDOR=samsung

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${PWD}/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup {
    case "$1" in
        vendor/lib64/libcodec2_hidl@1.0.so)
            "${PATCHELF}" --replace-needed "libstagefright_bufferqueue_helper.so" "libstagefright_bufferqueue_helper-v31.so" "${2}"
            ;;
        vendor/bin/hw/samsung.software.media.c2@1.0-service)
            "${PATCHELF}" --replace-needed "libstagefright_bufferqueue_helper.so" "libstagefright_bufferqueue_helper-v31.so" "${2}"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib64/vendor.samsung.hardware.light-V1-ndk_platform.so)
            "$PATCHELF" --replace-needed "android.hardware.light-V1-ndk_platform.so" "android.hardware.light-V1-ndk.so" "${2}"
            ;;
        vendor/bin/hw/vendor.samsung.hardware.light-service)
            "$PATCHELF" --replace-needed "android.hardware.light-V1-ndk_platform.so" "android.hardware.light-V1-ndk.so" "${2}"
            ;;
        vendor/lib64/nfc_nci_nxpsn.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib/libnvram.so|vendor/lib/libsysenv.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib64/libnvram.so|vendor/lib64/libsysenv.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.neuralnetworks@1.3-service-mtk-neuron)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        # Fix GraphicBufferMapper symbols for Media Codecs
        vendor/lib*/libcodec2_vndk.so)
            "${PATCHELF}" --add-needed "libui_shim.so" "${2}"
            ;;
        # Fix GraphicBufferMapper symbols for Camera UniHAL
        vendor/lib64/unihal_main@2.1.so)
            "${PATCHELF}" --add-needed "libui_shim.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.media.c2@1.2-mediatek|vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b)
           "${PATCHELF}" --add-needed "libstagefright_foundation-v33.so" "${2}"
           "${PATCHELF}" --add-needed "libgraphicbuffersource_shim.so" "${2}"
           "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.sensors@2.0-service.multihal)
            "$PATCHELF" --replace-needed libutils.so libutils-v32.so "$2"
            ;;
        vendor/bin/hw/android.hardware.wifi@1.0-service-lazy | vendor/bin/hw/vendor.samsung.hardware.wifi@2.0-service)
            "$PATCHELF" --replace-needed "libwifi-hal.so" "libwifi-hal-mtk.so" "${2}"
            ;;
        vendor/bin/hw/vendor.samsung.hardware.camera.provider@4.0-service_64)
            "$PATCHELF" --replace-needed libbinder.so libbinder-v31.so "${2}"
            "$PATCHELF" --replace-needed libhidlbase.so libhidlbase-v31.so "${2}"
            "$PATCHELF" --replace-needed libutils.so libutils-v31.so "$2"
            ;;
        vendor/bin/hw/vendor.samsung.hardware.hyper-service)
            "$PATCHELF" --replace-needed liblog.so liblog-v31.so "${2}"
            ;;
        vendor/lib64/libwifi-hal-mtk.so)
            "$PATCHELF" --set-soname libwifi-hal-mtk.so "${2}"
            ;;
        vendor/lib*/sensors.inputvirtual.so|vendor/lib*/sensors.sensorhub.so)
            "$PATCHELF" --replace-needed libutils.so libutils-v31.so "$2"
            ;;
        vendor/bin/hw/vendor.mediatek.hardware.mtkpower@1.0-service)
            "$PATCHELF" --replace-needed "android.hardware.power-V2-ndk_platform.so" "android.hardware.power-V2-ndk.so" "${2}"
            ;;
        vendor/bin/hw/vendor.samsung.hardware.vibrator-service)
            "$PATCHELF" --replace-needed "android.hardware.vibrator-V2-ndk_platform.so" "android.hardware.vibrator-V2-ndk.so" "${2}"
            ;;
        vendor/lib64/vendor.samsung.hardware.vibrator-V5-ndk_platform.so)
            "$PATCHELF" --replace-needed "android.hardware.vibrator-V2-ndk_platform.so" "android.hardware.vibrator-V2-ndk.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
