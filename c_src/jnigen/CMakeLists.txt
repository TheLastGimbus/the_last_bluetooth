# jni_native_build (Build with jni:setup. Do not delete this line.)

# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(the_last_bluetooth VERSION 0.0.1 LANGUAGES C)

add_library(the_last_bluetooth SHARED
  "./the_last_bluetooth.c"
)

set_target_properties(the_last_bluetooth PROPERTIES
  OUTPUT_NAME "the_last_bluetooth"
)

target_compile_definitions(the_last_bluetooth PUBLIC DART_SHARED_LIB)

if(WIN32)
	set_target_properties(${TARGET_NAME} PROPERTIES
		LINK_FLAGS "/DELAYLOAD:jvm.dll")
endif()

if (ANDROID)
	target_link_libraries(the_last_bluetooth log)
else()
	find_package(Java REQUIRED)
	find_package(JNI REQUIRED)
	include_directories(${JNI_INCLUDE_DIRS})
	target_link_libraries(the_last_bluetooth ${JNI_LIBRARIES})
endif()
