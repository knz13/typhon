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

  # adding dylib library

  list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/dylib/include)

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

    if(TYPHON_DEBUG)
      add_compile_definitions(TYPHON_DEBUG=1)

      # adding ixwebsocket library

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/ixwebsocket)

      list(APPEND typhon_LIBRARIES ixwebsocket)

    endif()
    
    # --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources

      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/engine.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/utils/general.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/utils/color.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/utils/generic_reflection.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/entity_component_system/ecs_registry.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/auxiliary_libraries/shader_compiler.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/auxiliary_libraries_helpers/auxiliary_library.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/rendering_engine.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/object/object.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/object/object_handle.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/prefab/prefab.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/component/make_component.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/features/project_selection/project_selection_canvas.cpp)
      #list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/typhon_generated.cpp)
      #list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/main.cpp)
      
      if(APPLE)
        list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine/platform_specific/MacOS/metal_rendering_engine.mm)
      endif()
    # creating target


    

    add_library(typhon
        ${typhon_SOURCE_FILES}
        ${PROJECT_SOURCE_DIR}/main.cpp
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
    
      
