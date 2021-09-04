package M_Modelo;

import M_Util.Elomac;
import static M_Util.M_Procedure.Group;
import VO.Reporte_AreaVO;
import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;

public class Area extends Elomac {

    public Area() {
        super("area", 1);
    }
    public ArrayList<Reporte_AreaVO> Areareporte(){
        Connection cnn=null;
        Statement sentencia=null;
        ResultSet rs=null;
        String nombrearea="";
        String nombrecentro="";
        ArrayList<Reporte_AreaVO> listaareas=new ArrayList<Reporte_AreaVO>();
        try {
            cnn=obtenerConn();
            sentencia=cnn.createStatement();
            rs=sentencia.executeQuery("SELECT * FROM 11_v_area");
            while(rs.next()){
             Reporte_AreaVO reportearea=new Reporte_AreaVO();
              nombrearea=rs.getString("nom_area");
              nombrecentro=rs.getString("nom_centro");
             reportearea.setNom_area(nombrearea);
             reportearea.setNom_centro(nombrecentro);
             listaareas.add(reportearea);
            }
        } catch (Exception e) {
            Logger.getLogger(Area.class.getName()).log(Level.SEVERE, null, e);
        }
        return listaareas;
    }
    public boolean RegistrarArea(String[] infoArea, int idCentro) {
        Elomac area = new Elomac(1, 1, infoArea);
        if (area.Insert()) {
            String[] aCent = {"", "" + area.atributos.get("id_area"), "" + idCentro};
            Elomac areaCentro = new Elomac(2, 1, aCent);
            if (areaCentro.Insert()) {
                return true;
            } else {
                return false;
            }

        } else {
            return false;
        }
    }

    public boolean ModificarArea(String[] infoArea, int idCentro) {
        Elomac area = new Elomac(1, 1, infoArea);
        if (area.Update()) {
            return true;
        } else {
            return false;
        }
    }
    
    
    public String AreaAdmin(String[] parametrosAreaAdmin){
        try {
            JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(parametrosAreaAdmin, '~'), 25));
            return arrayConsulta.toString();
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}
