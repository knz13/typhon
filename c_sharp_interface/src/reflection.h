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


template<typename T>
class HasKeyCallbacks { 


    static int m;
public:
    virtual void OnKeyPressed(InputKey key){

    }

    HasKeyCallbacks() {
        (void)m;
    }

};

template<typename T>
int HasKeyCallbacks<T>::m = [] (){
    std::cout << "Registered class as having key callbacks " << HelperFunctions::GetClassNameString<T>() << std::endl;
    GameObjectMiddleMan::classesThatHaveHasKeyCallbacks[HelperFunctions::GetClassNameString<T>()] = [](GameObjectMiddleMan* obj,InputKey k){
        static_cast<T*>(obj)->OnKeyPressed(k);
    };

    return 0;
}();