module postid.connection;
import std.stdio;
import std.conv;
import std.string;
import std.range;
import std.algorithm;
import C.connection;

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

        PGresult* res = PQexec(conn, query.toStringz());
        ResultSet results = ResultSet(res);
        return results;
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

    struct Row{
        int currentField;
        int fieldNumber;
        int rowNumber;
        Cstring[] vals;
        this(int rowNumber, int fieldNumber){
            this.rowNumber = rowNumber;
            this.fieldNumber = fieldNumber;
            foreach(field; 0..fieldNumber){
                //vals ~= to!Cstring(PQgetvalue(this.res, rowNumber, field));
            }
        }
        void insert(Cstring data){
            vals ~= data;
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
            this.rows ~= Row(i, this.nFields);
        }
    }

    @property bool empty()
    {
        return currentRow == nrows;

    }   


    @property Row front()
    {
        auto row = Row(currentRow, nFields);

        foreach(field; 0..nFields){
            row.insert(to!Cstring(PQgetvalue(res, currentRow, field)));
        }
        
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










