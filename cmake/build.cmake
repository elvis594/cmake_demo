macro(AT_BUILD_LIB OUTPUT_NAME SRC_LISTS LIB_LISTS LIBRARY_TYPE)
    MESSAGE(STATUS "${SOURCE_OUTPUT_NAME} build generate lib file [lib${OUTPUT_NAME}.so] ${LIBRARY_TYPE}")
    add_library(${OUTPUT_NAME} ${LIBRARY_TYPE} ${SRC_LISTS})
    target_link_libraries(${OUTPUT_NAME} PUBLIC ${LIB_LISTS}) # 为指定target增加库链接
    target_link_options(${OUTPUT_NAME} PRIVATE -Xlinker -Map=${OUTPUT_NAME}.map)
endmacro()

macro(AT_BUILD_TARGET OUTPUT_NAME SRC_LISTS LIB_LISTS)
    MESSAGE(STATUS "${SOURCE_OUTPUT_NAME} build  generate executable file [${OUTPUT_NAME}]")
    add_executable(${OUTPUT_NAME} ${SRC_LISTS})
    target_link_libraries(${OUTPUT_NAME} PUBLIC ${LIB_LISTS}) # 为指定target增加库链接
    target_link_options(${OUTPUT_NAME} PRIVATE -Xlinker -Map=${OUTPUT_NAME}.map)
    #添加生成的map
endmacro()


macro(AT_REG_NAME PROJECT_NAME)
    set(SON_PROJECT_NAME ${PROJECT_NAME})
    set_property(GLOBAL APPEND PROPERTY VERSION_LISTS  "${PROJECT_NAME}")
endmacro(AT_REG_NAME)

macro(AT_MAJOR_VERSION CODE)
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_MAJOR_VERSION ${CODE})
endmacro()

macro(AT_MINOR_VERSION CODE)
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_MINOR_VERSION ${CODE})
endmacro(AT_MINOR_VERSION)

macro(AT_PATCH_VERSION CODE)
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_PATCH_VERSION ${CODE})
endmacro(AT_PATCH_VERSION)

macro(AT_TWEAK_VERSION CODE)
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_TWEAK_VERSION ${CODE})
endmacro(AT_TWEAK_VERSION)


macro(AT_MAKE_VERSION VERSION_NAME)
    if(NOT "${${VERSION_NAME}_VERSION_VARIABLE}" STREQUAL "")
        set(VERSION_STRING "${VERSION_STRING}.${${VERSION_NAME}_VERSION_VARIABLE}")
    else() 
        set(VERSION_STRING "${VERSION_STRING}.0")
    endif()
endmacro()

macro(AT_MAKE_VERSION_HEAD VERSION_NAME)
    if(NOT "${${VERSION_NAME}_VERSION_VARIABLE}" STREQUAL "")
        set(VERSION_STRING "${VERSION_STRING} ${${VERSION_NAME}_VERSION_VARIABLE}")
    else() 
        set(VERSION_STRING "${VERSION_STRING} 0")
    endif()
endmacro()


function(AT_GET_VERSION VERSION_NAME VERSION_RES)
    get_property(MAJOR_VERSION GLOBAL PROPERTY ${VERSION_NAME}_MAJOR_VERSION)
    get_property(MINOR_VERSION GLOBAL PROPERTY ${VERSION_NAME}_MINOR_VERSION)
    get_property(PATCH_VERSION GLOBAL PROPERTY ${VERSION_NAME}_PATCH_VERSION)
    get_property(TWEAK_VERSION GLOBAL PROPERTY ${VERSION_NAME}_TWEAK_VERSION)
    set(${VERSION_RES} "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}.${TWEAK_VERSION}" PARENT_SCOPE)
endfunction()

##拷贝输出头文件到某目录下面
function(AT_RELEASE_INCLUD_FILES FILE_LISTS RELEASE_DIR)
    file(GLOB API_INC_FILES_LISTS ${FILE_LISTS})
    # 确保目标目录存在
    file(MAKE_DIRECTORY "${INCLUDE_OUTPUT_PATH}/${RELEASE_DIR}")
    foreach(file IN LISTS API_INC_FILES_LISTS)
        file(COPY "${file}" DESTINATION "${INCLUDE_OUTPUT_PATH}/${RELEASE_DIR}")
    endforeach()
