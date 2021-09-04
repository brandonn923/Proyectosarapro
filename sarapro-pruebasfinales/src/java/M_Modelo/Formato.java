package M_Modelo;

import M_Util.Elomac;
import static M_Util.M_Procedure.Group;
import VO.Formatos;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;

public class Formato extends Elomac{
	public  Formato ( ){ 
		super("formato",1);
	}
        
        public String consultaTipoFormato(String[] parametrosTipoFormato){
            try {
                JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(parametrosTipoFormato, '~'), 19));
                return arrayConsulta.toString();
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        
        public String FormatoAdmin(String[] parametrosFormatoAdmin){
            try {
                JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(parametrosFormatoAdmin, '~'), 27));
                return arrayConsulta.toString();
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        
        public String TipoFormatoAdmin(String[] parametrosTipoFormatoAdmin){
            try {
                JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(parametrosTipoFormatoAdmin, '~'), 28));
                return arrayConsulta.toString();
            } catch (Exception e) {
                return e.getMessage();
            }
        }
//         public ArrayList tipoformatos(){
//                Connection cnn=null;
//                ResultSet rs;
//                Statement sentencia;
//                ArrayList lista=new ArrayList();
//                Formatos formatosvo=new Formatos();
//            try {
//              cnn=obtenerConn();
//              sentencia=cnn.createStatement();
//              rs=sentencia.executeQuery("SELECT * FROM tipo_formato");
//              while(rs.next()){
//                  lista.add(rs.getInt("id_tipo_formato"));
//                  formatosvo.setId_tipo_formato(rs.getInt("id_tipo_formato"));
//                  formatosvo.setNom_tipo_formato(rs.getString("nom_tipo_formato"));
//                  lista.add(rs.getString("nom_tipo_formato"));
//                  
//              }
//            } catch (Exception e) {
//                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
//            }
//            return lista;
//        }
        
}