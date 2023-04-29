#pragma once
#include <iostream>
#include <functional>



class MonoManager {
public:

    inline static std::shared_ptr<MonoManager> instance = std::shared_ptr<MonoManager>();

    static MonoManager& getInstance() {
        if(!MonoManager::instance){
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