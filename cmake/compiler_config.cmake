
# 设置编译类型，默认Release
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
message(STATUS "编译类型:" ${CMAKE_BUILD_TYPE})

#设置编译参数
add_compile_options(-c -pipe -Werror=return-type)


# 编译警告转成错误
# add_compile_options(-Werror)

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,--no-undefined")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")


set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,--no-undefined")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")

# 指定C/C++版本
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
# 输出编译命令
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
