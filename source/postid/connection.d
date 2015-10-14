import std.stdio;
import std.conv;

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


pragma(lib, "pq");

extern (C) int strcmp(char* string1, char* string2);



void main() {

    char x = 't';
    char y = 'z';
    //writeln(strcmp(&x, &y));
    auto conn = PQconnectdb("user=pylync password=dev dbname=pylync_groups hostaddr=192.168.2.7 port=5432"); 

    //writeln(conn);
    writeln(PQstatus(conn));
    writeln(PostgresPollingStatusType.PGRES_POLLING_FAILED);

    if (PQstatus(conn) != CONNECTION_OK)
    {
        writeln("Connection to database failed");
        //CloseConn(conn);
    }

    PGresult* res = PQexec(conn, "select * from public.group;");
    Cstring st = PQgetvalue(res, 1, 3);
    writeln(PQgetisnull(res,0,3));
    char* field = PQgetvalue(res, 0, 3);
    const PQprintOpt* p1;
    PQprint(stdout, res*, p1*);

    //writeln(strlen(field));
}


//Types
extern (C){
    struct PGconn {};
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

    void PQprint(FILE *fout,      /* output stream */
             const PGresult *res,
             const PQprintOpt *po);

}



