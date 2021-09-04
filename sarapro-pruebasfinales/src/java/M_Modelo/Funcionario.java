package M_Modelo;

import M_Controller.Correos.DJCorreoHTML;
import M_Util.Elomac;
import VO.FuncionarioVO;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.codec.digest.DigestUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Funcionario extends Elomac{
	public void reemplazo(){
    }
//        public boolean RegistrarFuncionario(Object[] fun){
//            return (boolean)this.Registar(Group(fun,'~'), 2);
//        }
        
//        public String ListaAsignarRoles(String idCentro){
//            String[] campos ={"2"};
//            String listaFun1 = new Elomac(26,1).Select(campos);
//            String listaNegativa = "";
//            try {
//                for (int i = 0; i < new JSONArray(listaFun1).length(); i++) {
//                    JSONObject jso = new JSONArray(listaFun1).getJSONObject(i);
//                    if(i == 0)
//                        listaNegativa += jso.getString("id_funcionario"); 
//                    else
//                        listaNegativa += ","+jso.getString("id_funcionario"); 
//                }
//                    
//                   String[] campos1 = {"0","1","2","4","6","8"}; 
//                   return (new Elomac(20,2).Select(campos1,"[{colum:0,operador:7,valor1:'"+listaNegativa+"',añadir:0},{colum:3,operador:0,valor1:"+idCentro+"}]"));
//            } catch (JSONException ex) {
//                return("no se pudo");
//            }
//        }
        
        public boolean ModificarContraseña(String[] parametrosModifContr){
            return (boolean)this.Registar(Group(parametrosModifContr,'~'), 20);
        }
        
        public String Logueo(String[] paramUser){
            try {
                JSONArray arrayConsulta = new JSONArray(Elomac.M_ResultSet(Group(paramUser, '~'), 21));
                return arrayConsulta.toString();
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        public boolean registrarUsuario(FuncionarioVO funcionariovo){
            Connection cnn=null;
            Statement sentencia=null;
            boolean operacion=false;
            String clave=DigestUtils.md5Hex(funcionariovo.getClave());
            try {
               cnn=obtenerConn();
               sentencia=cnn.createStatement();
              sentencia.executeUpdate("INSERT INTO funcionario(id_tipo_documento,num_documento,nom_funcionario,apellidos,correo,cargo,ip_sena,contraseña,id_estado,id_area_centro) VALUES('"+funcionariovo.getTipoIdenti()+"','"+funcionariovo.getNumeroIdentificacion()+"','"+funcionariovo.getNombre()+"','"+funcionariovo.getApellido()+"','"+funcionariovo.getEmail()+"','"+funcionariovo.getCargo()+"','"+funcionariovo.getIpSena()+"','"+clave+"','"+1+"','"+1+"')");
              registrorol(funcionariovo);
              operacion=true;
            } catch (Exception e) {
                 Logger.getLogger(Funcionario.class.getName()).log(Level.SEVERE, null, e);
            }
            return operacion;
        }
        public boolean registrorol(FuncionarioVO funcionariovo){
            Connection cnn=null;
            Statement sentencia=null;
            boolean operacion=false;
            ResultSet rs;
            int id_rolfuncionario=0;
            try {
               cnn=obtenerConn();
               sentencia=cnn.createStatement();
               rs=sentencia.executeQuery("SELECT * FROM funcionario WHERE num_documento='"+Double.parseDouble(funcionariovo.getNumeroIdentificacion())+"'");
               while(rs.next()){
               id_rolfuncionario=rs.getInt("id_funcionario");
               }
                 System.out.println("tipo:"+funcionariovo.getTipoUsuario());
               sentencia.executeUpdate("INSERT INTO rol_funcionario(id_rol,id_funcionario,vigencia) VALUES ('"+funcionariovo.getTipoUsuario()+"','"+id_rolfuncionario+"','"+1+"')");
               operacion=true;
            } catch (SQLException e) {
              //System.out.println("Location"+e.getClass());
              Logger.getLogger(Funcionario.class.getName()).log(Level.SEVERE, null, e);  
            }
            return operacion;
        }
        public int consultaestado(int id_condicion){
           
                Connection cnn=null;
                Statement sentencia=null;
                ResultSet rs;
                int id_estado=0;
                try {
                    cnn=obtenerConn();
                    sentencia=cnn.createStatement();
                    rs=sentencia.executeQuery("SELECT id_estado FROM funcionario WHERE id_funcionario='"+id_condicion+"'");
                    while(rs.next()){
                        id_estado=rs.getInt("id_estado");
                    }
                } catch (Exception e) {
                     Logger.getLogger(Funcionario.class.getName()).log(Level.SEVERE, null, e);
                }
                 return id_estado;
        }
      public boolean CargaMasiva(ArrayList listafuncionario,int rol){
           ArrayList info=new ArrayList();
          try {
             int contador=0;
             String palabras="";
             for(int i=0;i<listafuncionario.size();i++){
                 if(listafuncionario.get(i)!=null && i>0){
                for(int j=0;j<listafuncionario.get(i).toString().length();j++){
                   if(listafuncionario.get(i).toString().charAt(j)==';' || contador==listafuncionario.get(i).toString().length()-1){
                   info.add(palabras);
                   palabras=""; 
                   }else{
                   palabras=palabras+listafuncionario.get(i).toString().charAt(j);
                   }
                   contador=contador+1;
                }    
              }
             contador=0;
          }
          
          }catch (Exception e) {
              e.printStackTrace();
          }
          return CargaMasivafinal(info,rol);
      }
     public String clavegenerica(){
           Random random =new Random();
           String clave=String.valueOf(random.nextInt(1000));
           ArrayList guardarabcedario=new ArrayList();
           for(int i=97;i<123;i++){
               guardarabcedario.add((char)i);
           } 
           for(int j=0;j<6;j++){
               clave=clave+guardarabcedario.get(random.nextInt(26));
           }
           return clave;
     } 
    public boolean CargaMasivafinal(ArrayList info, int rol) {
        Connection cnn;
        Statement sentencia=null;
        Statement sentencia2=null;
        ResultSet resultset;
        boolean operacion=false;
        int numdocumento=2;
        int nombrefuncionario=0;
        int apellidos=1;
        int correo=3;
        int telefono=6;
        String cargo="";
        String clave="";
        String claveencriptada="";
        DJCorreoHTML correoenvio=new DJCorreoHTML();
        int idfuncionario=0;
        switch(rol){
            case 1:
                cargo="Instructor";
                break;
            case 2:
                cargo="lider equipo tecnico";
                break;
            case 3:
                cargo="lider equipo pedagogico";
                break;
            case 4:
                cargo="coordinador";
                break;
        }
        try {
           cnn=obtenerConn();
           sentencia=cnn.createStatement();
           sentencia2=cnn.createStatement();
           for(int i=0;i<info.size();i++){
           clave=clavegenerica();
           correoenvio.mandarCorreo(info.get(correo).toString(),"Clave de Registro SARAPRO",clave);
           sentencia.execute("INSERT INTO funcionario(id_tipo_documento,num_documento,nom_funcionario,apellidos,correo,cargo,ip_sena,contraseña,id_estado,id_area_centro) VALUES('"+1+"','"+info.get(numdocumento)+"','"+info.get(nombrefuncionario)+"','"+info.get(apellidos)+"','"+info.get(correo)+"','"+cargo+"','"+info.get(telefono)+"','"+DigestUtils.md5Hex(clave)+"','"+1+"','"+1+"')");
           resultset=sentencia2.executeQuery("SELECT MAX(id_funcionario) FROM  funcionario");
           while(resultset.next()){
           idfuncionario=resultset.getInt(1);
           }
           sentencia.execute("INSERT INTO rol_funcionario(id_rol,id_funcionario,vigencia)VALUES('"+rol+"','"+idfuncionario+"',1)");
           numdocumento=numdocumento+7;
           nombrefuncionario=nombrefuncionario+7;
           apellidos=apellidos+7;
           correo=correo+7;
           telefono=telefono+7;
           }
        } catch (Exception e) {
            e.printStackTrace();
        }finally{
            try {
                sentencia.close();
                sentencia2.close();
            } catch (SQLException ex) {
                Logger.getLogger(Funcionario.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return operacion;
    }
    public boolean actualizarclave(String identificacion){
        Connection cnn;
       Statement sentencia;
        boolean operacion=false;
        ResultSet rs=null;
        String correo=null;
        String clave="";
        DJCorreoHTML correolink=new DJCorreoHTML();
        try {
            cnn=obtenerConn();
            sentencia=cnn.createStatement();
            rs=sentencia.executeQuery("SELECT correo FROM funcionario WHERE num_documento='"+identificacion+"'");
            while(rs.next()){
            correo=rs.getString("correo");
            }
            clave=clavegenerica();
            correolink.mandarCorreo(correo,"Modificacion de clave", clave);    
            sentencia.executeUpdate("UPDATE funcionario SET contraseña=  MD5('"+clave+"') WHERE num_documento='"+identificacion+"'");
            operacion=true;
            if(correo==null)
             operacion=false;
        } catch (Exception e) {
           Logger.getLogger(Funcionario.class.getName()).log(Level.SEVERE, null, e);  
        }
        return operacion;
    }
      
       
}