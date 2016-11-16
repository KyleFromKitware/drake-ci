# TODO move to site.cmake when subprojects arrive
set(DASHBOARD_SUPERBUILD_PROJECT_NAME "drake-superbuild")

set(CTEST_BUILD_NAME "${DASHBOARD_BUILD_NAME}-download-cpplint")
set(CTEST_PROJECT_NAME "${DASHBOARD_SUPERBUILD_PROJECT_NAME}")
set(CTEST_NIGHTLY_START_TIME "${DASHBOARD_NIGHTLY_START_TIME}")
set(CTEST_DROP_METHOD "https")
set(CTEST_DROP_SITE "${DASHBOARD_CDASH_SERVER}")
set(CTEST_DROP_LOCATION
  "/submit.php?project=${DASHBOARD_SUPERBUILD_PROJECT_NAME}")
set(CTEST_DROP_SITE_CDASH ON)

notice("CTest Status: DOWNLOADING GOOGLE_STYLEGUIDE")

ctest_start("${DASHBOARD_MODEL}" TRACK "${DASHBOARD_TRACK}" QUIET)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}"
  RETURN_VALUE DASHBOARD_SUPERBUILD_UPDATE_RETURN_VALUE QUIET)

# Configure superbuild
ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}"
  SOURCE "${CTEST_SOURCE_DIRECTORY}"
  RETURN_VALUE DASHBOARD_SUPERBUILD_CONFIGURE_RETURN_VALUE QUIET)
if(NOT DASHBOARD_SUPERBUILD_CONFIGURE_RETURN_VALUE EQUAL 0)
  set(DASHBOARD_FAILURE ON)
  list(APPEND DASHBOARD_FAILURES "CONFIGURE SUPERBUILD")
endif()

# Download google_styleguide (superbuild "build" step)
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" APPEND
  TARGET "google_styleguide-update"
  RETURN_VALUE DASHBOARD_SUPERBUILD_DOWNLOAD_RETURN_VALUE QUIET)
if(NOT DASHBOARD_SUPERBUILD_DOWNLOAD_RETURN_VALUE EQUAL 0)
  set(DASHBOARD_FAILURE ON)
  list(APPEND DASHBOARD_FAILURES "DOWNLOAD SUPERBUILD")
endif()
ctest_submit(RETRY_COUNT 4 RETRY_DELAY 15
  RETURN_VALUE DASHBOARD_SUPERBUILD_SUBMIT_RETURN_VALUE QUIET)

# Submit results of superbuild
set(DASHBOARD_BUILD_URL_FILE
  "${CTEST_BINARY_DIRECTORY}/${DASHBOARD_BUILD_NAME}.url")
file(WRITE "${DASHBOARD_BUILD_URL_FILE}" "$ENV{BUILD_URL}")
ctest_upload(FILES "${DASHBOARD_BUILD_URL_FILE}" QUIET)

ctest_submit(RETRY_COUNT 4 RETRY_DELAY 15
  RETURN_VALUE DASHBOARD_SUPERBUILD_SUBMIT_RETURN_VALUE QUIET)

set(DASHBOARD_SUPERBUILD_FAILURE ${DASHBOARD_FAILURE})