#pragma once

#include "../player.h"



class FlyingTreant : public Player<FlyingTreant>,
    Reflection::UsesTexture<FlyingTreant>,
    Reflection::AddToHierarchyMenu<FlyingTreant>,
    Reflection::HasKeyCallbacks<FlyingTreant>
    {


public:
    void Update(double dt)  {
    }

     void OnKeyPressed(InputKey key) override {
        std::cout << "on key pressed from flying treant position " << CurrentPosition().x << "," << CurrentPosition().y << "!" << std::endl;
        switch(key){
        case InputKey::A:
            Move(Vector2f(-2,0));
            break;
        case InputKey::D:
            Move(Vector2f(2,0));
            break;
        case InputKey::W:
            Move(Vector2f(0,2));
            break;
        case InputKey::S:
            Move(Vector2f(0,-2));
            break;
        default:
            break;
        }
    }



};