#include "auxiliary_library.h"

std::vector<std::function<void()>> AuxiliaryLibrariesInternals::initializeFunctions;
std::vector<std::function<void()>> AuxiliaryLibrariesInternals::unloadFunctions;