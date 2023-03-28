#pragma once
#include "reflection.h"


class NPC : public GameObject, 
    public Reflection::UsesStaticDefaults<NPC>,
    Reflection::AddToHierarchyMenu<NPC>
{
public:
    static void SetStaticDefaults() {
        std::cout << "Static default for npc!" << std::endl;
    };


protected:
    
    virtual void AI() {};
};