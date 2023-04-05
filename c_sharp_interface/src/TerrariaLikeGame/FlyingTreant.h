#pragma once
#include "../engine.h"


class FlyingTreant : public DerivedFromGameObject<FlyingTreant,
        Traits::HasUpdate<FlyingTreant>,
        Traits::UsesAI<FlyingTreant>,
        Traits::HasVelocity<FlyingTreant>,
        Traits::HasPosition,
        Traits::UsesSpriteAnimation<FlyingTreant>
    > {
private:
    enum ActionState
    {
        Following
    };

    enum FollowingAnimation
    {
        WingsTop,
        WingsMedium,
        WingsMediumLow,
        WingsLow
    };

    enum EyePositionAnimation
    {
        Left,
        TopLeft,
        Top,
        TopRight,
        Right,
        BottomRight,
        Bottom,
        BottomLeft
    };
    
    int AI_State = ActionState::Following;
    int frameCounter = 0;

public:




    void SetDefaults() {
        std::cout << "calling set defaults for flying treant!" << std::endl;
        width = 32;
        height = 32;
        scale = 2;
        //anchor = Anchor::Center;
        //angle = HelperFunctions::Radians(-45);
    }

    void Update(double dt) {
        std::cout << "my position now is " << position.x << "," << position.y << std::endl;
    }
    
    void AI() {
        if(Engine::IsKeyPressed(InputKey::D)) {
            position += Vector2f(1,0);
        }
        if(Engine::IsKeyPressed(InputKey::A)) {
            position += Vector2f(-1,0);
        }
        if(Engine::IsKeyPressed(InputKey::W)) {
            position += Vector2f(0,-1);
        }
        if(Engine::IsKeyPressed(InputKey::S)) {
            position += Vector2f(0,1);
        }

    }

    void FindFrame(int frameHeight) {
        Vector2f mousePos = Engine::GetMousePosition();

        float angleToEye = (float)(atan2(mousePos.y-position.y,mousePos.x-position.x) * 180/M_PI);	
        int eyeIndex = GetEyeIndex(angleToEye);

        switch(AI_State){
            case ActionState::Following:
                frameCounter++;
                if(frameCounter < 10) {
                    frame.y =  (eyeIndex * 4 + (int)FollowingAnimation::WingsTop) * frameHeight;
                }
                else if(frameCounter < 25) {
                    frame.y = (eyeIndex * 4 + (int)FollowingAnimation::WingsMedium)  * frameHeight;
                }
                else if(frameCounter < 40) {
                    frame.y = (eyeIndex * 4 + (int)FollowingAnimation::WingsMediumLow)  * frameHeight;
                }
                else if(frameCounter < 50) {
                    frame.y = (eyeIndex * 4 + (int)FollowingAnimation::WingsLow)  * frameHeight;
                }
                else if(frameCounter < 60) {
                    frame.y = (eyeIndex * 4 + (int)FollowingAnimation::WingsMediumLow) * frameHeight;
                }
                else if(frameCounter < 75) {
                    frame.y = (eyeIndex * 4 + (int)FollowingAnimation::WingsMedium)  * frameHeight;
                }
                else if(frameCounter < 90) {
                    frame.y = (eyeIndex * 4 + (int)FollowingAnimation::WingsTop)  * frameHeight;
                }
                else {
                    frameCounter = 0;
                }

                break;

        }
    };

    int GetEyeIndex(float angle) {
        if(angle > -22.5f && angle < 22.5f){
            return (int)EyePositionAnimation::Right;
        }
        else if(angle > 22.5f && angle < 67.5f){
            return (int)EyePositionAnimation::BottomRight;
        }
        else if(angle > 67.5f && angle <  112.5f){
            return (int)EyePositionAnimation::Bottom;
        }
        else if(angle > 112.5f && angle <  157.5f){
            return (int)EyePositionAnimation::BottomLeft;
        }
        else if(angle > -157.5f && angle <  -112.5f){
            return (int)EyePositionAnimation::TopLeft;
        }
        else if(angle > -112.5f && angle <  -67.5f){
            return (int)EyePositionAnimation::Top;
        }
        else if(angle > -67.5f && angle <  -22.5f){
            return (int)EyePositionAnimation::TopRight;
        }
        else if(angle > 157.5f || angle < -157.5f){
            return (int)EyePositionAnimation::Left;
        }

        return (int)EyePositionAnimation::Left;
    }

};