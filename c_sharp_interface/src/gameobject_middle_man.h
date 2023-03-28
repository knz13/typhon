#pragma once
#include <iostream>
#include <functional>
#include "general.h"
#include <unordered_map>
#include <map>
#include <vector>

struct HierarchyMenuObject {
    std::function<void()> onClick;
};

class GameObjectMiddleMan {
public:
    inline static std::function<int64_t()> createGameObjectAndGetID;
    inline static std::function<void(int64_t)> removeGameObjectFromID;
    inline static std::function<void(int64_t)> attachPointersToObject;
    inline static std::unordered_map<uint64_t,std::string> menuOptionsIDtoString;
    inline static std::unordered_map<int64_t,GameObjectMiddleMan*> objectsToCallKeysCallback;
    inline static std::map<std::string,std::function<void(GameObjectMiddleMan*,InputKey)>> classesThatHaveHasKeyCallbacks;
    inline static std::unordered_map<std::string,std::function<void()>> menuOptionsStringToOnClick;
    inline static std::vector<std::function<void()>> staticDefaultsFuncs;
    inline static std::unordered_map<int64_t,std::unique_ptr<GameObjectMiddleMan>> aliveObjects;

    static void onCallUpdate(int64_t id,double dt) {
        //std::cout << "calling update!" << std::endl;
        *aliveObjects[id].get()->_positionX  = aliveObjects[id].get()->position.x;
        *aliveObjects[id].get()->_positionY  = aliveObjects[id].get()->position.y;
        *aliveObjects[id].get()->_scalePointerX = aliveObjects[id].get()->scale.x;
        *aliveObjects[id].get()->_scalePointerY = aliveObjects[id].get()->scale.y;
        
        aliveObjects[id].get()->GameObjectUpdate(dt);
    }

    static void onCallSetDefaults(int64_t id){
        aliveObjects[id].get()->GameObjectSetDefaults();
    }

    static void onCallPreDraw(int64_t id) {
        aliveObjects[id].get()->GameObjectPreDraw();
    }

    static void onCallPostDraw(int64_t id){
        aliveObjects[id].get()->GameObjectPostDraw();
    }

    static void onCallToRemoveObject(int64_t id);

    int64_t identifier;
    double* _positionX;
    double* _positionY;
    double* _scalePointerX;
    double* _scalePointerY;
    
    std::string className = "";
    std::string GetClassName() {
        return className;
    }
    virtual void OnRemove() {};
protected:
    Vector2f position = Vector2f(0,0);
    Vector2f scale = Vector2f(1,1);


    virtual void GameObjectUpdate(double dt) {}


    virtual void GameObjectPreDraw() {};

    virtual void GameObjectPostDraw() {};

    virtual void GameObjectSetDefaults() {};



private:
    

};