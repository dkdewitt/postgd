import std.stdio;
import postid.connection;


void main() {

    //Connection conn = Connection("user=test password=test dbname=test hostaddr=127.0.0.1 port=5432"); 
    Connection conn = Connection(
    	["user":"test",
    	"password": "test",
    	"db": "usda",
    	]); 

    writeln(conn.status);
    //auto res = conn.query("select column_name, data_type, character_maximum_length
//from INFORMATION_SCHEMA.COLUMNS where table_name = 'tbl1';");
    //res.getRows();
auto res = conn.query("select * from data_src;");

	res.getHeaders();
    foreach(row; res){
    	//row["authors"];
        writeln(row);
    }

}
