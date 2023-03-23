#pragma once
#include "monopp/mono_jit.h"
#include "monopp/mono_domain.h"
#include <iostream>

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
    std::unique_ptr<mono::mono_domain> _domain;
    bool _initialized = false;

public:
    MonoManager();

    bool initialized();


};