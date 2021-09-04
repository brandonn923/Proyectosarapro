package M_Modelo;
import M_Util.Elomac;
import static M_Util.M_Procedure.Group;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;

public class Centro extends Elomac{
	public  Centro (){ 
		super("centro",1);
	}
        
    public String CentroAdmin(String[] parametrosCentroAdmin){
        try {
            JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(parametrosCentroAdmin, '~'), 26));
            return arrayConsulta.toString();
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    public ArrayList consultacentro(){
            Connection cnn;
            Statement sentencia;
            ResultSet rs;
            ArrayList lista=new ArrayList();
            try {
                cnn=obtenerConn();
                sentencia=cnn.createStatement();
                rs=sentencia.executeQuery("SELECT * FROM centro");
                while(rs.next()){
                lista.add(rs.getString("nom_centro"));
                }
            } catch (Exception e) {
                 Logger.getLogger(Centro.class.getName()).log(Level.SEVERE, null, e);
            }
            
            return lista;
        }
    public void insertarCentros(String nom,int num,String direccion,int ciudad,String [] areas){
            Connection cnn;
            Statement sentencia=null;
            ResultSet rs;
        try {
            int idcentro=0;
            cnn=obtenerConn();
            sentencia=cnn.createStatement();
            sentencia.execute("INSERT INTO centro(num_centro,nom_centro,direccion,id_ciudad) VALUES('"+num+"','"+nom+"','"+direccion+"','"+ciudad+"')");
            rs=sentencia.executeQuery("SELECT MAX(id_centro) FROM centro");
            while(rs.next()){
            idcentro=rs.getInt(1);
            }
            for(int i=0;i<areas.length;i++){     
            sentencia.execute("INSERT INTO area_centro(id_area,id_centro) VALUES('"+(Integer.parseInt(areas[i]))+"','"+idcentro+"')");
            }
            sentencia.close();
            rs.close();
        } catch (Exception e) {
            Logger.getLogger(Centro.class.getName()).log(Level.SEVERE, null, e);
        }
    }

    public void actualizarCentro(String nom, int num, String direccion, int ciudad, String[] areas) {
         try {
            Connection cnn=null;
            Statement sentencia=null;
            ResultSet rs=null;
            int idcentro=0;
            cnn=obtenerConn();
            sentencia=cnn.createStatement();
            rs=sentencia.executeQuery("SELECT * FROM centro WHERE num_centro='"+num+"'");
            while(rs.next()){
            idcentro=rs.getInt("id_centro");
            }
            for(int i=0;i<areas.length;i++){
            sentencia.execute("INSERT INTO area_centro(id_area,id_centro) VALUES('"+(Integer.parseInt(areas[i]))+"','"+idcentro+"')");
            }
            sentencia.execute("UPDATE centro SET centro.nom_centro = '"+nom+"',centro.direccion='"+direccion+"',centro.id_ciudad='"+ciudad+"' WHERE centro.id_centro ='"+idcentro+"'");
        } catch (Exception e) {
            Logger.getLogger(Centro.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}