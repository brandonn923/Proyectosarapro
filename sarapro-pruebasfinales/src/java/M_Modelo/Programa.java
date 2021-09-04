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

public class Programa extends Elomac{
	public  Programa ( ){ 
		super("Programa",1);
	}
        
        public boolean RegistrarPrograma(String programa,String nivel,String[] temas){
            Connection cnn=null;
            Statement sentencia=null;
            ResultSet rs;
            boolean operacion=false;
            int idultimo=0;
            try {
                cnn=obtenerConn();
                sentencia=cnn.createStatement();
                sentencia.execute("INSERT INTO programa(nom_programa,nivel_formacion) VALUES('"+programa+"','"+nivel+"')");
                rs=sentencia.executeQuery("SELECT MAX(id_programa) FROM programa");
                while(rs.next()){
                    idultimo=rs.getInt(1);
                }
                for(int i=0;i<temas.length;i++){
                    sentencia.execute("INSERT INTO detalles_programa(id_tema,id_programa) VALUES('"+temas[i]+"','"+idultimo+"')");
               }
                sentencia.close();
                operacion=true;
            } catch (Exception e) {
                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e); 
            }
            return operacion;
        }
        
        
        public String ProgramaAdmin(String[] parametrosProgramaAdmin){
            try {
                JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(parametrosProgramaAdmin, '~'), 24));
                return arrayConsulta.toString();
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        public int selectprogramared(String nombrePrograma){
                Connection cnn=null;
                ResultSet rs;
                Statement sentencia;
                ArrayList lista=new ArrayList();
                boolean opcion=false;
                int idarea=0;
            try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              rs=sentencia.executeQuery("SELECT * FROM area WHERE nom_area='"+nombrePrograma+"'");
              while(rs.next()){
                 idarea=rs.getInt("id_area");  
                 System.out.println(rs.getInt("id_area"));
              }
              opcion=true;
            } catch (Exception e) {
                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
            }
            return idarea;
        }
        public ArrayList consultaprogramared(int idarea){
                Connection cnn=null;
                ResultSet rs;
                Statement sentencia;
                ArrayList lista=new ArrayList();
            try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              rs=sentencia.executeQuery("SELECT p.nom_programa FROM programa p inner join detalles_area d on d.id_programa=p.id_programa INNER JOIN area a on a.id_area=d.id_area WHERE a.id_area='"+idarea+"'");
              while(rs.next()){
                  lista.add(rs.getString("p.nom_programa"));
                  System.out.println("nombreprograma"+rs.getString("p.nom_programa"));
              }
            } catch (Exception e) {
                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
            }
            return lista;
        }
        public ArrayList consultaprograma(String nomarea){
                Connection cnn=null;
                ResultSet rs;
                Statement sentencia;
                ArrayList lista=new ArrayList();
            try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              rs=sentencia.executeQuery("SELECT p.nom_programa FROM programa p inner join detalles_area d on d.id_programa=p.id_programa INNER JOIN area a on a.id_area=d.id_area WHERE a.nom_area='"+nomarea+"'");
              while(rs.next()){
                  lista.add(rs.getString("p.nom_programa"));
                  System.out.println("lista"+lista);
              }
            } catch (Exception e) {
                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
            }
            return lista;
        }
}