#pragma once
#include "reflection.h"


class NPC : public GameObject, public UsesStaticDefaults<NPC>, public AddObjectToHierarchy<NPC> {
public:
    static void SetStaticDefaults() {
        std::cout << "Static default for npc!" << std::endl;
    };

};