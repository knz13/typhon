/*
GENERATED FILE - DO NOT MODIFY!
*/
#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "engine.h"
#include "TerrariaLikeGame/FlyingTreant.h"

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();
    
    Engine::Initialize();
    

    return true;    

}


void onMouseMove(double positionX, double positionY)
{
    EngineInternals::SetMousePosition(Vector2f(positionX,positionY));
}

void onKeyboardKeyDown(int64_t input)
{
    Engine::PushKeyDown(input);
}

void onKeyboardKeyUp(int64_t input)
{
    Engine::PushKeyUp(input);

}

void onUpdateCall(double dt)
{
    Engine::Update(dt);


}

void passProjectPath(const char *path)
{
    HelperStatics::projectPath = std::string(path);

}


void attachEnqueueRender(EnqueueObjectRender func)
{
    EngineInternals::enqueueRenderFunc = [=](double x,double y,int64_t width,int64_t height,int64_t imageX,int64_t imageY,double anchorX,double anchorY,double scale,double angle){
        func(x,y,width,height,imageX,imageY,anchorX,anchorY,scale,angle);
    };
}

void unloadLibrary()
{
    Engine::Unload();

}

ClassesArray getInstantiableClasses()
{
    static std::vector<int64_t> ids;
    static std::vector<const char*> names;

    ids.clear();
    names.clear();

    for(const auto& [id,name] : GameObject::GetInstantiableClassesIDsToNames()){
        names.push_back(name.c_str());
        ids.push_back(id);
    }

    ClassesArray arr;

    arr.array = ids.data();
    arr.size = ids.size();
    arr.stringArray = names.data();
    arr.stringArraySize = names.size();
    return arr;
}

void createObjectFromClassID(int64_t classID)
{
    Engine::CreateNewGameObject(classID);
}
