#pragma once
#include <iostream>
#include <functional>
#include "general.h"
#include <unordered_map>

struct HierarchyMenuObject {
    std::function<void()> onClick;
};

class GameObjectMiddleMan {
public:
    inline static std::function<int64_t()> createGameObjectAndGetID;
    inline static std::unordered_map<uint64_t,std::string> menuOptionsIDtoString;
    inline static std::unordered_map<std::string,std::function<void()>> menuOptionsStringToOnClick;

    inline static std::unordered_map<int64_t,std::unique_ptr<GameObjectMiddleMan>> aliveObjects;


    static void onCallUpdate(int64_t id,double dt) {
        aliveObjects[id].get()->Update(dt);
    }

    static void onCallSetDefaults(int64_t id){
        aliveObjects[id].get()->SetDefaults();
    }

    static void onCallFindFrame(int64_t id){
        aliveObjects[id].get()->FindFrame();
    }  

    static void onCallAI(int64_t id){
        aliveObjects[id].get()->AI();
    } 

    static void onCallPreDraw(int64_t id) {
        aliveObjects[id].get()->PreDraw();
    }

    static void onCallPostDraw(int64_t id){
        aliveObjects[id].get()->PostDraw();
    }

    double* _positionX;
    double* _positionY;
    double* _scalePointerX;
    double* _scalePointerY;
protected:

    virtual void Update(double dt) {}

    virtual void AI() {};

    virtual void PreDraw() {};

    virtual void PostDraw() {};

    virtual void FindFrame() {};

    virtual void SetDefaults() {};


private:
    

};