module postid.connection;
import std.stdio;
import std.conv;
import std.string;
import std.range;
import std.algorithm;
import std.exception;
import C.connection;


enum TypeTag {
    INT = "int",
    STRING = "string",
    BOLLEAN = "bool"

}

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




struct PreparedStatement{

    PGconn* conn;
    string query;
    //string[] params;
    PGresult* statement2;
    TypeTag[] parameters;
    int paramNum;

    Param[] params;
    const char[] stmt = "PREPARED STATEMENT".dup;
    struct Param{
        TypeTag tag;
        string val;     
        this(TypeTag tag, string val){
            this.tag = tag;
            this.val = val;
        }
    }

    

    private int numParams(string query){
        bool inString;
        bool inStatement;
        int numberOfParameters = 1;
        foreach(i, ch; query){
            if(ch == '\''){    
                inString = !inString;
            }

            if(ch=='"'){
                inStatement = !inStatement;
            }

            if(ch == '?' && !(inStatement || inString)){
                numberOfParameters +=1;
            }
        }
        return numberOfParameters;
    }

    this(PGconn* conn, string query){
        this.conn = conn;

        this.paramNum = numParams(query);
        writeln(this.paramNum);
        params.length = this.paramNum;


       this.statement2 = PQprepare(conn, toStringz(stmt), 
            query.toStringz(), this.paramNum, null);
       //writeln(Cstring(PQresultErrorMessage(this.statement2)));
    }

    void executePreparedStatement(){
        //auto stmt = "stmtname3";
        //PGresult* statement = PQprepare(this.conn, toStringz(stmt), 
        //    "select * from data_src where year > $1".toStringz(), 1, null);
        //auto resStatement = PQresultErrorMessage(statement);
        //writeln(Cstring(PQresultErrorMessage(statement)));
         char[] args = "1999\0".dup;
        char*[2] argsStrings;
        char[] args12 = "2000\0".dup;
        argsStrings[0] = args.ptr;
        argsStrings[1] = args.ptr;
        //int[] vals = [1];


        int x = 1;
        ////int[] s = [];
        //writeln(typeid(x).toString() == TypeTag.INT);
        

        //TypeTag[] tt;

        //string s = "David";


        //tt ~= TypeTag.INT; 
        //tt  ~= TypeTag.STRING;

        //writeln(tt);
        const int x1 = 1;
        char*[1] args1;
        char[][] args2;
        foreach(i,p; this.params){
            writeln(p.val);
            args2 ~= p.val.dup;
            args1[i] = args2[0].ptr;
        }

        writeln(this.stmt);

        


        PGresult* res = PQexecPrepared(conn, toStringz(stmt), 1, args1.ptr, &x1, &x , 0);
        ResultSet results = new ResultSet(res);
        writeln(Cstring(PQresultErrorMessage(res)));
        writeln(PQntuples(res));
        //return results;
    


 
    }


    void setParameter(int index, TypeTag parameterType, string val){
        //Change to not > max ?
        //params[index] = val;
        if (index >  paramNum){
            writeln("Fix this");
        }
        Param p = Param(parameterType, val);

        writeln(index);
        params[index-1] = p;
        writeln(params);
    }



    void setInt(int index, int parameter){
        setParameter(index, TypeTag.INT, to!string(parameter));
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
        ResultSet results = new ResultSet(res);
        return results;
    }


    PreparedStatement createPreparedStatement(string query){
        PreparedStatement ps = PreparedStatement(this.conn, query);
        return ps;
    }

    ResultSet executePreparedStatement(string query){
        //auto s = "2001".toStringz();
        auto stmt = "stmtname";
        PGresult* statement = PQprepare(conn, toStringz(stmt), 
            "select * from data_src where year > $1".toStringz(), 1, null);
        writeln(PQresultStatus(statement));
        char[] args = "1999\0".dup;
        char*[1] argsStrings;
        argsStrings[0] = args.ptr;

        int[] vals = [1];

        int x = 0;
        PGresult* res = PQexecPrepared(conn, toStringz(stmt), 1, argsStrings.ptr, 0, &x , 0);
        ResultSet results = new ResultSet(res);
        return results;
        }


    
}



class ResultSet{
    
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
        }
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



    @property
    string[] headers(){
        return columnNames;
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










