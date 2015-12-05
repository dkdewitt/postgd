import std.stdio;
import postid.connection;


void main() {

    //Connection conn = Connection("user=test password=test dbname=test hostaddr=127.0.0.1 port=5432"); 
    Connection conn = Connection(
    	["user":"test",
    	"password": "test",
    	"db": "usda",
    	]); 

    try{
        auto res = conn.query("select * from data_src where year > '2001';");
        conn.executePreparedStatement("");
    	//res.getHeaders();
        writeln(conn.status);
        foreach(row; res){
        	//writeln(row["year"]);
        }

        auto ps = conn.createPreparedStatement("select * from data_src where year > $1");
        ps.executePreparedStatement();

        ps.setInt(1, 2004);
        //ps.setInt(2, 2006);
        ps.executePreparedStatement();
        //writeln(res.headers);
        //writeln(res[11][2]);
        //conn.close();
        //auto res2 = conn.query("select * from data_src;");
        //writeln(res2);
        } catch(PGException e){
            writeln(e.msg);
        }    
}
