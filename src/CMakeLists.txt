CMAKE_MINIMUM_REQUIRED (VERSION 3.10)

SET(CMAKE_EXECUTABLE_LIBRARY_PREFIX)
SET(CMAKE_EXECUTABLE_LIBRARY_SUFFIX)
project(robustserial)

#if (APPLE)
#set(CMAKE_BUILD_TYPE Debug)
#set(CMAKE_CXX_FLAGS_RELEASE "-O0 -ggdb -g3 -fpic")
#set(CMAKE_CXX_FLAGS_DEBUG   "-O0 -ggdb -g3 -fpic")
#set(CMAKE_C_FLAGS_DEBUG     "-O0 -ggdb -g3 -fpic -shared -Wl,--add-stdcall-alias")
#set(CMAKE_C_FLAGS_RELEASE   "-O0 -fpic -shared -Wl,--add-stdcall-alias")
#else(APPLE)
set(CMAKE_CXX_FLAGS_RELEASE "-O0 -ggdb -g3")
set(CMAKE_CXX_FLAGS_DEBUG   "-O0 -ggdb -g3")
set(CMAKE_C_FLAGS_DEBUG     "-O0 -ggdb -g3")
set(CMAKE_C_FLAGS_RELEASE   "-O0")
#endif(APPLE)

add_definitions(-DYY_NO_INPUT=1)

set(LIB_ROBUSTSERIAL_SOURCES  robust_serial.cpp)
set(LIB_ROBUSTSERIAL_HEADERS  robust_serial.h) 

set(PROJECT_SOURCE_FILES ${LIB_ROBUSTSERIAL_SOURCES})

target_link_libraries(robustserial serial)
add_library(robustserial ${LIB_ROBUSTSERIAL_SOURCES} ${LIB_ROBUSTSERIAL_HEADERS})

install(TARGETS robustserial DESTINATION lib)
install(FILES ${LIB_ROBUSTSERIAL_HEADERS} DESTINATION include/robustserial)


