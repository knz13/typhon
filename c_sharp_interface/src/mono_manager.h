#pragma once
#include "shaderc/shaderc.h"
#include <iostream>
#include <functional>



class MonoManager {
public:

    inline static std::unique_ptr<MonoManager> instance = std::unique_ptr<MonoManager>();

    static MonoManager& getInstance() {
        if(!MonoManager::instance){
            std::cout << "initializing mono!" << std::endl;
            MonoManager::instance = std::unique_ptr<MonoManager>(new MonoManager());
        }  
        return *MonoManager::instance.get();
    }


private:
    bool _initialized = false;

public:
    MonoManager();

    bool initialized();



    

};