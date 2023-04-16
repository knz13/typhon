#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "engine.h"
//__BEGIN__CPP__IMPL__
//__INCLUDE__CREATED__CLASSES__

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();
    
    //__INITIALIZE__CREATED__CLASSES__

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
        std::cout << "sending names: " << *(names.end() - 1) << std::endl;
        ids.push_back(id);
    }

    std::cout << "names size = " << names.size() << std::endl;

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

bool isEngineInitialized() {
    return Engine::HasInitialized();
}

//__END__CPP__IMPL__