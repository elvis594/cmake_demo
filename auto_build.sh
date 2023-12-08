#!/usr/bin/bash

# 编译所使用线程数目
build_thread_num=8

# 设置交叉编译链列表
g_compiler_list=(
    "x86"
)
compiler="x86"
########################################################################
#      函数定义
########################################################################

# 字符串精确匹配 字符串数组 字符串
function Contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

# 选择编译平台
function SelectCompiler(){
    local compiler_list=($*)
    echo "compiler list:"

    for i in "${!compiler_list[@]}";
    do 
        echo " - $i" "${compiler_list[$i]}"  
    done

    read -p "please select compiler list index to generate cmake files:" compiler_idx

    compiler=${compiler_list[${compiler_idx}]}


    if [ -z ${compiler} ]; then
        echo "select compiler list index [${compiler_idx}] invalid!!!"
        exit
    fi
    echo ${compiler}
}

# 编译
function Build(){
    if [ ! -d "${current_path}/build_${compiler}" ];then
        mkdir ${current_path}/build_${compiler}
        cd ${current_path}/build_${compiler} && cmake .. ${compiler_flag}=ON
        make -j${build_thread_num}
    else
        cd ${current_path}/build_${compiler}
        make -j${build_thread_num}
    fi
}

function BuildTarget(){
    if [ ! -d "${current_path}/build_${compiler}" ];then
        mkdir ${current_path}/build_${compiler}
        cd ${current_path}/build_${compiler} && cmake .. ${compiler_flag}=ON -DBUILD_TESTS_PROJECT=ON
        make $1 -j${build_thread_num}
    else
        cd ${current_path}/build_${compiler}
        make $1 -j${build_thread_num}
    fi
}

# 清除
function Clean(){
    if [ -d "${current_path}/build_${compiler}" ];then
        cd ${current_path}/build_${compiler}
        make clean
        cd ..
        rm -rf ${current_path}/build_${compiler}
    fi
}

function check_cmake_config(){
    cd ${current_path}/build_${compiler} && cmake -L
}

function echo_help() {
    echo "-r: 清除cmake缓存，后再重新编译。"
    echo "-c: 清除cmake缓存。"
    echo "-s: 单独编译                         例：-s <process_name>"
    echo "-b: 选择编译器进行编译"
    echo "-d: 编译完成后，清除cmake缓存"
    echo "-l: 显示cmake缓存参数。"
    echo "-h: 显示帮助信息。"
}

########################################################################
#      功能执行
########################################################################

build_opt="build"
is_rm_build_dir=0
current_path=$(cd ${0%/*};pwd)
target_name="";


if [ -n "$1" ] && [ "$1" == "-h" ]; then
  echo_help
  exit 1
fi

#############################设置编译器###########################################
if [ -z ${compiler} ]; then
    SelectCompiler ${g_compiler_list[*]}
fi

if [[ $compiler == "build_"* ]];then
    compiler=${compiler:6}
fi
if [ $(Contains "${g_compiler_list[@]}" "${compiler}") == "n" ]; then
    echo "select compiler [${compiler}] invalid!!!"
    exit
fi

# 设置编译选项
compiler_flag="-DBUILD_FOR_${compiler^^}"

echo "compiler_flag = ${compiler_flag}"

#############################设置编译器end###########################################

while getopts "b:s:crdlh" opt; do
    case $opt in
        b)
            compiler=${OPTARG}
            echo "build compiler:${compiler}"
        ;;
        c)
            build_opt="clean"
            echo "clean compiler"
        ;;
        r)
            build_opt="rebuild"
            echo "rebuild compiler"
        ;;
        d)
            is_rm_build_dir=1
        ;;
        s)
            target_name=${OPTARG}
            build_opt="single_build"
            echo "build ${OPTARG}"
        ;;
        l)
            echo "cmake config"
                check_cmake_config
            exit 1
        ;;
    esac
done

#计时
start_time=$(date +%s.%N)

if [ "$build_opt" == "build" ]; then
    Build
elif [ "$build_opt" == "rebuild" ]; then
    Clean
    Build
elif [ "$build_opt" == "single_build" ]; then
    BuildTarget $target_name
else
    Clean
fi

# 记录结束时间
end_time=$(date +%s.%N)
# 计算脚本运行时间
runtime=$(echo "$end_time - $start_time" | bc)
rounded_runtime=$(printf "%.1f\n" $runtime)
# 输出运行时间
echo "运行时间为： $rounded_runtime 秒"

if [ $is_rm_build_dir -eq 1 ];then
    echo "rm ${current_path}/build_${compiler}"
    if [ -d "${current_path}/build_${compiler}" ];then
        rm -rf ${current_path}/build_${compiler}
    fi
fi

#package
# ${current_path}/package.sh ${compiler}