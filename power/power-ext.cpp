#include <aidl/android/hardware/power/Mode.h>
#include <android-base/file.h>

namespace aidl {
namespace google {
namespace hardware {
namespace power {
namespace impl {
namespace pixel {

using ::aidl::android::hardware::power::Mode;

bool isDeviceSpecificModeSupported(Mode type, bool* ret) {
    switch (type) {
        case Mode::DOUBLE_TAP_TO_WAKE:
        case Mode::INTERACTIVE:
            *ret = true;
            return true;
        default:
            return false;
    }
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