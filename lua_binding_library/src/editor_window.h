


#include <functional>


class EditorWindow {
public:
    inline static std::function<void(std::string)> _printFunc = [](std::string){};

    inline static void show(std::string message) {
        EditorWindow::_printFunc(message);
    };

};