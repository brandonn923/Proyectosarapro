package M_Modelo;

import M_Util.Elomac;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Ciudad extends Elomac{
	public  Ciudad ( ){ 
		super("ciudad",1);
	}
        public ArrayList consultaciudad(){
            Connection cnn;
            Statement sentencia;
            ResultSet rs;
            ArrayList lista=new ArrayList();
            try {
                cnn=obtenerConn();
                sentencia=cnn.createStatement();
                rs=sentencia.executeQuery("SELECT * FROM ciudad");
                while(rs.next()){
                lista.add(rs.getString("nom_ciudad"));
                }
            } catch (Exception e) {
                 Logger.getLogger(Ciudad.class.getName()).log(Level.SEVERE, null, e);
            }
            for(int i=0;i<lista.size();i++){
                if(lista.get(i).equals("[")|| lista.get(i).equals("]"))
                    lista.remove(i);
            }
            return lista;
        }

}