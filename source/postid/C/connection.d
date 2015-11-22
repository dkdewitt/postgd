module C.connection;
import std.stdio;
import std.conv;


//pragma(lib, "pq");


struct Cstring
{
    size_t i = 0;
    char* str;

    this(char* s)
    {
        str = s;
    }

    @property bool empty()
    {
        return str[i] == '\0';
    }

    @property char front()
    {
        return str[i];
    }

    void popFront()
    {
        ++i;
    }
}



//Types
extern (C){
    struct PGconn {};
    struct PGcancel;
    alias uint Oid;
    alias char pqbool;

    enum PostgresPollingStatusType {
    PGRES_POLLING_FAILED = 0,
    PGRES_POLLING_READING,      /* These two indicate that one may    */
    PGRES_POLLING_WRITING,      /* use select before polling again.   */
    PGRES_POLLING_OK,
    PGRES_POLLING_ACTIVE    
    }

    enum ExecStatusType {
        PGRES_EMPTY_QUERY = 0,
        PGRES_COMMAND_OK,
        PGRES_TUPLES_OK,
        PGRES_COPY_OUT,
        PGRES_COPY_IN,
        PGRES_BAD_RESPONSE,
        PGRES_NONFATAL_ERROR,
        PGRES_FATAL_ERROR,
        PGRES_COPY_BOTH
    }

    struct PQprintOpt {
        pqbool header;
        pqbool aligment;
        pqbool standard;
        pqbool html3;
        pqbool expander;
        pqbool pager;
        char* fieldSep;
        char* tableOpt;
        char* caption;
        char** fieldName;
    }

}


