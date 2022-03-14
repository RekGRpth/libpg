#include "libpg.h"

bool lex(const char *s) {
    const char *YYCURSOR = s;
    /*!re2c
        re2c:flags:case-ranges = 1;
        re2c:yyfill:enable = 0;
        re2c:define:YYCTYPE = char;
        number = [1-9][0-9]*;
        number { return true; }
        *      { return false; }
    */
}
