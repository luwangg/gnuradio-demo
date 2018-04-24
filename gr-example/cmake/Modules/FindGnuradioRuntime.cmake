INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_GNURADIO_RUNTIME gnuradio-runtime)

if(PC_GNURADIO_RUNTIME_FOUND)
  # look for include files
  FIND_PATH(
    GNURADIO_RUNTIME_INCLUDE_DIRS
    NAMES gnuradio/top_block.h
    HINTS $ENV{GNURADIO_RUNTIME_DIR}/include
          ${PC_GNURADIO_RUNTIME_INCLUDE_DIRS}
          ${CMAKE_INSTALL_PREFIX}/include
    PATHS /var/empty/local/include
          /var/empty/include
    )

  # look for libs
  FIND_LIBRARY(
    GNURADIO_RUNTIME_LIBRARIES
    NAMES gnuradio-runtime
    HINTS $ENV{GNURADIO_RUNTIME_DIR}/lib
          ${PC_GNURADIO_RUNTIME_LIBDIR}
          ${CMAKE_INSTALL_PREFIX}/lib/
          ${CMAKE_INSTALL_PREFIX}/lib64/
    PATHS /var/empty/local/lib
          /var/empty/local/lib64
          /var/empty/lib
          /var/empty/lib64
    )

  set(GNURADIO_RUNTIME_FOUND ${PC_GNURADIO_RUNTIME_FOUND})
endif(PC_GNURADIO_RUNTIME_FOUND)

INCLUDE(FindPackageHandleStandardArgs)
# do not check GNURADIO_RUNTIME_INCLUDE_DIRS, is not set when default include path us used.
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GNURADIO_RUNTIME DEFAULT_MSG GNURADIO_RUNTIME_LIBRARIES)
MARK_AS_ADVANCED(GNURADIO_RUNTIME_LIBRARIES GNURADIO_RUNTIME_INCLUDE_DIRS)
