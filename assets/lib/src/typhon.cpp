#include "typhon.h"
//__BEGIN__CPP__IMPL__
#include <iostream>
#include <stdint.h>
#include "engine.h"
#include "rendering_engine.h"
#include "prefab/prefab.h"
#include "auxiliary_libraries/model_loader.h"
#include "component/make_component.h"
//__INCLUDE__CREATED__CLASSES__
//__INCLUDE__INTERNALS__STATICALLY__

bool initializeCppLibrary()
{

    //__INITIALIZE__CREATED__COMPONENTS__

    //__INITIALIZE__CREATED__CLASSES__

    //__INITIALIZE__INTERNALS__STATICALLY__

    Engine::Initialize();

    return true;
}

void onMouseMove(double positionX, double positionY)
{
    EngineInternals::SetMousePosition(Vector2f(positionX, positionY));
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
    EngineInternals::enqueueRenderFunc = [=](double x, double y, int64_t width, int64_t height, int64_t imageX, int64_t imageY, double anchorX, double anchorY, double scale, double angle)
    {
        func(x, y, width, height, imageX, imageY, anchorX, anchorY, scale, angle);
    };
}

void attachOnChildrenChanged(OnChildrenChangedFunc func)
{
    EngineInternals::onChildrenChangedFunc = [=]()
    {
        func();
    };
}

void unloadLibrary()
{
    Engine::Unload();
}

void onRenderCall()
{
    RenderingEngine::Render();
}

AliveObjectsArray getAliveParentlessObjects()
{
    static std::vector<int64_t> ids;

    ids.clear();
    ids.reserve(Engine::NumberAlive());
    Engine::View<Typhon::ObjectInternals::ParentlessTag>([&](Typhon::Object obj)
                                                         { ids.push_back(static_cast<int64_t>(obj.ID())); });

    AliveObjectsArray arr;
    arr.array = ids.data();
    arr.size = ids.size();

    return arr;
}

const char *getObjectNameByID(int64_t id)
{
    static std::vector<char> temp = std::vector<char>();
    static const char *ptr = nullptr;

    temp.clear();

    Typhon::Object obj = Engine::GetObjectFromID(id);

    if (!obj.Valid())
    {
        temp.push_back(' ');
        ptr = temp.data();
        return ptr;
    }
    temp.reserve(obj.Name().size() + 1);
    memcpy(temp.data(), obj.Name().c_str(), obj.Name().size() + 1);
    ptr = temp.data();

    return ptr;
};

void removeObjectByID(int64_t id)
{
    if (Engine::ValidateHandle(id))
    {
        Engine::RemoveObject(id);
    }
}

bool setObjectName(int64_t objectID, const char *str, int64_t size)
{
    if (Engine::ValidateHandle(objectID))
    {
        Engine::GetObjectFromID(objectID).SetName(std::string(str, size));
        EngineInternals::onChildrenChangedFunc();
        return true;
    }
    return false;
}

const char *getObjectSerializationByID(int64_t id)
{

    static std::vector<char> temp = std::vector<char>();
    static const char *ptr = nullptr;

    temp.clear();

    Typhon::Object obj = Engine::GetObjectFromID(id);

    if (!obj.Valid())
    {
        std::cout << "object not valid!" << std::endl;
        temp.resize(3);
        temp.push_back('{');
        temp.push_back('}');
        ptr = temp.data();
        return ptr;
    }

    json jsonData;
    obj.Serialize(jsonData);

    std::string jsonDataStr = jsonData.dump();

    temp.resize(jsonDataStr.size() + 1);
    memcpy(temp.data(), jsonDataStr.c_str(), jsonDataStr.size() + 1);
    ptr = temp.data();

    return ptr;
}

const char *getObjectInspectorUIByID(int64_t id)
{
    static std::vector<char> temp = std::vector<char>();
    static const char *ptr = nullptr;

    temp.clear();

    Typhon::Object obj = Engine::GetObjectFromID(id);

    if (!obj.Valid())
    {
        std::cout << "object not valid!" << std::endl;
        temp.push_back('{');
        temp.push_back('}');
        ptr = temp.data();
        return ptr;
    }

    json jsonData = json::object();
    jsonData["name"] = obj.Name();
    jsonData["components"] = json::array();
    obj.ForEachComponent([&](Typhon::Component &comp)
                         { jsonData["components"].push_back(comp.InternalBuildEditorUI().GetJSON()); });

    std::string jsonDataStr = jsonData.dump();

    temp.resize(jsonDataStr.size() + 1);
    memcpy(temp.data(), jsonDataStr.c_str(), jsonDataStr.size() + 1);
    ptr = temp.data();

    return ptr;
}

