#include "make_component.h"

namespace Typhon
{

    std::vector<entt::id_type> ComponentInternals::ComponentStatics::componentTypes;
    std::map<std::string, int64_t> ComponentInternals::ComponentStatics::defaultComponentMenuMap;

    std::string ComponentInternals::GetDefaultComponentsJSON()
    {
        json prefabs;
        for (const auto &[path, hash] : ComponentStatics::defaultComponentMenuMap)
        {
            auto strVector = HelperFunctions::SplitString(path, "/");
            std::string componentName = strVector.back();
            json *jsonPtr = &prefabs;
            for (auto &str : strVector)
            {
                if (str == componentName)
                {
                    break;
                }
                if ((*jsonPtr).find(str) == (*jsonPtr).end())
                {
                    (*jsonPtr)[str] = json::object();
                }
                jsonPtr = &(*jsonPtr)[str];
            }
            (*jsonPtr)[componentName] = hash;
        }

        return prefabs.dump();
    }

}
