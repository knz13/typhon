#pragma once
#include <iostream>
#include <functional>
#include "general.h"
#include <unordered_map>
#include <vector>

struct HierarchyMenuObject {
    std::function<void()> onClick;
};

class GameObjectMiddleMan {
public:
    inline static std::function<int64_t()> createGameObjectAndGetID;
    inline static std::function<void(int64_t)> removeGameObjectFromID;
    inline static std::unordered_map<uint64_t,std::string> menuOptionsIDtoString;
    inline static std::unordered_map<std::string,std::function<void()>> menuOptionsStringToOnClick;
    inline static std::vector<std::function<void()>> staticDefaultsFuncs;
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

    static void onCallToRemoveObject(int64_t id){
        if(aliveObjects.find(id) == aliveObjects.end()){
            std::cout << "tried to delete object with invalid id = "  << id << std::endl;
            return;
        }
        std::cout << "removing object with id = " << id << std::endl;
        aliveObjects[id].get()->OnRemove();
        aliveObjects.erase(id);
    }

    double* _positionX;
    double* _positionY;
    double* _scalePointerX;
    double* _scalePointerY;
    int64_t identifier;
    
    virtual void OnRemove() {};
protected:


    virtual void Update(double dt) {}

    virtual void AI() {};

    virtual void PreDraw() {};

    virtual void PostDraw() {};

    virtual void FindFrame() {};

    virtual void SetDefaults() {};



private:
    

};