#include "generic_reflection.h"





namespace Reflection {
    std::map<int64_t,std::function<void()>> InitializedStaticallyStorage::functionsFromDerivedClasses;
}