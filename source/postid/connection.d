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
    int rows;
    Rows rrng;
    int currentRow;
    int currentField;

        int ins;
    this(PGresult* res){
        this.res = res;
        this.nFields = PQnfields(res);
        this.rows= PQntuples(res);
        this.rrng = Rows(this.rows);
    }




}

struct Rows{
    int i = 0;
    int len;
    Row row;

    this(int res){
        this.len = res;
    }
    @property bool empty()
    {
        return i == len;
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



struct Row{
    int i = 0;
    int fieldNumber;


    this(int fieldNumber){
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





void main() {

    auto conn = PQconnectdb("user=test password=test dbname=usda hostaddr=127.0.0.1 port=5432"); 
    writeln(PQstatus(conn));


    if (PQstatus(conn) != CONNECTION_OK)
    {
        writeln("Connection to database failed");
        //CloseConn(conn);
    }

    PGresult* res = PQexec(conn, "select * from public.fd_group;");
    Cstring st = PQgetvalue(res, 0, 0);
    //writeln(PQgetisnull(res,0,3));
    //char* field = PQgetvalue(res, 0, 3);
    const PQprintOpt* p1;
    auto nFields = PQnfields(res);
    //for(int i = 0; i < PQntuples(res); i++){
        auto ins = PQntuples(res);
        Rows row = Rows(ins);
        ResultSet rs = ResultSet(res);
        writeln(rs);
        
    /*foreach(int i; Rows(ins)){
        foreach(int j; Row(PQnfields(res))){
            Cstring st1 = PQgetvalue(res, i, j);
            write(st1);
        }
        write("\n");
    }*/

    //writeln(Rows(ins));


    //PQprint(f, res, p1);
    writeln(st);
    //writeln(PQntuples(res));
}

