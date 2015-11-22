module postid.connection;
import std.stdio;
import std.conv;
import std.string;
import std.range;
import std.algorithm;
import std.exception;
import C.connection;


class PGException: Exception{
         this (string msg) {
         super(msg);
     }
}

class NotConnectedToDatabaseException : PGException {
     this (string msg) {
         super(msg);
     }
 }

struct Connection{
    PGconn* conn;

    this(string connectionString){
        conn = PQconnectdb(connectionString.toStringz());
    }

    this(string[string] connInfo){

        conn = PQsetdbLogin(connInfo.get("host","").toStringz(),
                     connInfo.get("port", "").toStringz(),
                     connInfo.get("options", "").toStringz(),
                     null,//const char *pgtty,
                     connInfo.get("db", "").toStringz(),
                     connInfo.get("user", "").toStringz(),
                     connInfo.get("password", "").toStringz());
    }

    @property
    int status(){
        return PQstatus(conn);
    }

    void close(){
        PQfinish(conn);
    }

    void reset(){
        PQreset(conn);
    }

    ResultSet query(string query){
        if(this.status == CONNECTION_BAD){
            throw new NotConnectedToDatabaseException("Not connection to database");
        }
        PGresult* res = PQexec(conn, query.toStringz());
        ResultSet results = ResultSet(res);
        return results;
    }

    void executePreparedStatement(string query){
        auto s = "2001".toStringz();
        auto statement = PQprepare(conn, "stmtname".toStringz(), "select * from data_src where year > %s".toStringz(), 1, null);
        /*auto paramVals = ["2004".toStringz()];

          PGresult *res = PQexecPrepared(conn,
                         statement,
                         1,
                         paramVals,
                         [4],
                         [0],
                         0);

        writeln(statement);*/
    }
}



struct ResultSet{
    
    PGresult* res;
    int nFields;
    int nrows;
    Row[] rows;
    int currentRow;

    int ins;
    string[] columnNames;

    //string[] headers;

    Row opIndex(int i){
        return rows[i];
    }

    Cstring opIndex(int i, int j){
        auto row = rows[i];
        return row[j];
    }

    struct Row{
        int currentField;
        int fieldNumber;
        int rowNumber;
        Cstring[] vals;
        const ResultSet resSet;
        this(PGresult* res,int rowNumber, int fieldNumber, const ref ResultSet resSet){
            this.rowNumber = rowNumber;
            this.fieldNumber = fieldNumber;
            this.resSet = resSet;
            foreach(field; 0..fieldNumber){//writeln(resSet.columnNames);
                vals ~= to!Cstring(PQgetvalue(res, rowNumber, field));
            }
        }
        void insert(Cstring data){
            vals ~= data;
        }

        Cstring opIndex(int i){
            return vals[i];
        }

        Cstring opIndex(string columnName){
            auto idx = std.algorithm.countUntil(this.resSet.columnNames, columnName);
            if(idx>0){
                return vals[idx];
            }
            else{
                throw new NotConnectedToDatabaseException("Fix");
            }

        }

        @property bool empty()
        {
            return currentField == fieldNumber;
        }

        @property Cstring front()
        {
            return vals[currentField];
            //return to!Cstring(PQgetvalue(res, row.rowNumber, field));
        }

        void popFront()
        {
            ++currentField;
        }
    }


    this(PGresult* res){
        this.res = res;
        this.nFields = PQnfields(res);
        this.nrows= PQntuples(res);
        
        foreach(i; 0..nFields){
            columnNames ~=  to!string(to!Cstring(PQfname(res,i)));
            
        }

                foreach(i; 0..nrows){
            this.rows ~= Row(this.res,i, this.nFields, this);
            //writeln(Row(this.res,i, this.nFields));
        }
        //writeln(nrows);
    }

    @property bool empty()
    {
        return currentRow == nrows;

    }   


    @property Row front()
    {
        //writeln(currentRow);
        //auto row = 0;
        //writeln(this.rows);
        auto row = rows[currentRow];
        /*auto row = Row(currentRow, nFields);

        foreach(field; 0..nFields){
            row.insert(to!Cstring(PQgetvalue(res, currentRow, field)));
        }*/
        
        return row;
        
    }

    void popFront()
    {
        ++currentRow;
    }



    void getHeaders(){
        foreach(i; 0..nFields){
            write(to!Cstring(PQfname(res,i)));
            write("|");
        }writeln();
    }

    void getRows(){

        foreach(row; rows){
            foreach(field; row){

                

                //write(to!Cstring(PQgetvalue(res, row.rowNumber, field)));
                write("|");
            }
            writeln();
        }
    }




}










