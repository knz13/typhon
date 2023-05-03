cmake_minimum_required(VERSION 3.16)

#adding extra cmake libs

include(ExternalProject)
include(FetchContent)


#project name
project(project_typhon)

option(TYPHON_RUN_TESTS "Run Tests" OFF)




SET(FETCHCONTENT_QUIET FALSE)

# --------------------- Repository declarations ------------------------
# repository download and settings for mono...


    #FetchContent_Declare(MONO
    #    GIT_REPOSITORY https://github.com/volcoma/monopp
    #    GIT_TAG origin/master
    #    SOURCE_DIR ${PROJECT_SOURCE_DIR}/vendor/mono
    #  
    #) 
    

    #FetchContent_MakeAvailable(MONO)
    # includes for target typhon...

      #list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/vendor/mono/)

    # libraries for target typhon...
    
   # list(APPEND typhon_LIBRARIES monopp)


    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/entt)
    
    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/yael)
    
    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/random)
    
    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/glm)
    
    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/crunch)
        
    if(APPLE)
      add_compile_definitions(OBJC_DEBUG_MISSING_POOLS=1)

      add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/metal-cpp)
    
      list(APPEND typhon_LIBRARIES METAL_CPP)

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/metal-cpp/metal-cpp/)

      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/macos/macos_engine.cpp)
    endif()
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/entt/single_include/)
    
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/yael/include)
  
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/random/include)
    
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/glm/)
    

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/crunch/crunch/)
    list(APPEND typhon_LIBRARIES libcrunch)


    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/json/single_include)
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/dylib/include)
    
    # --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources

      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/general.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/game_object.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/ecs_registry.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/game_object_traits.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/generic_reflection.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/shader_compiler.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/rendering_engine.cpp)
    # creating target


    add_library(typhon

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