#pragma once
#include <iostream>
#include <functional>
#include "general.h"
#include <unordered_map>



class GameObjectMiddleMan {
public:
    inline static std::function<GameObjectMiddleMan()> addGameObject;
    

    inline static std::unordered_map<int,GameObjectMiddleMan> aliveObjects;

    GameObjectMiddleMan();

    static void onCallUpdate(int64_t id,double dt) {
        std::cout << "Called onCallUpdate!" << std::endl;
    }

    static void onCallSetDefaults(int64_t id){
        std::cout << "Called onCallSetDefaults!" << std::endl;

    }

    static void onCallFindFrame(int64_t id){
        std::cout << "Called onCallFindFrame!" << std::endl;

    }

    static void onCallAI(int64_t id){
        std::cout << "Called onCallAI!" << std::endl;

    } 

    static void onCallPreDraw(int64_t id) {
        std::cout << "Called onCallPreDraw!" << std::endl;

    }

    static void onCallPostDraw(int64_t id){
        std::cout << "Called onCallPostDraw!" << std::endl;

    }

    double* _positionX;
    double* _positionY;
    double* _scalePointerX;
    double* _scalePointerY;
protected:

private:
    

};