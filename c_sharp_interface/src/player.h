#pragma once
#include "npc.h"



class Player : public NPC, UsesStaticDefaults<Player> {
public:

    static void SetStaticDefaults() {
        std::cout << "Static default for player!!" << std::endl;

        
    };

    void SetDefaults() override {


    };

};