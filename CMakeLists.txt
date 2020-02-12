cmake_minimum_required(VERSION 3.12)

project(ibmtpm20tss VERSION 1.3.0 LANGUAGES C)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

include (GNUInstallDirs)
include(TestBigEndian)
if(APPLE OR MSVC)
    include(ConanAutoSetup)
endif()

include(TPM20tss)

option(CONFIG_SHARED_LIBRARIES "Build as shared libraries" ON)
option(CONFIG_TPM20 "Enable TPM 2.0 Features" ON)
option(CONFIG_TPM12 "Enable TPM 1.2 Features" ON)
option(CONFIG_TSS_NOPRINT "Build a TSS library without tracing or prints" OFF)
option(CONFIG_TSS_NOFILE "Build a TSS library that does not use files to preserve state" OFF)
option(CONFIG_TSS_NOCRYPTO "Build a TSS library that does not require a crypto library" OFF)
option(CONFIG_TSS_NOECC "Build a TSS library that does not require OpenSSL elliptic curve support" OFF)
option(CONFIG_HWTPM "Use a software TPM instead of the hardware one" ON)
option(CONFIG_RMTPM "Do not use the resource manage" OFF)

set(BUILD_SHARED_LIBS ${CONFIG_SHARED_LIBRARIES})
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(OpenSSL REQUIRED)

add_subdirectory(utils)
if(CONFIG_TPM12)
    add_subdirectory(utils12)
endif()