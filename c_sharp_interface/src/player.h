#pragma once
#include "npc.h"
#include "yael.h"




class InternalPlayerStorage {
public:
    static yael::event_sink<void(GameObject&)> OnPlayerCreated() {
        return {onPlayerCreatedLauncher};
    }

    static yael::event_sink<void(GameObject&)> OnPlayerRemoved() {
        return {onPlayerRemovedLauncher};
    }

private:
    static inline yael::event_launcher<void(GameObject&)> onPlayerCreatedLauncher;
    static inline yael::event_launcher<void(GameObject&)> onPlayerRemovedLauncher;
    
    template<typename... Args>
    friend class Player;   

};


template<typename... Derived>
class Player : public NPC<Player<Derived...>,Derived...>
    {
public:

    void SetDefaults() {
        std::cout << "called set defaults on player!" << std::endl;
        InternalPlayerStorage::onPlayerCreatedLauncher.EmitEvent(*this);
    };

    void OnRemove() {
        InternalPlayerStorage::onPlayerRemovedLauncher.EmitEvent(*this);
        
    }

   
    void Update(double dt) {
    }

private:
    


};

