#include <aidl/android/hardware/power/Mode.h>
#include <android-base/file.h>

namespace aidl {
namespace android {
namespace hardware {
namespace power {
namespace impl {
namespace mediatek {

bool isDeviceSpecificModeSupported(Mode type, bool* ret) {
    if (type != Mode::DOUBLE_TAP_TO_WAKE) return false;
    *ret = true;
    return true;
}

bool setDeviceSpecificMode(Mode type, bool enabled) {
    using ::android::base::WriteStringToFile;

    if (type == Mode::DOUBLE_TAP_TO_WAKE) {
        WriteStringToFile(enabled ? "aot_enable,1" : "aot_enable,0", "/sys/class/sec/tsp/cmd");
        return true;
    }

    if (type == Mode::INTERACTIVE) {
        WriteStringToFile(enabled ? "1" : "0", "/sys/class/sec/tsp/input/enabled");
    }

    return false;
}

}
}
}
}
}
}