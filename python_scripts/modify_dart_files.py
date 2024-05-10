

import os


def add_includes_to_dart():

    print("Adding includes to dart file")

    include_files = []

    for root, dirs, files in os.walk("cpp_library/"):
        if "vendor" in root:
            continue
        for file in files:
            if file.endswith(".h"):
                include_files.append(os.path.join(root, file))


    file_to_modify = "lib/features/engine_frontend/domain/engine_frontend_service.dart"

    with open(file_to_modify, "r") as file:
        file_data = file.readlines()
    
    with open(file_to_modify, "w") as file:
        writing_includes = False
        for line in file_data:
            if "// INIT_TYPHON_H" in line:
                file.write("// INIT_TYPHON_H\n")
                writing_includes = True
                for include_file in include_files:
                    file.write(r'#include "${path.join(applicationDir,"lib/' + include_file + '")}";\n')

            if "// END_TYPHON_H" in line:
                writing_includes = False
            if not writing_includes:
                file.write(line)

    print("Includes added to dart file")

def add_main_cpp_contents():
    print("Adding main cpp contents")
    
    main_cpp_file = "cpp_library/main.cpp"

    with open(main_cpp_file, "r") as file:
        main_cpp_file_data = file.readlines()

        index = 0

        for line in main_cpp_file_data:
            if "// INIT_MAIN_CPP" in line:
                break
            index += 1

        main_cpp_file_data = main_cpp_file_data[index + 1:]
    
    
    file_to_modify = "lib/features/engine_frontend/domain/engine_frontend_service.dart"

    with open(file_to_modify, "r") as file:
        file_data = file.readlines()
    
    with open(file_to_modify, "w") as file:
        writing_main_cpp = False
        for line in file_data:
            if "// INIT_MAIN_CPP" in line:
                file.write("// INIT_MAIN_CPP\n")
                writing_main_cpp = True
                file.writelines(main_cpp_file_data)
            if "// END_MAIN_CPP" in line:
                writing_main_cpp = False
            if not writing_main_cpp:
                file.write(line)

    print("Main cpp contents added")
    
