/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package M_Modelo;
import M_Util.M_Connection;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author FAMILIA NOVOA
 */
public class Red_deConocimiento extends M_Connection{
    public ArrayList selectred(){
                Connection cnn=null;
                ResultSet rs;
                Statement sentencia;
                ArrayList lista=new ArrayList();
            try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              rs=sentencia.executeQuery("SELECT * FROM area");
              while(rs.next()){
                  lista.add(rs.getString("nom_area"));    
              }
            } catch (Exception e) {
                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
            }
            return lista;
        }
      public ArrayList selectprograma(){
                Connection cnn=null;
                ResultSet rs;
                Statement sentencia;
                ArrayList lista=new ArrayList();
            try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              rs=sentencia.executeQuery("SELECT * FROM programa");
              while(rs.next()){
                  lista.add(rs.getString("nom_programa"));    
              }
            } catch (Exception e) {
                Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
            }
            return lista;
        }
      public boolean registrored(String red,String [] programas){
          boolean operacion=false;
          Connection cnn=null;
          Statement sentencia=null;
          ResultSet rs=null;
          int idred=0;
          try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              sentencia.executeUpdate("INSERT INTO area(nom_area) VALUES('"+red+"')");
              rs=sentencia.executeQuery("SELECT * FROM area WHERE nom_area='"+red+"'");
              while(rs.next()){
              idred=rs.getInt("id_area");
              }
              for(int i=0;i<programas.length;i++){
                  sentencia.executeUpdate("INSERT INTO detalles_area(id_area,id_programa) VALUES('"+idred+"','"+programas[i]+"')");
              }
              operacion=true;   
          } catch (Exception e) {
               Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
          }
          return operacion;
      }
      public ArrayList consultaprogramas(String redconsulta){
          ArrayList consultaprogramas=new ArrayList();
          Connection cnn=null;
          ResultSet rs=null;
          Statement sentencia=null;
          try {
              cnn=obtenerConn();
              sentencia=cnn.createStatement();
              rs=sentencia.executeQuery("SELECT pr.nom_programa from programa pr inner join detalles_area da on pr.id_programa=da.id_programa inner join area ar on ar.id_area=da.id_area WHERE ar.nom_area='"+redconsulta+"'");
              while(rs.next()){
                  consultaprogramas.add(rs.getString("pr.nom_programa"));
              }
          } catch (Exception e) {
               Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
          }
          return consultaprogramas;
      }

    public void actualizar(String redconsultanueva, String[] nuevosprogramas) {
        Connection cnn=null;
        Statement sentencia=null;
        ResultSet rs=null;
        ResultSet rs1=null;
        int idredconsultanueva=0;
        int [] nuevosprogramasid=new int[nuevosprogramas.length];
        int contador=0;
        try {
            cnn=obtenerConn();
            sentencia=cnn.createStatement();
            rs=sentencia.executeQuery("SELECT id_area FROM area WHERE nom_area='"+redconsultanueva+"'");
            while(rs.next()){
               idredconsultanueva=rs.getInt("id_area");
            }
           for(int i=0;i<nuevosprogramas.length;i++){
               rs1=sentencia.executeQuery("SELECT id_programa from programa  WHERE nom_programa='"+nuevosprogramas[i]+"'");
               while(rs1.next()){
               nuevosprogramasid[i]=rs1.getInt("id_programa");
               }
           }
           for(int j=0;j<nuevosprogramasid.length;j++){
               sentencia.execute("INSERT INTO detalles_area(id_area,id_programa) VALUES('"+idredconsultanueva+"','"+nuevosprogramasid[j]+"')");
           }
           
        } catch (Exception e) {
              Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
        }
    }
    public ArrayList consultadatosestadisticos(){
        Connection cnn=null;
        Statement sentencia=null;
        ResultSet rs=null;
        //ResultSet rs1=null;
        String consulta="SELECT count(id_area) as 'cantidad' FROM 11_v_area";
        int cantidad=0;
        ArrayList resultado=new ArrayList();
        ArrayList finalresultado=new ArrayList();
        try {
            cnn=obtenerConn();
            sentencia=cnn.createStatement();
            rs=sentencia.executeQuery(consulta);
            while(rs.next()){
            cantidad=rs.getInt("cantidad");
            }
            System.out.println("cant:"+cantidad);
            rs=sentencia.executeQuery("SELECT DISTINCT(id_area) as 'idarea' FROM area");
            while(rs.next()){
              resultado.add(rs.getInt("idarea"));
                System.out.println("idarea:"+rs.getInt("idarea"));
            }
            for (int i = 0; i < resultado.size(); i++) {
                rs=sentencia.executeQuery("SELECT count(id_area) as 'cantidad',nom_area FROM 11_v_area WHERE id_area='"+resultado.get(i)+"'");
                while(rs.next()){
                finalresultado.add(rs.getInt("cantidad"));
                finalresultado.add(rs.getString("nom_area"));
                }
            }
             finalresultado.add(cantidad);
        } catch (Exception e) {
         Logger.getLogger(Red_deConocimiento.class.getName()).log(Level.SEVERE, null, e);
        }
      return finalresultado;
    }
    
}
