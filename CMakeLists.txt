cmake_minimum_required(VERSION 3.13)

##=====================公共变量=====================
# 设置项目根目录
set(ROOT_DIR                 ${CMAKE_CURRENT_SOURCE_DIR})
# 3rd library 搜索路径
set(MAIN_PRJ_SRC_DIR         ${ROOT_DIR})
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(RELEASE_DIR ${CMAKE_CURRENT_LIST_DIR}/release)

#配置版本信息
set_property(GLOBAL PROPERTY VERSION_LISTS  "")
##=====================宏文件=====================
include(build)

##=====================编译平台=====================
include(toolchain)

##=====================编译器config=====================
include(compiler_config)

# 项目名称
project(infra)

#第三方库
include(${ROOT_DIR}/third_party/third_party.cmake)

##=====================统一编译输出路径=====================
set(LIBRARY_OUTPUT_PATH ${RELEASE_DIR}/${BUILD_TARGET}/lib)
set(EXECUTABLE_OUTPUT_PATH ${RELEASE_DIR}/${BUILD_TARGET}/bin)
set(TEST_EXECUTABLE_OUTPUT_PATH ${RELEASE_DIR}/${BUILD_TARGET}/test)
set(INCLUDE_OUTPUT_PATH ${RELEASE_DIR}/include)
link_directories(${RELEASE_DIR}/${BUILD_TARGET}/lib)

##=====================子目录=====================
# 添加子目录，每个子节点单独的目录，环境互相不影响
function(_add_subdirectory dir)
    if(EXISTS ${dir}/CMakeLists.txt)
        add_subdirectory(${dir})
    else()
        message("注意：${dir} CMakeLists.txt not found.")
    endif()
endfunction(_add_subdirectory)

_add_subdirectory(${ROOT_DIR}/example)


