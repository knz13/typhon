
#include <vector>
#include <string>
#include <sstream>
#include <cctype> // for std::isspace

namespace Typhon
{
    class Utils
    {
    public:
        static std::vector<std::string> parseStringToArgs(const std::string &input)
        {
            std::vector<std::string> args;
            std::string token;
            bool inQuotes = false;

            for (char ch : input)
            {
                if (ch == '\"')
                {
                    inQuotes = !inQuotes; // Toggle inQuotes status
                    // Optional: include quotes as part of the argument
                    // token += ch;
                }
                else if (std::isspace(ch) && !inQuotes)
                {
                    if (!token.empty())
                    {
                        args.push_back(token);
                        token.clear();
                    }
                }
                else
                {
                    token += ch;
                }
            }

            // Add the last token if it's not empty
            if (!token.empty())
            {
                args.push_back(token);
            }

            return args;
        }
    };

}