const char *getObjectChildTree(int64_t id)
{
    static std::vector<char> temp = std::vector<char>();
    static const char *ptr = nullptr;

    temp.clear();

    Typhon::Object obj = Engine::GetObjectFromID(id);

    if (!obj.Valid())
    {
        std::cout << "object not valid!" << std::endl;
        temp.resize(3);
        temp.push_back('{');
        temp.push_back('}');
        ptr = temp.data();
        return ptr;
    }

    json jsonData = json::object();
    obj.ExecuteForEveryChildInTree([&](Typhon::Object &tempObj)
                                   {
        if(tempObj.NumberOfChildren() > 0){
            jsonData[std::to_string(static_cast<int64_t>(tempObj.ID()))] = json::array();
            for(auto entity : tempObj.Children()){
                jsonData[std::to_string(static_cast<int64_t>(tempObj.ID()))].push_back(static_cast<int64_t>(entity));
            }
        } },
                                   true);

    std::string jsonDataStr = jsonData.dump();

    temp.resize(jsonDataStr.size() + 1);
    memcpy(temp.data(), jsonDataStr.c_str(), jsonDataStr.size() + 1);
    ptr = temp.data();

    return ptr;
}

char *getInstantiableClasses()
{
    static std::vector<char> classesJSON;
    static char *classesJSONChar = nullptr;

    classesJSON.clear();

    std::string jsonData = PrefabInternals::GetPrefabsJSON();

    classesJSON.resize(jsonData.size() + 1);

    memcpy(classesJSON.data(), jsonData.c_str(), jsonData.size() + 1);
    classesJSONChar = classesJSON.data();

    return classesJSONChar;
}

char *getInstantiableComponents()
{
    static std::vector<char> classesJSON;
    static char *classesJSONChar = nullptr;

    classesJSON.clear();

    std::string jsonData = ComponentInternals::GetDefaultComponentsJSON();

    classesJSON.resize(jsonData.size() + 1);

    memcpy(classesJSON.data(), jsonData.c_str(), jsonData.size() + 1);
    classesJSONChar = classesJSON.data();

    return classesJSONChar;
}

void createObjectFromClassID(int64_t classID)
{
    PrefabInternals::CreatePrefabFromID(classID);
}

bool isEngineInitialized()
{
    return Engine::HasInitialized();
}
bool isRenderingEngineInitialized()
{
    return RenderingEngine::HasInitialized();
}

void passPlatformSpecificViewPointer(void *window)
{

    RenderingEngine::PassPlatformSpecificViewPointer(window);
}

void *getPlatformSpecificPointer()
{
    if (!Engine::HasInitialized())
    {
        return nullptr;
    }
    return RenderingEngine::GetPlatformSpecificPointer();
}

bool setObjectParent(int64_t objectID, int64_t parentID)
{
    if (!Engine::ValidateHandle(objectID) || !Engine::ValidateHandle(parentID))
    {
        return false;
    }

    Typhon::Object(Engine::IDFromHandle(objectID)).SetParent(Typhon::Object(Engine::IDFromHandle(parentID)));
    return true;
}
bool removeObjectFromParent(int64_t objectID)
{
    if (!Engine::ValidateHandle(objectID))
    {
        return false;
    }
    Typhon::Object(Engine::IDFromHandle(objectID)).RemoveFromParent();
    return true;
}

char *getContextMenuForFilePath(const char *filePath, int64_t size)
{
    static std::vector<char> responseJSON;
    static char *responsePtr = nullptr;

    responseJSON.clear();

    responseJSON.push_back('[');
    responseJSON.push_back(']');

    responsePtr = responseJSON.data();

    return responsePtr;
}

void loadModelFromPath(const char *filePath, int64_t size)
{
    std::string path = std::string(filePath, size);

    std::cout << ModelLoader::LoadModelFromFile(path).meshes.size() << std::endl;
}

void addComponentToObject(int64_t objectID, int64_t componentClassID)
{
    if (Engine::ValidateHandle(objectID))
    {
        Typhon::Object obj = Engine::GetObjectFromID(objectID);
        auto componentMeta = entt::resolve(entt::hashed_string(std::to_string(componentClassID).c_str()));
        if (componentMeta)
        {
            auto func = componentMeta.func(entt::hashed_string(std::string("AddComponent").c_str()));
            if (func)
            {
                func.invoke({}, obj.ID());
                EngineInternals::onChildrenChangedFunc();
            }
        }
        else
        {
            std::cout << "Could not find component with id => " << componentClassID << std::endl;
        }
    }
}

//__END__CPP__IMPL__