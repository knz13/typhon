#include "game_object_traits.h"



namespace Traits {

    std::vector<entt::entity> HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate;
    
}