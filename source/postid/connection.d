module postid.connection;
import std.stdio;
import std.conv;
import std.string;
import std.range;
import std.algorithm;
import std.exception;
import std.bitmanip;
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
        int numberOfParameters = 0;
        foreach(i, ch; query){
            if(ch == '\''){    
                inString = !inString;
            }

            if(ch=='"'){
                inStatement = !inStatement;
            }

            if(ch == '$' && !(inStatement || inString)){
                numberOfParameters +=1;
            }
        }

        return numberOfParameters;
    }

    this(PGconn* conn, string query){
        this.conn = conn;

        this.paramNum = numParams(query);

        params.length = this.paramNum;


       this.statement2 = PQprepare(conn, toStringz(stmt), 
            query.toStringz(), this.paramNum, null);

    }

    ResultSet executePreparedStatement(){

        char*[] paramValues;
        int[] paramLengths;
        int[] paramFormats;

        char[][] args2;
        
        ubyte[][] bts;

        foreach(i,p; this.params){
            ubyte[4] v;
            if(p.tag == TypeTag.INT){
                 v = nativeToBigEndian(to!int(p.val));
                bts ~= v;
                paramValues ~= cast(char*)bts[i];
                paramLengths ~= v.sizeof;
                paramFormats ~= 1;
            }
            else{
                args2 ~= p.val.dup;
                paramValues ~= args2[i].ptr;
                paramLengths ~= p.sizeof;
                paramFormats ~= 0;
            }


        }

        PGresult* res = PQexecPrepared(conn, toStringz(stmt), this.paramNum, paramValues.ptr, paramLengths.ptr, paramFormats.ptr , 0);
        ResultSet results = new ResultSet(res);

        return results;
    


 
    }


    void setParameter(int index, TypeTag parameterType, string val){
        //Change to not > max ?
        //params[index] = val;
        if (index >  paramNum){
            writeln("Fix this");
        }
        Param p = Param(parameterType, val);
            params[index-1] = p;

    }



    void setInt(int index, int parameter){
         //auto ubarray = (cast(ubyte *)&parameter)[0..parameter.sizeof];
        ubyte[4] ub = nativeToLittleEndian(parameter);
  
        setParameter(index, TypeTag.INT, to!string(parameter));
    }

    void setString(int index, string parameter){

        //ubyte[4] ub = nativeToLittleEndian!string(parameter);
        setParameter(index, TypeTag.STRING, to!string(parameter));
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










