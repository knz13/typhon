#include "typhon.h"
//__BEGIN__CPP__IMPL__
#include <iostream>
#include <stdint.h>
#include "engine.h"
#include "rendering_engine.h"
#include "prefab/prefab.h"
//__INCLUDE__CREATED__CLASSES__
//__INCLUDE__INTERNALS__STATICALLY__

bool initializeCppLibrary() {
    
    //__INITIALIZE__CREATED__COMPONENTS__
    
    //__INITIALIZE__CREATED__CLASSES__

    //__INITIALIZE__INTERNALS__STATICALLY__

    Engine::Initialize();


    return true;    

}


void onMouseMove(double positionX, double positionY)
{
    EngineInternals::SetMousePosition(Vector2f(positionX,positionY));
}

void onKeyboardKeyDown(int64_t input)
{
    EngineInternals::PushKeyDown(input);
}

void onKeyboardKeyUp(int64_t input)
{
    EngineInternals::PushKeyUp(input);

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

void onRenderCall() {
    RenderingEngine::Render();
}

AliveObjectsArray getAliveObjects() {
    static std::vector<int64_t> ids;

    
    ids.clear();
    ids.reserve(Engine::NumberAlive());
    Engine::View([&](Object obj){
        ids.push_back(static_cast<int64_t>(obj.ID()));
    });


    AliveObjectsArray arr;
    arr.array = ids.data();
    arr.size = ids.size();


    return arr;

}

const char* getObjectNameByID(int64_t id) {
    static std::vector<char> temp = std::vector<char>();
    static const char* ptr = nullptr;

    temp.clear(); 

    Object obj = Engine::GetObjectFromID(id);
    std::cout << "tried getting object with id: " << id << " with result = "<< (obj.Valid() ? "valid" : "invalid") << std::endl;

    if(!obj.Valid()){
        temp.push_back('\0');
        ptr = temp.data();
        return ptr;
    }
    temp.reserve(obj.Name().size() + 1);
    memcpy(temp.data(),obj.Name().c_str(),obj.Name().size() + 1);
    ptr = temp.data();


    return ptr;
};


void removeObjectByID(int64_t id) {
    if(Engine::ValidateHandle(id)){
        Engine::RemoveObject(id);
    }
}


const char* getObjectSerializationByID(int64_t id) {

    static std::vector<char> temp = std::vector<char>();
    static const char* ptr = nullptr;

   /*  temp.clear(); 

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
 */

    return ptr;
}


char* getInstantiableClasses()
{
    static std::vector<char> classesJSON;
    static char* classesJSONChar = nullptr;

    classesJSON.clear();

    std::string jsonData = PrefabInternals::GetPrefabsJSON();

    classesJSON.resize(jsonData.size() + 1);
    
    memcpy(classesJSON.data(),jsonData.c_str(),jsonData.size() + 1);
    classesJSONChar = classesJSON.data();

    return classesJSONChar;
}

void createObjectFromClassID(int64_t classID)
{
    Engine::CreateObject();
}

bool isEngineInitialized() {
    return Engine::HasInitialized();
}


void passPlatformSpecificViewPointer(void* view) {
    
    RenderingEngine::PassPlatformSpecificViewPointer(view);
}

void* getPlatformSpecificPointer() {
    if(!Engine::HasInitialized()){
        return nullptr;
    }
    return RenderingEngine::GetPlatformSpecificPointer();
}



//__END__CPP__IMPL__