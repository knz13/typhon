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

void attachEnqueueOnChildrenChanged(OnChildrenChangedFunc func) {
    EngineInternals::onChildrenChangedFunc = [=](){
        func();
    };
}

void unloadLibrary()
{
    Engine::Unload();

}

AliveObjectsArray getAliveObjects() {
    static std::vector<int64_t> ids;


    ids.clear();
    auto view = Engine::View();
    ids.reserve(view.size());
    for(const auto& obj : view) {
        ids.push_back(obj->Handle());
    }


    AliveObjectsArray arr;
    arr.array = ids.data();
    arr.size = ids.size();


    return arr;

}

const char* getObjectNameByID(int64_t id) {
    static std::vector<char> temp = std::vector<char>();
    static const char* ptr = nullptr;

    temp.clear(); 

    GameObject* obj = Engine::GetObjectFromID(id);
    std::cout << "tried getting object with id: " << id << " with result ptr = "<< (void*)obj << std::endl;

    if(obj == nullptr){
        temp.push_back('\0');
        ptr = temp.data();
        return ptr;
    }
    temp.reserve(obj->Name().size() + 1);
    memcpy(temp.data(),obj->Name().c_str(),obj->Name().size() + 1);
    ptr = temp.data();


    return ptr;
};


void removeObjectByID(int64_t id) {
    if(Engine::ValidateHandle(id)){
        Engine::RemoveGameObject(id);
    }
}


const char* getObjectSerializationByID(int64_t id) {

    static std::vector<char> temp = std::vector<char>();
    static const char* ptr = nullptr;

    temp.clear(); 

    GameObject* obj = Engine::GetObjectFromID(id);
    
    if(obj == nullptr){
        temp.reserve(3);
        temp.push_back('{');
        temp.push_back('}');
        temp.push_back('\0');
        ptr = temp.data();
        return ptr;
    }


    json jsonData;
    obj->Serialize(jsonData);

    std::string jsonDataStr = jsonData.dump();

    temp.reserve(jsonDataStr.size() + 1);
    memcpy(temp.data(),jsonDataStr.c_str(),jsonDataStr.size() + 1);
    ptr = temp.data();


    return ptr;
}


ClassesArray getInstantiableClasses()
{
    static std::vector<int64_t> ids;
    static std::vector<std::vector<char>> names;
    static std::vector<const char*> names_char;

    ids.clear();
    names.clear();
    names_char.clear();

    for(const auto& [id,name] : GameObject::GetInstantiableClassesIDsToNames()) {
        std::vector<char> temp(name.size() + 1);
        memcpy(temp.data(),name.c_str(),name.size() + 1);
        names.push_back(temp);
        std::cout << "sending names: " << (*(names.end() - 1)).data() << std::endl;
        std::cout << "address = " << (void*)((*(names.end() - 1)).data()) << std::endl;
        ids.push_back(id);
        names_char.push_back((*(names.end() - 1)).data());
    }

    std::cout << "names size = " << names.size() << std::endl;

    ClassesArray arr;

    arr.array = ids.data();
    arr.size = ids.size();
    arr.stringArray = names_char.data();
    arr.stringArraySize = names_char.size();
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