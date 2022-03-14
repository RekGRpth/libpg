typedef enum {
    PG_AUTHENTICATION,
    PG_BIND_COMPLETE,
    PG_CLOSE_COMPLETE,
    PG_COMMAND_COMPLETE,
    PG_DATA_ROW,
    PG_ERROR_RESPONSE,
    PG_PARAMETER_STATUS,
    PG_PARSE_COMPLETE,
    PG_READY_FOR_QUERY,
    PG_ROW_DESCRIPTION,
    PG_SECRET_KEY,
} PGstatus;

typedef struct {
//    FILE *file;
//    char buf[BUFSIZE + 1], *lim, *cur, *mar, *tok;
    PGstatus status;
} PGstate;

PGstatus PGparse(PGstate *state);
