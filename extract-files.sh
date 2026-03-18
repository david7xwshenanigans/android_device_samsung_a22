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

function blob_fixup() {
    case "${1}" in

        # =====================================================================
        # Generic Fixups
        # =====================================================================

        vendor/lib64/vendor.samsung.hardware.light-V1-ndk_platform.so)
            "$PATCHELF" --replace-needed "android.hardware.light-V1-ndk_platform.so" "android.hardware.light-V1-ndk.so" "${2}"
            ;;
        vendor/bin/hw/vendor.samsung.hardware.light-service)
            "$PATCHELF" --replace-needed "android.hardware.light-V1-ndk_platform.so" "android.hardware.light-V1-ndk.so" "${2}"
            ;;
        vendor/lib64/nfc_nci_nxpsn.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib/libnvram.so|vendor/lib64/libnvram.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib/libsysenv.so|vendor/lib64/libsysenv.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.neuralnetworks@1.3-service-mtk-neuron)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib64/unihal_main@2.1.so)
            "${PATCHELF}" --add-needed "libui_shim.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.sensors@2.0-service.multihal)
            "$PATCHELF" --replace-needed libutils.so libutils-v32.so "$2"
            ;;
        vendor/bin/hw/android.hardware.wifi@1.0-service-lazy|vendor/bin/hw/vendor.samsung.hardware.wifi@2.0-service)
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
        vendor/lib/sensors.inputvirtual.so|vendor/lib64/sensors.inputvirtual.so)
            "$PATCHELF" --replace-needed libutils.so libutils-v31.so "$2"
            ;;
        vendor/lib/sensors.sensorhub.so|vendor/lib64/sensors.sensorhub.so)
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
        # =====================================================================
        # Codec2: SONAME and Internal Dependencies
        # =====================================================================
        vendor/etc/init/android.hardware.media.c2@1.2-mediatek.rc)
            sed -i 's|/vendor/bin/hw/android.hardware.media.c2@1.2-mediatek|/vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b|g' "${2}"
            ;;
        vendor/lib/libcodec2_a13.so|vendor/lib64/libcodec2_a13.so)
            "${PATCHELF}" --set-soname "libcodec2_a13.so" "${2}"
            ;;
        vendor/lib/libcodec2_vndk_a13.so|vendor/lib64/libcodec2_vndk_a13.so)
            "${PATCHELF}" --set-soname "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33-a22.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --add-needed "libui_c2_mtk_shim.so" "${2}"
            ;;
        vendor/lib/libcodec2_hidl_plugin_a13.so|vendor/lib64/libcodec2_hidl_plugin_a13.so)
            "${PATCHELF}" --set-soname "libcodec2_hidl_plugin_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            ;;
        vendor/lib/libcodec2_hidl_a13@1.0.so|vendor/lib64/libcodec2_hidl_a13@1.0.so)
            "${PATCHELF}" --set-soname "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl_plugin.so" "libcodec2_hidl_plugin_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_bufferqueue_helper.so" "libstagefright_bufferqueue_helper-v31.so" "${2}"
            ;;
        vendor/lib/libcodec2_hidl_a13@1.1.so|vendor/lib64/libcodec2_hidl_a13@1.1.so)
            "${PATCHELF}" --set-soname "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl_plugin.so" "libcodec2_hidl_plugin_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_bufferqueue_helper.so" "libstagefright_bufferqueue_helper-v31.so" "${2}"
            ;;
        vendor/lib/libcodec2_hidl_a13@1.2.so|vendor/lib64/libcodec2_hidl_a13@1.2.so)
            "${PATCHELF}" --set-soname "libcodec2_hidl_a13@1.2.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl_plugin.so" "libcodec2_hidl_plugin_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_bufferqueue_helper.so" "libstagefright_bufferqueue_helper-v31.so" "${2}"
            ;;

        # =====================================================================
        # Codec2: Repoint Executable Shared Libs
        # =====================================================================

        vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --add-needed "libstagefright_foundation-v33-a22.so" "${2}"
            "${PATCHELF}" --add-needed "libgraphicbuffersource_shim.so" "${2}"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            "${PATCHELF}" --add-needed "libui_c2_mtk_shim.so" "${2}"
            llvm-objcopy --remove-section=.note.android.ident "${2}"
            ;;
        vendor/bin/hw/samsung.software.media.c2@1.0-service)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_bufferqueue_helper.so" "libstagefright_bufferqueue_helper-v31.so" "${2}"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;

        # =====================================================================
        # Codec2: Repoint Proprietary MTK and Soft Codec blobs
        # =====================================================================

        vendor/lib/libcodec2_mtk_vdec.so|vendor/lib64/libcodec2_mtk_vdec.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33-a22.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            "${PATCHELF}" --add-needed "libui_c2_mtk_shim.so" "${2}"
            ;;
        vendor/lib/libcodec2_mtk_venc.so|vendor/lib64/libcodec2_mtk_venc.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33-a22.so" "${2}"
            "${PATCHELF}" --add-needed "libui_c2_mtk_shim.so" "${2}";
            ;;
        vendor/lib/libcodec2_mtk_c2store.so|vendor/lib64/libcodec2_mtk_c2store.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libui.so" "libui-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33-a22.so" "${2}"
            "${PATCHELF}" --add-needed "libui_c2_mtk_shim.so" "${2}";
            ;;
        vendor/lib/libcodec2_soft_common.so|vendor/lib64/libcodec2_soft_common.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
        vendor/lib/libcodec2_soft_mtk_imaadpcmdec.so|vendor/lib64/libcodec2_soft_mtk_imaadpcmdec.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
        vendor/lib/libcodec2_soft_mtk_mp3dec.so|vendor/lib64/libcodec2_soft_mtk_mp3dec.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
        vendor/lib/libcodec2_soft_mtk_msadpcmdec.so|vendor/lib64/libcodec2_soft_mtk_msadpcmdec.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
        vendor/lib/libcodec2_vpp_qt_plugin.so|vendor/lib64/libcodec2_vpp_qt_plugin.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
        vendor/lib/libcodec2_vpp_rs_plugin.so|vendor/lib64/libcodec2_vpp_rs_plugin.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
        vendor/lib64/libSecC2ComponentStore.so|vendor/lib64/libcodec2_soft_ac4dec.so|vendor/lib64/libcodec2_soft_eac3dec.so)
            "${PATCHELF}" --replace-needed "libcodec2.so" "libcodec2_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk_a13.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.0.so" "libcodec2_hidl_a13@1.0.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.1.so" "libcodec2_hidl_a13@1.1.so" "${2}"
            "${PATCHELF}" --replace-needed "libcodec2_hidl@1.2.so" "libcodec2_hidl_a13@1.2.so" "${2}"
            ;;
            #####################################################################
            # Codec2: End Codec2 Patchelf
            #####################################################################

    esac
}
# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
