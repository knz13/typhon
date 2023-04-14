#pragma once
#include "shaderc/shaderc.h"
#include <iostream>
#include <functional>



class MonoManager {
public:

    inline static std::shared_ptr<MonoManager> instance = std::shared_ptr<MonoManager>();

    static MonoManager& getInstance() {
        if(!MonoManager::instance){
            std::cout << "initializing mono!" << std::endl;
            MonoManager::instance = std::shared_ptr<MonoManager>(new MonoManager());
        }  
        return *MonoManager::instance.get();
    }


private:
    bool _initialized = false;

public:
    MonoManager();

    bool initialized();



    

};