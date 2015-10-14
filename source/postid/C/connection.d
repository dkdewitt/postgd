module C.connection;



extern (C){

    struct PGconn {};
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


    enum PostgresPollingStatusType {
    PGRES_POLLING_FAILED = 0,
    PGRES_POLLING_READING,      /* These two indicate that one may    */
    PGRES_POLLING_WRITING,      /* use select before polling again.   */
    PGRES_POLLING_OK,
    PGRES_POLLING_ACTIVE    
    }

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


}



