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

# Restoring a previous configuration after a build operation can be a problematic task.  There are
# several approaches one can take:
# - restore the configuration file from source control:  Generally works well in automated environments but
#      tends to break down for developer configurations because the developer may have made configuration
#      modifications without committing those changes.  Any changes to the configuration of that nature
#      will be lost when the SCM version of the configuration is restored.
# - retain a snapshot of the configuration prior to the build and restore that after the build:  This
#      sounds simple, but is usually fraught with problems "in the wild".  The build tool becomes responsible
#      for caching the config, restoring it, and verifying integrity; each of which is a potential point
#      of failure.  Every non-Happy Path build operation will almost certainly put the system in an
#      unanticipated state in these types of configurations.  These states require the system to essentially
#      read the developer's mind about what is correct and what is left-over garbage.  No matter how good the
#      algorithm, the system will make an incorrect decision at some point.
# - retain a snapshot of only the changed values:  This is generally pretty safe, but suffers from many of the
#      same headaches as the full-configuration snapshot option mentioned above but just on a more isolated
#      scale.  Additionally, the tooling required to make such a scheme work is a significant investment in a
#      solution that will likely only perform marginally well at best.
#
# None of these approaches seemed appropriate for a publicly-released framework.  Therefore, the solution I've
# adopted is to simply restore the default settings after a build.  This is largely palatable because SpiralKit
# only modifies the build number on a build operation, which is a low-risk setting to over-write.
#
# If you hate how this works in your developer workflow, simply disable this script from the build schemes and
# adjust however works for you.  Any suggestions on a better approach are appreciated.

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion DEVBUILD" ${PROJECT_DIR}/${PROJECT_NAME}/Info.plist
