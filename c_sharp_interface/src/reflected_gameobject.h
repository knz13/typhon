#pragma once
#include "gameobject.h"



template<typename Derived>
class ReflectedGameObject : public GameObject {
    static inline int m = ([](){
        
        GameObject::AddToHierarchyMenu<Derived>();
        

        return 0;
    })();

public:
    ReflectedGameObject()
    {
        (void)m;
    }
    
};
