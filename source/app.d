import std.stdio;
import postgd.connection;


void main() {

    Connection conn = Connection(
    	["user":"test",
    	"password": "test",
    	"db": "usda",
    	]); 

    try{


        auto rs = checkDouble(conn);
        foreach(r; rs){
            //writeln(r);
        }

        auto rs1 = checkJoin(conn);

        writeln(rs1);
        foreach(r; rs1){
           // writeln(r);
        }


        } catch(PGException e){
            writeln(e.msg);
        }    
}

ResultSet checkString(Connection conn){
        auto ps = conn.createPreparedStatement("select * from data_src where datasrc_id = $1 or datasrc_id = $2");
        ps.setString(1, "D1066");
        ps.setString(2, "D1073");
        auto rs = ps.executePreparedStatement();
        //auto rs = checkDouble(conn);
        return rs;

}

//select * from data_src t1 join datsrcln t2 on t1.datasrc_id = t2.datasrc_id where t1.vol_city = 'Beltsville';

ResultSet checkJoin(Connection conn){
        auto ps = conn.createPreparedStatement("select * from data_src t1 join datsrcln t2 on t1.datasrc_id = t2.datasrc_id where t1.vol_city = $1");
        ps.setText(1, "Beltsville");
      
        auto rs = ps.executePreparedStatement();
        writeln(rs);
        //auto rs = checkDouble(conn);
        return rs;

}

ResultSet checkDouble(Connection conn)
{
    auto ps = conn.createPreparedStatement("select * from weight where std_dev > $1 and num_data_pts = $2 and msre_desc = $3");
    //ps.setInt(1,2004);
    ps.setDouble(1,65.0);
    ps.setInt(2, 9);
    ps.setText(3, "pie");
    return ps.executePreparedStatement();
}


