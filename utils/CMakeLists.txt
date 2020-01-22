string(APPEND CMAKE_SHARED_LINKER_FLAGS " -Wl,--no-undefined")

if(CONFIG_HWTPM)
    list(APPEND default_flags "TPM_INTERFACE_TYPE_DEFAULT=\"dev\"")
endif()

if(CONFIG_RMTPM)
    list(APPEND default_flags "TPM_DEVICE_DEFAULT=\"/dev/tpmrm0\"")
endif()

if(CONFIG_TSS_NOECC)
    list(APPEND default_flags "TPM_TSS_NOECC")
endif()

set(IBMTSS_SHARED_SRCS
    tss.c
    tssproperties.c
    tssmarshal.c
    tssauth.c
    tssutils.c
    tsssocket.c
    tssdev.c
    tsstransmit.c
    tssresponsecode.c
    tssccattributes.c
    tssprint.c
    Unmarshal.c
    CommandAttributeData.c
)

set(IBMTSS_SRCS
    tssfile.c
    tsscryptoh.c
    tsscrypto.c
    )

if(CONFIG_TPM20)
    set(IBMTSS_TPM20_SRCS
        tss20.c
        tssauth20.c
        Commands.c
        tssprintcmd.c
        ntc2lib.c
        tssntc.c
    )
    list(APPEND default_flags "TPM_TPM20")
endif()

if(CONFIG_TPM12)
    set(IBMTSS_TPM12_SRCS
        tss12.c
        tssauth12.c
        tssmarshal12.c
        Unmarshal12.c
        Commands12.c
        tssccattributes12.c
        CommandAttributeData12.c
    )
    list(APPEND default_flags "TPM_TPM12")
endif()

#---------------
# Object shared library

add_library(ibmtss_object OBJECT ${IBMTSS_SHARED_SRCS})

target_compile_definitions(ibmtss_object PUBLIC
    ${TPM_OS_DEF}
    ${default_flags}
    )

#---------------
# main ibmtss shared library

add_library(ibmtss SHARED
    ${IBMTSS_SRCS}
    $<TARGET_OBJECTS:ibmtss_object>
    ${IBMTSS_TPM20_SRCS}
    ${IBMTSS_TPM12_SRCS}
    )

set_target_properties(ibmtss PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_compile_definitions(ibmtss PUBLIC
    ${TPM_OS_DEF}
    ${default_flags}
)

target_link_libraries(ibmtss
    PUBLIC
        OpenSSL::Crypto
)

#---------------
# ibmtssutils shared library

set(IBMTSSUTILS_SRCS
    cryptoutils.c
    ekutils.c
    imalib.c
    eventlib.c
    )


add_library(ibmtssutils SHARED
    ${IBMTSSUTILS_SRCS}
    )

set_target_properties(ibmtssutils PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_compile_definitions(ibmtssutils PUBLIC
    ${TPM_OS_DEF}
    ${default_flags}
)

target_link_libraries(ibmtssutils
    PUBLIC
        OpenSSL::Crypto
        ibmtss
)

#---------------------
# Utilities

if(CONFIG_TSS_NOECC)
    set(UTILS_FLAGS TPM_TSS_NOECC)
endif()

add_executable(activatecredential activatecredential.c)
target_compile_definitions(activatecredential PRIVATE ${UTILS_FLAGS})
target_link_libraries(activatecredential ibmtssutils)
