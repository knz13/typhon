cmake_minimum_required(VERSION 3.16)
#project name
project(project_typhon)

#adding extra cmake libs

include(ExternalProject)
include(FetchContent)



option(TYPHON_RUN_TESTS "Run Tests" OFF)
option(TYPHON_RENDER_2D "Use 2D Rendered" ON)

if(TYPHON_RENDER_2D)
add_compile_definitions(TYPHON_RENDER_2D=1)
endif()

SET(FETCHCONTENT_QUIET FALSE)


# --------------------- External Libraries ------------------------

    # adding glfw library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/glfw) 
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/glfw/include/)

    # adding entt library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/entt)

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/entt/single_include/)  

    # adding yael library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/yael)

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/yael/include)

    # adding random library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/random) 
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/random/include)

    # adding glm library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/glm)  
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/glm/)

    # adding crunch library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/crunch) 
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/crunch/crunch/)  

    # adding bgfx library

    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/bgfx) 
    list(APPEND typhon_LIBRARIES bgfx bx bimg libcrunch glfw) 
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/bgfx/bgfx/include)
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/bgfx/bx/include)
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/bgfx/bimg/include) 

    # adding json library

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/json/single_include) 

    # adding dylib library

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/dylib/include)
    
    # adding ImGui Library

    # glob imgui files


    list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/imgui.cpp)

    list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/imgui_draw.cpp)

    list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/imgui_widgets.cpp)

    list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/imgui_tables.cpp)

    # platform specific backends

    if(WIN32)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/backends/imgui_impl_glfw.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/backends/imgui_impl_dx11.cpp)
      list(APPEND typhon_LIBRARIES d3d11)
    endif()

    if(APPLE)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/backends/imgui_impl_glfw.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/backends/imgui_impl_metal.mm)
    endif()

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/)

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/imgui/backends/)
    
    
    # --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources

      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/engine.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/utils/general.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/entity_component_system/ecs_registry.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/utils/generic_reflection.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/auxiliary_libraries/shader_compiler.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/auxiliary_libraries_helpers/auxiliary_library.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/rendering_engine.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/object/object.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/object/object_handle.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/prefab/prefab.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/component/make_component.cpp)
      #list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/typhon_generated.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/main.cpp)
    # creating target


    add_executable(typhon
        ${typhon_SOURCE_FILES}
    )


    # setting c++ standard
    set_target_properties(typhon PROPERTIES
        CXX_STANDARD 20
    )

    # setting c standard

    set_target_properties(typhon PROPERTIES
        C_STANDARD 20
    )
    # adding include paths 

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src)

      target_include_directories(typhon PUBLIC ${typhon_INCLUDES})

      
      # adding internal libraries
      
      target_link_libraries(typhon PUBLIC ${typhon_LIBRARIES})
      
      #get_target_property(TYPHON_INCLUDES_FINAL typhon INCLUDE_DIRECTORIES)
        
      #foreach(X IN LISTS TYPHON_INCLUDES_FINAL)
      #  message(STATUS "target_include_directories(SOMETHING PUBLIC ${X})")
      #endforeach()
      
      #message(STATUS "BEGIN__INCLUDE__DIRS ${TYPHON_INCLUDES_FINAL};${} END__INCLUDE__DIRS")
    

#tests

if(TYPHON_RUN_TESTS)
  add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/catch2)
  add_compile_definitions(__TYPHON_TESTING__=1)

  list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/src/vendor/catch2/extras)

  include(CTest)
  include(Catch)

  # Creating shared test library to be loaded as dll/dylib
  add_library(typhon_shared_tests_lib SHARED tests/shared_library_code.cpp)

  set_target_properties(typhon_shared_tests_lib PROPERTIES
      CXX_STANDARD 20
  )

  set_target_properties(typhon_shared_tests_lib PROPERTIES
  C_STANDARD 20
  )
  
  target_link_libraries(typhon_shared_tests_lib PRIVATE typhon)

  # Creating test to load dll/dylib created above
  add_executable(typhon_shared_tests 
    tests/shared_library_test.cpp  

  )

  set_target_properties(typhon_shared_tests PROPERTIES
      CXX_STANDARD 20
  )

  set_target_properties(typhon_shared_tests PROPERTIES
      C_STANDARD 20
  )

  add_dependencies(typhon_shared_tests typhon_shared_tests_lib)

  # Adding main engine tests
  add_executable(typhon_tests 
    tests/main_test.cpp
  )

  set_target_properties(typhon_tests PROPERTIES
      CXX_STANDARD 20
  )

  # setting c standard

  set_target_properties(typhon_tests PROPERTIES
      C_STANDARD 20
  )

  target_link_libraries(typhon_tests PRIVATE Catch2::Catch2WithMain)
  target_link_libraries(typhon_tests PRIVATE typhon)
  
  catch_discover_tests(typhon_shared_tests)
  catch_discover_tests(typhon_tests)

endif()