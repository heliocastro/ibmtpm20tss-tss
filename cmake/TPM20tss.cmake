include(GNUInstallDirs)

#---------------------
# Utilities

function(add_tss_binary)
    set(options TPM12)
    set(oneValueArgs SUFFIX)
    set(multiValueArgs SOURCES;LIBRARIES)
    cmake_parse_arguments(TSS
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
    )

    add_executable(${ARGV0} ${TSS_SOURCES})

    if(TSS_TPM12)
        target_link_libraries(${ARGV0}
            PRIVATE
                ibmtssutils12
                ${TSS_LIBRARIES}
        )
        target_compile_definitions(${ARGV0}
            PRIVATE
                TPM_TPM12
        )
    else()
        target_link_libraries(${ARGV0}
            PRIVATE
                ibmtssutils
                ${TSS_LIBRARIES}
            )
        target_compile_definitions(${ARGV0}
            PRIVATE
                TPM_TPM20
                $<$<BOOL:CONFIG_TSS_NOECC>:TPM_TSS_NOECC>
        )
    endif()

    install(TARGETS ${ARGV0}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endfunction()
