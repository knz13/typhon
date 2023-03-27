#pragma once
#include "gameobject.h"

class NullClassHelper {

};

template<typename Derived>
class AddObjectToHierarchy {
    static int m;

public:
    AddObjectToHierarchy()
    {
        (void)m;
    }
    
};

template<typename Derived>
int AddObjectToHierarchy<Derived>::m = ([](){
    GameObject::AddToHierarchyMenu<Derived>();
        
    return 0;
})();

template<typename T>
class UsesStaticDefaults { 

    static int m;

public:
    UsesStaticDefaults()
    {
        (void)m;
    }
};

template<typename T>
int UsesStaticDefaults<T>::m = ([](){
        
    GameObjectMiddleMan::staticDefaultsFuncs.push_back([](){T::SetStaticDefaults();});

    return 0;
})();