#include "mono_manager.h"
#include "shaderc/env.h"
#include "shaderc_private.h"

MonoManager::MonoManager() {


};

bool MonoManager::initialized()  {

    return _initialized;
}