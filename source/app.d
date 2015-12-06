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
        //auto res = conn.query("select * from data_src where year > '2001';");
        //conn.executePreparedStatement("");
    	//res.getHeaders();
        //writeln(conn.status);
        //foreach(row; res){
        	//writeln(row["year"]);
        //}

        //auto ps = conn.createPreparedStatement("select * from data_src where year > $1");
        //ps.setInt(1,2004);
        //ps.executePreparedStatement();
        auto ps1 = conn.createPreparedStatement("select * from data_src where datasrc_id = $1 or datasrc_id = $2");
        ps1.setString(1, "D1066");
        ps1.setString(2, "D1073");
        auto rs1 = ps1.executePreparedStatement();

        foreach(r; rs1){
            writeln(r);
        }
        //writeln(res.headers);
        //writeln(res[11][2]);
        //conn.close();
        //auto res2 = conn.query("select * from data_src;");
        //writeln(res2);
        } catch(PGException e){
            writeln(e.msg);
        }    
}
