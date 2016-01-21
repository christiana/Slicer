
set(proj OpenIGTLinkIO)

# Set dependency list
set(${proj}_DEPENDENCIES ${VTK_EXTERNAL_NAME} OpenIGTLink)

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  unset(OpenIGTLinkIO_DIR CACHE)
  find_package(OpenIGTLinkIO REQUIRED NO_MODULE)
endif()

# Sanity checks
if(DEFINED OpenIGTLinkIO_DIR AND NOT EXISTS ${OpenIGTLinkIO_DIR})
  message(FATAL_ERROR "OpenIGTLinkIO_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED OpenIGTLinkIO_DIR AND NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  set(CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG)
  if(CTEST_USE_LAUNCHERS)
    set(CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG
      "-DCMAKE_PROJECT_OpenIGTLinkIO_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake")
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${git_protocol}://github.com/christiana/OpenIGTLinkIO.git"
#    GIT_REPOSITORY "${git_protocol}://github.com/openigtlink/OpenIGTLink.git"
    #GIT_TAG "849b434b4b45a28e3955adf4ba1f3ececd51581e"
    SOURCE_DIR OpenIGTLinkIO
    BINARY_DIR OpenIGTLinkIO-build
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      ${CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG}
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DVTK_DIR:PATH=${VTK_DIR}
      -DOpenIGTLink_DIR:PATH=${OpenIGTLink_DIR}
#      -DOpenIGTLink_PROTOCOL_VERSION_2:BOOL=ON
    INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )

  set(OpenIGTLinkIO_DIR ${CMAKE_BINARY_DIR}/OpenIGTLinkIO-build)

  #-----------------------------------------------------------------------------
  # Launcher setting specific to build tree

  set(${proj}_LIBRARY_PATHS_LAUNCHER_BUILD
    ${OpenIGTLinkIO_DIR}
    ${OpenIGTLinkIO_DIR}/bin/<CMAKE_CFG_INTDIR>
    )
  mark_as_superbuild(
    VARS ${proj}_LIBRARY_PATHS_LAUNCHER_BUILD
    LABELS "LIBRARY_PATHS_LAUNCHER_BUILD"
    )

  #-----------------------------------------------------------------------------
  # Launcher setting specific to install tree

  if(UNIX AND NOT APPLE)
    set(${proj}_LIBRARY_PATHS_LAUNCHER_INSTALLED <APPLAUNCHER_DIR>/lib/igtl)
    mark_as_superbuild(
      VARS ${proj}_LIBRARY_PATHS_LAUNCHER_INSTALLED
      LABELS "LIBRARY_PATHS_LAUNCHER_INSTALLED"
      )
  endif()

else()
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
endif()

mark_as_superbuild(
  VARS OpenIGTLinkIO_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
