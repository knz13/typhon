#pragma once
#include "monopp/mono_jit.h"
#include "monopp/mono_domain.h"
#include "shaderc/shaderc.h"
#include <iostream>
#include <functional>

template<typename T>
using deleted_unique_ptr = std::unique_ptr<T,std::function<void(T*)>>;

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
    deleted_unique_ptr<mono::mono_domain> _domain;
    bool _initialized = false;

public:
    MonoManager();

    bool initialized();



    

};