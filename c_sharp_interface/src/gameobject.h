#pragma once
#include "gameobject_middle_man.h"


class GameObject : public GameObjectMiddleMan {

private:
    using GameObjectMiddleMan::_positionX;
    using GameObjectMiddleMan::_positionY;
    using GameObjectMiddleMan::_scalePointerX;
    using GameObjectMiddleMan::_scalePointerY;
};