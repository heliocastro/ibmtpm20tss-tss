cmake_minimum_required(VERSION 3.4)

project(ibmtpm20tss VERSION 1.3.0 LANGUAGES C)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(OpenSSL REQUIRED)

option(BUILD_SHARED_LIBS "build as shared libraries" ON)
option(CONFIG_TPM20 "Enable TPM 2.0 Features" TRUE)
option(CONFIG_TPM12 "Enable TPM 1.2 Features" TRUE)
option(CONFIG_TSS_NOPRINT "Build a TSS library without tracing or prints" FALSE)
option(CONFIG_TSS_NOFILE "Build a TSS library that does not use files to preserve state" FALSE)
option(CONFIG_TSS_NOCRYPTO "Build a TSS library that does not require a crypto library" FALSE)
option(CONFIG_TSS_NOECC "Build a TSS library that does not require OpenSSL elliptic curve support" FALSE)
option(CONFIG_HWTPM "Use a software TPM instead of the hardware one" TRUE)
option(CONFIG_RMTPM "Do not use the resource manage" FALSE)

if(UNIX)
    set(TPM_OS_DEF "TPM_POSIX")
elseif(WIN32)
    set(TPM_OS_DEF "TPM_WINDOWS")
endif()

add_subdirectory(utils)
add_subdirectory(utils12)
