#pragma once
#include "../general.h"
#include "../generic_reflection.h"
#include <sstream>

DEFINE_HAS_SIGNATURE(has_initialize_library, T::InitializeLibrary, void (*)());
DEFINE_HAS_SIGNATURE(has_unload_library, T::UnloadLibrary, void (*)());
DEFINE_HAS_SIGNATURE(has_get_library_name, T::GetLibraryName, std::string (*)());

class AuxiliaryLibrariesInternals
{
public:
    static std::vector<std::function<void()>> initializeFunctions;
    static std::vector<std::function<void()>> unloadFunctions;
};

template <typename T>
class AuxiliaryLibrary : public Reflection::IsInitializedStatically<AuxiliaryLibrary<T>>
{
public:
    static void InitializeStatically()
    {
        static std::string withName = ([]()
                                       {
            std::stringstream ss;
            ss <<    "with name " << T::GetLibraryName() << " and c++ class " << HelperFunctions::GetClassNameString<T>();

            return ss.str(); })();
        if constexpr (has_get_library_name<T>::value)
        {
            if constexpr (has_initialize_library<T>::value)
            {
                if constexpr (has_unload_library<T>::value)
                {
                    AuxiliaryLibrariesInternals::initializeFunctions.push_back([]()
                                                                               {
                                                                            try
                                                                            {
                                                                                auxiliaryLibraryLib = std::make_shared<dylib>((std::filesystem::path(HelperStatics::projectPath) / std::filesystem::path("build")).string(), T::GetLibraryName());
                                                                                std::cout << "Loaded " << T::GetLibraryName() << " Auxiliary Library!" << std::endl;
                                                                            }
                                                                            catch (std::exception &e)
                                                                            {
                                                                                std::cout << "Could not load dynamic library " << withName <<":\n"
                                                                                        << e.what() << std::endl;
                                                                                auxiliaryLibraryLib.reset();
                                                                            }
                                                                            T::InitializeLibrary(); });
                    AuxiliaryLibrariesInternals::unloadFunctions.push_back([]()
                                                                           { AuxiliaryLibrary<T>::auxiliaryLibraryLib.reset();T::UnloadLibrary(); });
                }
                else
                {
                    std::cout << "Could not initialize auxiliary library " << withName << " because it is missing the static void UnloadLibrary() function." << std::endl;
                }
            }
            else
            {
                std::cout << "Could not initialize auxiliary library " << withName << " because it is missing the static void InitializeLibrary() function." << std::endl;
            }
        }
        else
        {
            std::cout << "Could not initialize auxiliary library with c++ class " << HelperFunctions::GetClassNameString<T>() << " because it is missing the static std::string GetLibraryName() function." << std::endl;
        }
    }

    static bool LibraryLoaded()
    {
        return AuxiliaryLibrary<T>::auxiliaryLibraryLib.operator bool();
    }

    static dylib *GetLibrary()
    {
        return AuxiliaryLibrary<T>::auxiliaryLibraryLib.get();
    }

private:
    static inline std::shared_ptr<dylib> auxiliaryLibraryLib;
};