extern (C){

    
    PGconn* PQconnectdb(const char*);
    char *PQdb(const PGconn *conn);
    char *PQuser(const PGconn *conn);
    char *PQpass(const PGconn *conn);
    char *PQhost(const PGconn *conn);
    char *PQport(const PGconn *conn);
    char *PQtty(const PGconn *conn);
    char *PQoptions(const PGconn *conn);

    int PQstatus(PGconn*); 
    //ConnStatusType PQstatus(const PGconn *conn);

    //Returns current transaction status type
    //PGTransactionStatusType PQtransactionStatus(const PGconn *conn);


    enum int CONNECTION_OK = 0;
    enum int CONNECTION_BAD = 1;

    PGconn *PQsetdbLogin(const char *pghost,
                const char *pgport,
                const char *pgoptions,
                const char *pgtty,
                const char *dbName,
                const char *login,
                const char *pwd);

    //Closes connection and frees memory
    void PQfinish(PGconn *conn);




    //Resets conn to server
    void PQreset(PGconn *conn);

    //resets in non blocking manner
    int PQresetStart(PGconn *conn);
    PostgresPollingStatusType PQresetPoll(PGconn *conn);




    /**
        Connection Status Functions

    **/

    char *PQdb(const PGconn *conn);
    char *PQuser(const PGconn *conn);

    char *PQpass(const PGconn *conn);

    char *PQhost(const PGconn *conn);

    char *PQport(const PGconn *conn);

    char *PQtty(const PGconn *conn);

    char *PQoptions(const PGconn *conn);


    /**
        Command execution
    **/

    struct PGresult{};

    PGresult *PQexec(PGconn *conn, const char *command);

    PGresult *PQexecParams(PGconn *conn,
                       const char *command,
                       int nParams,
                       const Oid *paramTypes,
                       const char ** paramValues,
                       const int *paramLengths,
                       const int *paramFormats,
                       int resultFormat);

    PGresult *PQprepare(PGconn *conn,
                    const char *stmtName,
                    const char *query,
                    int nParams,
                    const Oid *paramTypes);

    PGresult *PQexecPrepared(PGconn *conn,
                         const char *stmtName,
                         int nParams,
                         const char ** paramValues,
                         const int *paramLengths,
                         const int *paramFormats,
                         int resultFormat);

    PGresult *PQfn(PGconn *conn,
               int fnid,
               int *result_buf,
               int *result_len,
               int result_is_int,
               const PQArgBlock *args,
               int nargs);


    struct PQArgBlock{
        int len;
        int isint;
        union u
        {
            int* ptr;
            int integer;
        }
    }

    struct PGnotify
    {
        char *relname;              
        int  be_pid;                
        char *extra;                
    }



    PGresult *PQdescribePrepared(PGconn *conn, const char *stmtName);

    PGresult *PQdescribePortal(PGconn *conn, const char *portalName);

    ExecStatusType PQresultStatus(const PGresult *res);


    char *PQresStatus(ExecStatusType status);

    char *PQresultErrorMessage(const PGresult *res);

    char *PQresultErrorField(const PGresult *res, int fieldcode);

    void PQclear(PGresult *res);


    //Retreive query info


    int PQntuples(const PGresult *res);

    int PQnfields(const PGresult *res);

    char *PQfname(const PGresult *res,
              int column_number);

    int PQfnumber(const PGresult *res,
              const char *column_name);


    //Gets field in result
    char *PQgetvalue(const PGresult *res,
                 int row_number,
                 int column_number);
    

    //Checks if field is null
    int PQgetisnull(const PGresult *res,
                int row_number,
                int column_number);

    //Returns the  length of a field value in bytes. Row and column numbers start at 0.
    int PQgetlength(const PGresult *res,
                int row_number,
                int column_number);


    //Returns no of params in prepared statement
    int PQnparams(const PGresult *res);

    //data type of  statement param
    Oid PQparamtype(const PGresult *res, int param_number);


    ///Look into this
    void PQprint(FILE *fout,      /* output stream */
             const PGresult *res,
             const PQprintOpt *po);


    char *PQcmdStatus(PGresult *res);

    char *PQcmdTuples(PGresult *res);

    Oid PQoidValue(const PGresult *res);

    char *PQoidStatus(const PGresult *res);

    char *PQescapeLiteral(PGconn *conn, const char *str, size_t length);

    char *PQescapeIdentifier(PGconn *conn, const char *str, size_t length);

    size_t PQescapeStringConn(PGconn *conn,
                          char *to, const char *from, size_t length,
                          int *error);

    size_t PQescapeString (char *to, const char *from, size_t length);

    char *PQescapeByteaConn(PGconn *conn,
                                 const  char *from,
                                 size_t from_length,
                                 size_t *to_length);

    //Select single-row mode for the currently-executing query
    int PQsetSingleRowMode(PGconn *conn);



    /*
    *   Query cancellers
    */

    PGcancel *PQgetCancel(PGconn *conn);
    
    void PQfreeCancel(PGcancel *cancel);

    int PQcancel(PGcancel *cancel, char *errbuf, int errbufsize);

    int PQrequestCancel(PGconn *conn);



    
    //Async notification

    //The function PQnotifies returns the next notification from a list of unhandled notification messages received from the server
    PGnotify *PQnotifies(PGconn *conn);


    //Copy functions


    //Sends data to server during COPY_IN state
    int PQputCopyData(PGconn *conn,
                  const char *buffer,
                  int nbytes);

    
    //Sends end of data inication to server during COPY_IN state
    int PQputCopyEnd(PGconn *conn,
                 const char *errormsg);

    //Fn receives data from the server during COPY_OUT state
    int PQgetCopyData(PGconn *conn,
                  char **buffer,
                  int async);



    //Control functions

    //Returns the client encoding
    int PQclientEncoding(const PGconn *conn);

    char *pg_encoding_to_char(int encoding_id);

    //Set client encoding
    int PQsetClientEncoding(PGconn *conn, const char *encoding);


    enum PGVerbosity{
        PQERRORS_TERSE,
        PQERRORS_DEFAULT,
        PQERRORS_VERBOSE
    } 

    PGVerbosity PQsetErrorVerbosity(PGconn *conn, PGVerbosity verbosity);

    //Enables tracing of the client/server communication to a debugging file stream.
    void PQtrace(PGconn *conn, FILE *stream);

    //Disables trace started by PQTrace
    void PQuntrace(PGconn *conn);




    // Miscellaneous Functions
}




