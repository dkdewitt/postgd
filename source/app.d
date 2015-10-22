import std.stdio;
import postid.connection;


void main() {

    Connection conn = Connection("user=test password=test dbname=usda hostaddr=127.0.0.1 port=5432"); 
    auto res = conn.query("select authors, title from public.data_src where datasrc_id like 'D1066 '");
    res.getRows();

}