endfunction()

##======================获取git信息=========================

function(get_git_branch_name TARGET_DIR OUTPUT_VAR)
  execute_process(
    COMMAND git -C "${TARGET_DIR}" symbolic-ref --short HEAD
    OUTPUT_VARIABLE GIT_BRANCH_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # 将结果设置为输出变量
  set(${OUTPUT_VAR} ${GIT_BRANCH_NAME} PARENT_SCOPE)
endfunction()

function(get_git_commit_id TARGET_DIR OUTPUT_VAR)
    # 获取当前 6位 Git commit ID
    execute_process(
    COMMAND git -C "${TARGET_DIR}" rev-parse --short=6 HEAD
    OUTPUT_VARIABLE GIT_COMMIT_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  # 将结果设置为输出变量
  set(${OUTPUT_VAR} ${GIT_COMMIT_ID} PARENT_SCOPE)
endfunction()

##获取仓库名称 
function(get_git_repo_name TARGET_DIR OUTPUT_VAR)
    # 获取当前 Git 仓库的顶层目录
    execute_process(
    COMMAND git -C "${TARGET_DIR}" rev-parse --show-toplevel
    OUTPUT_VARIABLE GIT_REPO_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # 提取 Git 仓库名称
    get_filename_component(GIT_REPO_NAME "${GIT_REPO_DIR}" NAME)

    # 输出获取到的 Git 仓库名称
    # 将结果设置为输出变量
    set(${OUTPUT_VAR} ${GIT_REPO_NAME} PARENT_SCOPE)
endfunction()

##获取上一级仓库目录名称
function(get_old_repo_name OUTPUT_VAR)
    # 获取当前 CMakeLists.txt 文件所在的目录
    get_filename_component(CURRENT_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
    # 获取当前目录的上一层目录
    get_filename_component(PARENT_DIR "${CURRENT_DIR}" DIRECTORY)
    # 提取上一层目录的名称
    get_filename_component(PARENT_DIR_NAME "${PARENT_DIR}" NAME)
    # 输出获取到的 Git 仓库名称
    # 将结果设置为输出变量
    set(${OUTPUT_VAR} ${PARENT_DIR_NAME} PARENT_SCOPE)
endfunction()

##获取仓库状态
function(get_git_repo_state TARGET_DIR OUTPUT_VAR)
    execute_process(
    COMMAND git -C "${TARGET_DIR}" status --untracked-files=no -s
    COMMAND wc -l
    OUTPUT_VARIABLE MODIFIED_FILES_COUNT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # 输出已修改的文件数量，或输出 "clean"
    if(MODIFIED_FILES_COUNT EQUAL 0)
      set(REPO_RES "Clean")
    else()
      set(REPO_RES "${MODIFIED_FILES_COUNT}FilesIsDirty")
    endif()
    # 将结果设置为输出变量
    set(${OUTPUT_VAR} ${REPO_RES} PARENT_SCOPE)
endfunction()

function(get_git_info OUTPUT_VAR)

    get_filename_component(CURRENT_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

    get_git_repo_name(${CURRENT_DIR} GIT_REPO_NAME)
    get_git_commit_id(${CURRENT_DIR} GIT_COMMIT_ID)
    get_git_branch_name(${CURRENT_DIR} GIT_BRANCH_NAME)
    get_git_repo_state(${CURRENT_DIR} GIT_FILE_STATE)

    set(ProjectName_ "${GIT_REPO_NAME}")
    set(BranchName_ "${GIT_BRANCH_NAME}")
    set(CommitName_ "${GIT_COMMIT_ID}")
    set(IsDirty_ "${GIT_FILE_STATE}")

    set(formatted_string "%-30s Branch: %30s ( %s | %2s )")

    string(REPLACE "%-30s" "${ProjectName_}" formatted_string "${formatted_string}")
    string(REPLACE "%30s" "${BranchName_}" formatted_string "${formatted_string}")
    string(REGEX REPLACE "%s" "${CommitName_}" formatted_string "${formatted_string}")
    string(REGEX REPLACE "%2s" "${IsDirty_}" formatted_string "${formatted_string}")

    set(${OUTPUT_VAR} ${formatted_string} PARENT_SCOPE)
endfunction()

function(get_old_git_info OUTPUT_VAR)

    get_filename_component(CURRENT_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
    # 获取到的上一层目录名称
    get_old_repo_name(PARENT_DIR_NAME)
    get_git_repo_name(${CURRENT_DIR} GIT_REPO_NAME)
    get_git_commit_id(${CURRENT_DIR} GIT_COMMIT_ID)
    get_git_branch_name(${CURRENT_DIR} GIT_BRANCH_NAME)
    get_git_repo_state(${CURRENT_DIR} GIT_FILE_STATE)

    set(ProjectName_ "${PARENT_DIR_NAME}(${GIT_REPO_NAME})")
    set(BranchName_ "${GIT_BRANCH_NAME}")
    set(CommitName_ "${GIT_COMMIT_ID}")
    set(IsDirty_ "${GIT_FILE_STATE}")

    set(formatted_string "%-30s Branch: %30s ( %s | %2s )")

    string(REPLACE "%-30s" "${ProjectName_}" formatted_string "${formatted_string}")
    string(REPLACE "%30s" "${BranchName_}" formatted_string "${formatted_string}")
    string(REGEX REPLACE "%s" "${CommitName_}" formatted_string "${formatted_string}")
    string(REGEX REPLACE "%2s" "${IsDirty_}" formatted_string "${formatted_string}")

    set(${OUTPUT_VAR} ${formatted_string} PARENT_SCOPE)
endfunction()

macro(AT_REG_OTHER_NAME_OLD PROJECT_NAME)
    get_old_git_info(res)
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_OTHER_NAME ${PROJECT_NAME})
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_GIT_INFO ${res})

endmacro(AT_REG_OTHER_NAME_OLD)

macro(AT_REG_OTHER_NAME PROJECT_NAME)
    get_git_info(res)
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_OTHER_NAME ${PROJECT_NAME})
    set_property(GLOBAL PROPERTY ${SON_PROJECT_NAME}_GIT_INFO ${res})

endmacro(AT_REG_OTHER_NAME)

function(AT_MAKE_GIT_VERSION OTHER_NAME GIT_INFO OUT_PUT_VALUE)
    if(NOT "${GIT_INFO}" STREQUAL "")
        set(${OUT_PUT_VALUE} "#define VER_BUILD_${OTHER_NAME} \"${GIT_INFO}\"" PARENT_SCOPE)
    else() 
        set(${OUT_PUT_VALUE} " " PARENT_SCOPE)
    endif()
endfunction()

function(AT_MAKE_GIT_VERSION_ALL GIT_INFO OUT_PUT_VALUE)
    if(NOT "${GIT_INFO}" STREQUAL "")
        set(${OUT_PUT_VALUE} "${GIT_INFO}" PARENT_SCOPE)
    else() 
        set(${OUT_PUT_VALUE} " " PARENT_SCOPE)
    endif()
endfunction()
##======================end=========================

##======================编译protobuf================
function(PROTOBUF_GENERATE_CPP SRCS HDRS)
    if(NOT ARGN)
        message(SEND_ERROR "Error: PROTOBUF_GENERATE_CPP() called without any proto files")
        return()
    endif()

    set(${SRCS})
    set(${HDRS})
    foreach(FIL ${ARGN})
        get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
        get_filename_component(FIL_WE ${FIL} NAME_WE)

        list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc")
        list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h")

        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc"
                   "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h"
            COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
            ARGS --cpp_out ${CMAKE_CURRENT_BINARY_DIR} -I ${PROTO_SRC_DIR} ${ABS_FIL}
            DEPENDS ${ABS_FIL}
            COMMENT "Running C++ protocol buffer compiler on ${FIL}"
            VERBATIM
        )
    endforeach()

    set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
    set(${SRCS} ${${SRCS}} PARENT_SCOPE)
    set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()