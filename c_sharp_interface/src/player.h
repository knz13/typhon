#pragma once
#include "npc.h"
#include "yael.h"


class Player : public NPC,
    Reflection::UsesStaticDefaults<Player>,
    Reflection::AddToHierarchyMenu<Player>,
    Reflection::HasKeyCallbacks<Player>
    {
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

    void OnKeyPressed(InputKey key) override {
        //std::cout << "on key pressed position " << position.x << "," << position.y << "!" << std::endl;
        switch(key){
        case InputKey::A:
            position.x -= 2;
            break;
        case InputKey::D:
            position.x += 2;
            break;
        case InputKey::W:
            position.y += 2;
            break;
        case InputKey::S:
            position.y -= 2;
            break;
        default:
            break;
        }
    }

private:
    static inline yael::event_launcher<void(Player&)> onPlayerCreatedLauncher;
    static inline yael::event_launcher<void(Player&)> onPlayerRemovedLauncher;


};