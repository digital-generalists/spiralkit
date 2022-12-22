#
# Copyright 2015 Digital Generalists, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


rm -rf ${OUTPUT_PACKAGE_DIR}
rm -rf ${OUTPUT_DELIVERY_DIR}
mkdir -p ${OUTPUT_DELIVERY_DIR}

cp -r ${BUILD_DIR}/${OUTPUT_CONFIGURATION_NAME}-iphonesimulator ${OUTPUT_PACKAGE_DIR}

SIMULATOR_BUILD_ARCH=$(lipo "${BUILD_DIR}/${OUTPUT_CONFIGURATION_NAME}-iphonesimulator/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" -archs)
DEVICE_BUILD_ARCH=$(lipo "${BUILD_DIR}/${OUTPUT_CONFIGURATION_NAME}-iphoneos/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" -archs)

if [ "$DEVICE_BUILD_ARCH" == "$SIMULATOR_BUILD_ARCH" ]
then
    echo Creating universal binary with multiple architectures.
    rm ${OUTPUT_PACKAGE_DIR}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}
    lipo -create -output "${OUTPUT_PACKAGE_DIR}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${OUTPUT_CONFIGURATION_NAME}-iphonesimulator/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${OUTPUT_CONFIGURATION_NAME}-iphoneos/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
else
    echo Device and simulator architectures match.  Returning unmodified simulator build.
fi

mv ${OUTPUT_PACKAGE_DIR} ${OUTPUT_DELIVERY_DIR}/${OUTPUT_PACKAGE_NAME}
