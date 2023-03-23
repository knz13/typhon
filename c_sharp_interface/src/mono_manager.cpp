#include "mono_manager.h"



MonoManager::MonoManager()  {

    if(!mono::init("mono",true)){
        _initialized = false;
        return;
    }

    _domain = std::unique_ptr<mono::mono_domain>(new mono::mono_domain("typhon_domain"));


};

bool MonoManager::initialized()  {
    return _initialized;
}