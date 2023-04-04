#pragma once
#include "gameobject_middle_man.h"
#include <chrono>
#include "entt/entt.hpp"
#include "reflection_checks.h"


struct GameObjectStats {
    float maxSpeedUp;
    float maxSpeedDown;
    float maxSpeedHorizontal;
    float hp;
    float damage;
    bool hasContactDamage = true;
    bool expires = false;
};

DEFINE_HAS_SIGNATURE(has_update_func,T::Update,void (T::*)(double));
DEFINE_HAS_SIGNATURE(has_set_defaults_func,T::SetDefaults, void (T::*)());
DEFINE_HAS_SIGNATURE(has_find_frame_func,T::FindFrame, void (T::*)());
DEFINE_HAS_SIGNATURE(has_pre_draw_func,T::PreDraw, void (T::*)());
DEFINE_HAS_SIGNATURE(has_post_draw_func,T::PostDraw, void (T::*)());
DEFINE_HAS_SIGNATURE(has_on_remove_func,T::OnRemove, void (T::*)());



class GameObject : public GameObjectMiddleMan {
public:

    

    void Move(Vector2f direction) {
        oldPos = this->position;
        position += direction;
    }
    
    void SetPosition(Vector2f position) {
        oldPos = this->position;
        this->position = position;
    }

    void AddVelocity(Vector2f velocity){
        oldVelocity = this->velocity;
        this->velocity += velocity;
    }
    
    void SetVelocity(Vector2f velocity){
        oldVelocity = this->velocity;
        this->velocity = velocity;
    }

    void AddScale(Vector2f addition) {
        oldScale = scale;
        scale += addition;
    }

    void SetScale(Vector2f newScale) {
        oldScale = scale;
        scale = newScale;
    }

    const Vector2f& CurrentPosition() {
        return position;
    };

    const Vector2f& CurrentVelocity() {
        return velocity;
    }

    const Vector2f& CurrentScale() {
        return scale;
    }

    const GameObjectStats& Stats() {
        return currentStats;
    }

private:
    

    

    GameObjectStats currentStats;


   
    Vector2f velocity = Vector2f(0,0);
    Vector2f oldPos = Vector2f(0,0);
    Vector2f oldScale = Vector2f(1,1);
    Vector2f oldVelocity = Vector2f(0,0);



    using GameObjectMiddleMan::className;
    using GameObjectMiddleMan::aliveObjects;
    using GameObjectMiddleMan::menuOptionsIDtoString;
    using GameObjectMiddleMan::menuOptionsStringToOnClick;
    using GameObjectMiddleMan::staticDefaultsFuncs;
    using GameObjectMiddleMan::onCallUpdate;
    using GameObjectMiddleMan::onCallPostDraw;
    using GameObjectMiddleMan::onCallPreDraw;
    using GameObjectMiddleMan::onCallSetDefaults;
    using GameObjectMiddleMan::createGameObjectAndGetID;
    using GameObjectMiddleMan::_positionX;
    using GameObjectMiddleMan::_positionY;
    using GameObjectMiddleMan::_scalePointerX;
    using GameObjectMiddleMan::_scalePointerY;
};



template<typename... DerivedClasses>
class DeriveFromGameObject : public GameObject {
private:
     template<typename A>
    void CallPreDraw() {
        if constexpr (has_pre_draw_func<A>::value) {
            (static_cast<A*>(this))->PreDraw();
        }
    }

    template<typename A>
    void CallUpdate(double dt) {
        if constexpr (has_update_func<A>::value) {
            (static_cast<A*>(this))->Update(dt);
        }
    }

    template<typename A>
    void CallPostDraw() {
        if constexpr (has_post_draw_func<A>::value) {
            (static_cast<A*>(this))->PostDraw();
        }
    }

    template<typename A>
    void CallSetDefaults() {
        if constexpr (has_set_defaults_func<A>::value) {
            (static_cast<A*>(this))->SetDefaults();
        }
    }

    template<typename A>
    void CallFindFrame() {
        if constexpr (has_find_frame_func<A>::value) {
            (static_cast<A*>(this))->FindFrame();
        }
    }

    template<typename A>
    void CallOnRemove() {
        if constexpr (has_on_remove_func<A>::value) {
            (static_cast<A*>(this))->OnRemove();
        }
    }

protected:
    void GameObjectOnRemove() override {

        (CallOnRemove<DerivedClasses>(),...);
    }


    void GameObjectUpdate(double dt) override {

        (CallUpdate<DerivedClasses>(dt),...);
    }

    void GameObjectPreDraw() override {
        
        (CallFindFrame<DerivedClasses>(),...);


        (CallPreDraw<DerivedClasses>(),...);
    };

    void GameObjectPostDraw() override {

        (CallPostDraw<DerivedClasses>(),...);
    };


    void GameObjectSetDefaults() override {

        (CallSetDefaults<DerivedClasses>(),...);
    };

};


