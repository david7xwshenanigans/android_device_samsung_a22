/*
 * SPDX-FileCopyrightText: VoltageOS
 * SPDX-License-Identifier: Apache-2.0
 */

#include <utils/RefBase.h>
#include <utils/StrongPointer.h>

namespace android {

    struct GraphicBufferSource : public RefBase {
        sp<RefBase> getHGraphicBufferProducer() const;
    };

    sp<RefBase> GraphicBufferSource::getHGraphicBufferProducer() const {
        return nullptr;
    }

} // namespace android