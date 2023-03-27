#pragma once
#include "gameobject.h"



template<typename Derived>
class AddObjectToHierarchy : public GameObject {
    static inline int m = ([](){
        
        GameObject::AddToHierarchyMenu<Derived>();
        

        return 0;
    })();

public:
    AddToObjectHierarchy()
    {
        (void)m;
    }
    
};

template<typename T>
class UsesStaticDefaults { 

    static inline int m = ([](){
        


        return 0;
    })();

public:
    UsesStaticDefaults()
    {
        (void)m;
    }

}
