#---------------
# ibmtssutils shared library

add_library(ibmtssutils12 ekutils12.c)

set_target_properties(ibmtssutils12 PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_link_libraries(ibmtssutils12
    PUBLIC
        ibmtss
)

install(TARGETS ibmtssutils12
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

add_tss_binary(tss1activateidentity SOURCES activateidentity.c TPM12)
add_tss_binary(tss1createendorsementkeypair SOURCES createendorsementkeypair.c TPM12)
add_tss_binary(tss1createwrapkey SOURCES createwrapkey.c TPM12)
add_tss_binary(tss1extend SOURCES extend.c TPM12)
add_tss_binary(tss1flushspecific SOURCES flushspecific.c TPM12)
add_tss_binary(tss1getcapability SOURCES getcapability.c TPM12)
add_tss_binary(tss1loadkey2 SOURCES loadkey2.c TPM12)
add_tss_binary(tss1makeidentity SOURCES makeidentity.c TPM12)
add_tss_binary(tss1nvdefinespace SOURCES nvdefinespace.c TPM12)
add_tss_binary(tss1nvreadvalueauth SOURCES nvreadvalueauth.c TPM12)
add_tss_binary(tss1nvreadvalue SOURCES nvreadvalue.c TPM12)
add_tss_binary(tss1nvwritevalueauth SOURCES nvwritevalueauth.c TPM12)
add_tss_binary(tss1nvwritevalue SOURCES nvwritevalue.c TPM12)
add_tss_binary(tss1oiap SOURCES oiap.c TPM12)
add_tss_binary(tss1osap SOURCES osap.c TPM12)
add_tss_binary(tss1ownerreadinternalpub SOURCES ownerreadinternalpub.c TPM12)
add_tss_binary(tss1ownersetdisable SOURCES ownersetdisable.c TPM12)
add_tss_binary(tss1pcrread SOURCES pcrread.c TPM12)
add_tss_binary(tss1quote2 SOURCES quote2.c ${PROJECT_SOURCE_DIR}/utils/cryptoutils.c TPM12)
add_tss_binary(tss1sign SOURCES sign.c ${PROJECT_SOURCE_DIR}/utils/cryptoutils.c TPM12)
add_tss_binary(tss1startup SOURCES startup.c TPM12)
add_tss_binary(tss1takeownership SOURCES takeownership.c TPM12)
add_tss_binary(tss1tpminit SOURCES tpminit.c TPM12)
add_tss_binary(tss1createekcert SOURCES
    createekcert.c
    ekutils12.c
    ${PROJECT_SOURCE_DIR}/utils/cryptoutils.c
    ${PROJECT_SOURCE_DIR}/utils/ekutils.c TPM12)
add_tss_binary(tss1makeekblob SOURCES makeekblob.c TPM12)
add_tss_binary(tss1eventextend SOURCES eventextend.c ../utils/eventlib.c TPM12)
add_tss_binary(tss1imaextend SOURCES imaextend.c ../utils/imalib.c TPM12)
