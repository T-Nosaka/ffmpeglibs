
#ifndef STRINGFORMAT_H
#define STRINGFORMAT_H

template <class ...Args>
std::string Format(const std::string& fmt, Args ...args)
{
    auto len = snprintf(nullptr, 0, fmt.c_str(), args ...);
    std::vector<char> buf(len + 1);
    snprintf(buf.data(), len + 1, fmt.c_str(), args ...);
    return std::string(buf.data());
}

#endif
