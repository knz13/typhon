#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "lua.h"
#include "editor_window.h"





extern "C" int loadScriptFromString(const char* string) {
    
    EditorWindow::show("called with '" + std::string(string) + "'");
    
    return 0;
}

void registerPrintToEditorWindow(PrintToEditorWindow func)
{
    EditorWindow::_printFunc = [=](std::string data){
        func(data.c_str());
    };
}

extern "C" void registerRemoveGameObjectFunction(RemoveGameObjectFunction func)
{
     Lua::removeGameObjectFunction = [=](int gameObjectID){
        return func(gameObjectID);
    };
}


extern "C" void registerAddGameObjectFunction(AddGameObjectFunction func) {
    Lua::addGameObjectFunction = [=](int parent){
        return func(parent);
    };
}

