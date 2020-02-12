#---------------
# main ibmtss shared library

add_library(ibmtss
    tssfile.c
    tsscryptoh.c
    tsscrypto.c
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

if(CONFIG_TPM20)
    target_sources(ibmtss PRIVATE
        tss20.c
        tssauth20.c
        Commands.c
        tssprintcmd.c
        ntc2lib.c
        tssntc.c
    )
endif()

if(CONFIG_TPM12)
    target_sources(ibmtss PRIVATE
        tss12.c
        tssauth12.c
        tssmarshal12.c
        Unmarshal12.c
        Commands12.c
        tssccattributes12.c
        CommandAttributeData12.c
    )

endif()

set_target_properties(ibmtss PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_compile_definitions(ibmtss
    PRIVATE
        $<$<BOOL:${CONFIG_TPM20}>:TPM_TPM20>
        $<$<BOOL:${CONFIG_TPM12}>:TPM_TPM12>
        $<$<BOOL:${CONFIG_HWTPM}>:TPM_INTERFACE_TYPE_DEFAULT="dev">
        $<$<BOOL:${CONFIG_RMTPM}>:TPM_DEVICE_DEFAULT="/dev/tpmrm0">
    PUBLIC
        $<$<BOOL:${UNIX}>:TPM_POSIX>
        $<$<BOOL:${WIN32}>:TPM_WINDOWS>
        $<$<BOOL:${CONFIG_TSS_NOECC}>:TPM_TSS_NOECC>
        $<$<BOOL:${CONFIG_TSS_NOPRINT}>:TPM_TSS_NOPRINT>
        $<$<BOOL:${CONFIG_TSS_NOFILE}>:TPM_TSS_NOFILE>
        $<$<BOOL:${CONFIG_TSS_NOCRYPTO}>:TPM_TSS_NOCRYPTO>
)

target_compile_options(ibmtss
    PUBLIC
        $<$<OR:${UNIX},${MINGW}>:-Wall>
        $<$<OR:${UNIX},${MINGW}>:-Werror>
        $<$<OR:${UNIX},${MINGW}>:-Wmissing-declarations>
        $<$<OR:${UNIX},${MINGW}>:-Wmissing-prototypes>
        $<$<OR:${UNIX},${MINGW}>:-Wsign-compare>
        $<$<OR:${UNIX},${MINGW}>:-Wnested-externs>
        $<$<BOOL:${MSVC}>:/W3>
)

target_link_options(ibmtss
    PUBLIC
        $<$<OR:${UNIX},${MINGW}>:-Wl,--no-undefined>
)

target_link_libraries(ibmtss
    PUBLIC
        OpenSSL::Crypto
        $<$<BOOL:${WIN32}>:crypt32>
)

string(APPEND CMAKE_SHARED_LINKER_FLAGS " -Wl,--no-undefined")

target_include_directories(ibmtss
    PUBLIC
        $<INSTALL_INTERFACE:ibmtss>
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/utils>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

install(TARGETS ibmtss
    EXPORT ibmtss-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT ibmtss-targets
    FILE
        ibmtssTargets.cmake
    NAMESPACE
        ibmtpm::
    DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/cmake/ibmtss
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/ibmtssConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

#---------------
# ibmtssutils shared library

add_library(ibmtssutils
    cryptoutils.c
    ekutils.c
    imalib.c
    eventlib.c
    )

set_target_properties(ibmtssutils PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_compile_definitions(ibmtssutils
    PRIVATE
        $<$<BOOL:${CONFIG_TPM20}>:TPM_TPM20>
        $<$<BOOL:${CONFIG_TPM12}>:TPM_TPM12>
)

target_compile_options(ibmtssutils
    PUBLIC
        $<$<OR:${UNIX},${MINGW}>:-Wall>
        $<$<OR:${UNIX},${MINGW}>:-Werror>
        $<$<OR:${UNIX},${MINGW}>:-Wmissing-declarations>
        $<$<OR:${UNIX},${MINGW}>:-Wmissing-prototypes>
        $<$<OR:${UNIX},${MINGW}>:-Wsign-compare>
        $<$<OR:${UNIX},${MINGW}>:-Wnested-externs>
        $<$<BOOL:${MSVC}>:/W3>
)

target_link_options(ibmtssutils
    PUBLIC
        $<$<OR:${UNIX},${MINGW}>:-Wl,--no-undefined>
)

target_link_libraries(ibmtssutils
    PUBLIC
        ibmtss
)

install(TARGETS ibmtssutils
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Utilities Binaries

add_tss_binary(activatecredential SOURCES activatecredential.c)
add_tss_binary(eventextend SOURCES eventextend.c)
add_tss_binary(imaextend SOURCES imaextend.c)
add_tss_binary(certify SOURCES certify.c)
add_tss_binary(certifycreation SOURCES certifycreation.c)
add_tss_binary(certifyx509 SOURCES certifyx509.c)
add_tss_binary(changeeps SOURCES changeeps.c)
add_tss_binary(changepps SOURCES changepps.c)
add_tss_binary(clear SOURCES clear.c)
add_tss_binary(clearcontrol SOURCES clearcontrol.c)
add_tss_binary(clockrateadjust SOURCES clockrateadjust.c)
add_tss_binary(clockset SOURCES clockset.c)
add_tss_binary(commit SOURCES commit.c)
add_tss_binary(contextload SOURCES contextload.c)
add_tss_binary(contextsave SOURCES contextsave.c)
add_tss_binary(create SOURCES create.c objecttemplates.c)
add_tss_binary(createloaded SOURCES createloaded.c objecttemplates.c)
add_tss_binary(createprimary SOURCES createprimary.c objecttemplates.c)
add_tss_binary(dictionaryattacklockreset SOURCES dictionaryattacklockreset.c)
add_tss_binary(dictionaryattackparameters SOURCES dictionaryattackparameters.c)
add_tss_binary(duplicate SOURCES duplicate.c)
add_tss_binary(eccparameters SOURCES eccparameters.c)
add_tss_binary(ecephemeral SOURCES ecephemeral.c)
add_tss_binary(encryptdecrypt SOURCES encryptdecrypt.c)
add_tss_binary(eventsequencecomplete SOURCES eventsequencecomplete.c)
add_tss_binary(evictcontrol SOURCES evictcontrol.c)
add_tss_binary(flushcontext SOURCES flushcontext.c)
add_tss_binary(getcommandauditdigest SOURCES getcommandauditdigest.c)
add_tss_binary(getcapability SOURCES getcapability.c)
add_tss_binary(getcryptolibrary SOURCES getcryptolibrary.c)
add_tss_binary(getrandom SOURCES getrandom.c)
add_tss_binary(gettestresult SOURCES gettestresult.c)
add_tss_binary(getsessionauditdigest SOURCES getsessionauditdigest.c)
add_tss_binary(gettime SOURCES gettime.c)
add_tss_binary(hashsequencestart SOURCES hashsequencestart.c)
add_tss_binary(hash SOURCES hash.c)
add_tss_binary(hierarchycontrol SOURCES hierarchycontrol.c)
add_tss_binary(hierarchychangeauth SOURCES hierarchychangeauth.c)
add_tss_binary(hmac SOURCES hmac.c)
add_tss_binary(hmacstart SOURCES hmacstart.c)
add_tss_binary(import SOURCES import.c)
add_tss_binary(importpem SOURCES importpem.c objecttemplates.c)
add_tss_binary(load SOURCES load.c)
add_tss_binary(loadexternal SOURCES loadexternal.c)
add_tss_binary(makecredential SOURCES makecredential.c)
add_tss_binary(nvcertify SOURCES nvcertify.c)
add_tss_binary(nvchangeauth SOURCES nvchangeauth.c)
add_tss_binary(nvdefinespace SOURCES nvdefinespace.c)
add_tss_binary(nvextend SOURCES nvextend.c)
add_tss_binary(nvglobalwritelock SOURCES nvglobalwritelock.c)
add_tss_binary(nvincrement SOURCES nvincrement.c)
add_tss_binary(nvread SOURCES nvread.c)
add_tss_binary(nvreadlock SOURCES nvreadlock.c)
add_tss_binary(nvreadpublic SOURCES nvreadpublic.c)
add_tss_binary(nvsetbits SOURCES nvsetbits.c)
add_tss_binary(nvundefinespace SOURCES nvundefinespace.c)
add_tss_binary(nvundefinespacespecial SOURCES nvundefinespacespecial.c)
add_tss_binary(nvwrite SOURCES nvwrite.c)
add_tss_binary(nvwritelock SOURCES nvwritelock.c)
add_tss_binary(objectchangeauth SOURCES objectchangeauth.c)
add_tss_binary(pcrallocate SOURCES pcrallocate.c)
add_tss_binary(pcrevent SOURCES pcrevent.c)
add_tss_binary(pcrextend SOURCES pcrextend.c)
add_tss_binary(pcrread SOURCES pcrread.c)
add_tss_binary(pcrreset SOURCES pcrreset.c)
add_tss_binary(policyauthorize SOURCES policyauthorize.c)
add_tss_binary(policyauthvalue SOURCES policyauthvalue.c)
add_tss_binary(policycommandcode SOURCES policycommandcode.c)
add_tss_binary(policycphash SOURCES policycphash.c)
add_tss_binary(policynamehash SOURCES policynamehash.c)
add_tss_binary(policycountertimer SOURCES policycountertimer.c)
add_tss_binary(policyduplicationselect SOURCES policyduplicationselect.c)
add_tss_binary(policygetdigest SOURCES policygetdigest.c)
add_tss_binary(policymaker SOURCES policymaker.c)
add_tss_binary(policymakerpcr SOURCES policymakerpcr.c)
add_tss_binary(policyauthorizenv SOURCES policyauthorizenv.c)
add_tss_binary(policynv SOURCES policynv.c)
add_tss_binary(policynvwritten SOURCES policynvwritten.c)
add_tss_binary(policyor SOURCES policyor.c)
add_tss_binary(policypassword SOURCES policypassword.c)
add_tss_binary(policypcr SOURCES policypcr.c)
add_tss_binary(policyrestart SOURCES policyrestart.c)
add_tss_binary(policysigned SOURCES policysigned.c)
add_tss_binary(policysecret SOURCES policysecret.c)
add_tss_binary(policytemplate SOURCES policytemplate.c)
add_tss_binary(policyticket SOURCES policyticket.c)
add_tss_binary(quote SOURCES quote.c)
add_tss_binary(powerup SOURCES powerup.c)
add_tss_binary(readclock SOURCES readclock.c)
add_tss_binary(readpublic SOURCES readpublic.c)
add_tss_binary(returncode SOURCES returncode.c)
add_tss_binary(rewrap SOURCES rewrap.c)
add_tss_binary(rsadecrypt SOURCES rsadecrypt.c)
add_tss_binary(rsaencrypt SOURCES rsaencrypt.c)
add_tss_binary(sequenceupdate SOURCES sequenceupdate.c)
add_tss_binary(sequencecomplete SOURCES sequencecomplete.c)
add_tss_binary(setcommandcodeauditstatus SOURCES setcommandcodeauditstatus.c)
add_tss_binary(setprimarypolicy SOURCES setprimarypolicy.c)
add_tss_binary(shutdown SOURCES shutdown.c)
add_tss_binary(sign SOURCES sign.c)
add_tss_binary(startauthsession SOURCES startauthsession.c)
add_tss_binary(startup SOURCES startup.c)
add_tss_binary(stirrandom SOURCES stirrandom.c)
add_tss_binary(unseal SOURCES unseal.c)
add_tss_binary(verifysignature SOURCES verifysignature.c)
add_tss_binary(zgen2phase SOURCES zgen2phase.c)
add_tss_binary(signapp SOURCES signapp.c)
add_tss_binary(writeapp SOURCES writeapp.c)
add_tss_binary(timepacket SOURCES timepacket.c)
add_tss_binary(createek SOURCES createek.c)
add_tss_binary(createekcert SOURCES createekcert.c)
add_tss_binary(tpm2pem SOURCES tpm2pem.c)
add_tss_binary(tpmpublic2eccpoint SOURCES tpmpublic2eccpoint.c)
add_tss_binary(ntc2getconfig SOURCES ntc2getconfig.c)
add_tss_binary(ntc2preconfig SOURCES ntc2preconfig.c)
add_tss_binary(ntc2lockconfig SOURCES ntc2lockconfig.c)
add_tss_binary(publicname SOURCES publicname.c)
add_tss_binary(tpmcmd SOURCES tpmcmd.c LIBRARIES)
add_tss_binary(printattr SOURCES printattr.c)
