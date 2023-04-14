#include "generic_reflection.h"





namespace Reflection {
    std::vector<std::function<void()>> InitializedStaticallyStorage::functionsFromDerivedClasses;
}