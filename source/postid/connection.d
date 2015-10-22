module postid.connection;
import std.stdio;
import std.conv;
import std.string;
import std.range;
import C.connection;

struct Connection{
    PGconn* conn;

    this(string connectionString){
        conn = PQconnectdb(connectionString.toStringz());
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


struct ResultSet{
    
    PGresult* res;
    int nFields;
    int nrows;
    Row[] rows;
    int currentRow;
    int currentField;
    int ins;
    string[] columnNames;
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

    void getHeaders(){
        foreach(i; 0..nFields){
            write(to!Cstring(PQfname(res,i)));
            write("|");
        }writeln();
    }

    void getRows(){

        foreach(row; rows){
            foreach(field; row){

                

                write(to!Cstring(PQgetvalue(res, row.rowNumber, field)));
                write("|");
            }
            writeln();
        }
    }


}

struct Rows{
    int i = 0;
    int len;
    Row[] row;

    this(int res){
        this.len = res;
        foreach(i; 0..res){
            row ~= Row(i, 10);
        }
    }
    @property bool empty()
    {
        return i == len;
    }

    @property Row front()
    {
        return row[i];
    }

    void popFront()
    {
        ++i;
    }
}



struct Row{
    int i = 0;
    int fieldNumber;
    int rowNumber;


    this(int rowNumber, int fieldNumber){
        this.rowNumber = rowNumber;
        this.fieldNumber = fieldNumber;
    }
    @property bool empty()
    {
        return i == fieldNumber;
    }

    @property int front()
    {
        return i;
    }

    void popFront()
    {
        ++i;
    }
}



