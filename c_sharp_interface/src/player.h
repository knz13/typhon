#pragma once
#include "npc.h"
#include "yael.h"


class Player : public NPC, UsesStaticDefaults<Player>,AddObjectToHierarchy<Player>{
public:
    static yael::event_sink<void(Player&)> OnPlayerCreated() {
        return {onPlayerCreatedLauncher};
    }

    static yael::event_sink<void(Player&)> OnPlayerRemoved() {
        return {onPlayerRemovedLauncher};
    }

    static void SetStaticDefaults() {
        std::cout << "Static default for player!!" << std::endl;

        
    };

    void SetDefaults() override {
        onPlayerCreatedLauncher.EmitEvent(*this);

    };

    void OnRemove() override {
        onPlayerRemovedLauncher.EmitEvent(*this);

    }

private:
    static inline yael::event_launcher<void(Player&)> onPlayerCreatedLauncher;
    static inline yael::event_launcher<void(Player&)> onPlayerRemovedLauncher;


};