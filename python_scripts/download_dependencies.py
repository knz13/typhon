

import os
import re

def download_dependencies():
    if not os.path.exists("src/vendor/entt"):
        os.system('git clone --recursive --branch v3.11.1 https://github.com/skypjack/entt/ src/vendor/entt')
    if not os.path.exists("src/vendor/yael"):
        os.system('git clone --recursive https://github.com/knz13/YAEL src/vendor/yael')
    if not os.path.exists("src/vendor/random"):
        os.system('git clone --recursive https://github.com/effolkronium/random src/vendor/random')
    if not os.path.exists("src/vendor/glm"):
        os.system('git clone --recursive https://github.com/g-truc/glm src/vendor/glm')
    if not os.path.exists("src/vendor/json"):
        os.system('git clone --recursive https://github.com/nlohmann/json src/vendor/json')
    if not os.path.exists("src/vendor/bgfx"):
        os.system('git clone --recursive https://github.com/bkaradzic/bgfx.cmake src/vendor/bgfx')
    if not os.path.exists("src/vendor/imgui"):
        os.system("git clone --recursive https://github.com/ocornut/imgui src/vendor/imgui")
    if not os.path.exists("src/vendor/glfw"):
        os.system('git clone --recursive https://github.com/glfw/glfw src/vendor/glfw')
    if not os.path.exists("src/vendor/ixwebsocket"):
        os.system('git clone --recursive https://github.com/machinezone/IXWebSocket src/vendor/ixwebsocket')
    if not os.path.exists("src/vendor/dylib"):
        os.system('git clone --recursive https://github.com/martin-olivier/dylib src/vendor/dylib')
    if not os.path.exists("src/vendor/crunch"):
        os.system('git clone --recursive https://github.com/johnfredcee/crunch src/vendor/crunch')

        for file in os.listdir("src/vendor/crunch/crunch"):
            with open(f'src/vendor/crunch/crunch/{file}','r', encoding='iso-8859-1') as f:
                file_data = f.read()
            
            if file != "packer.hpp":
                pattern = r'(?<![A-Za-z<>])Point(?![A-Za-z<>])'
                file_data = re.sub(pattern, 'Crunch::Point', file_data)
            else:
                file_data = file_data.replace("""struct Point
    {
        int x;
        int y;
        int dupID;
        bool rot;
    };""","""
    namespace Crunch {

        struct Point
        {
            int x;
            int y;
            int dupID;
            bool rot;
        };

    }
    """)        
                file_data = file_data.replace("vector<Point> points;","vector<Crunch::Point> points;")

            with open(f'src/vendor/crunch/crunch/{file}','w') as f:
                f.write(file_data)


    print("Finished downloading dependencies!")