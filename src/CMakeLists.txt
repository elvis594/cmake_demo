

set (SRC_LISTS
    main.cpp
)
set (LIB_LISTS
    rt
)

AT_BUILD_TARGET(hello_world ${SRC_LISTS} ${LIB_LISTS})
