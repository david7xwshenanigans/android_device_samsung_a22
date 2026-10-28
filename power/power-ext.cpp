#include <aidl/android/hardware/power/Mode.h>
#include <android-base/file.h>
#include <android-base/logging.h>

namespace aidl {
namespace google {
namespace hardware {
namespace power {
namespace impl {
namespace pixel {

using ::aidl::android::hardware::power::Mode;

namespace{
    bool writeNode(const char* path, const char* value) {
        if (!::android::base::WriteStringToFile(value, path)) {
            PLOG(ERROR) << "power-ext: write '" << value << "' to " << path << " failed";
            return false;
        }
        LOG(INFO) << "power-ext: wrote '" << value << "' to " << path;
        return true;
    }
}

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
    if (type == Mode::DOUBLE_TAP_TO_WAKE) {
        writeNode("/sys/class/sec/tsp/cmd", enabled ? "aot_enable,1" : "aot_enable,0");
        return true;
    }

    if (type == Mode::INTERACTIVE) {
        writeNode("/sys/class/sec/tsp/input/enabled", enabled ? "1" : "0");
        return true;
    }

    return false;
}


}
}
}
}
}
}