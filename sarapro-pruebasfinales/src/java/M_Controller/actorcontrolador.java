/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package M_Controller;

import M_Controller.Correos.DJCorreoHTML;
import M_Modelo.Funcionario;
import M_Modelo.Producto_Virtual;
import M_Modelo.Programa;
import VO.FuncionarioVO;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Random;
import java.util.stream.IntStream;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.codec.digest.DigestUtils;
import static org.apache.commons.codec.digest.MessageDigestAlgorithms.MD5;
import org.apache.taglibs.standard.extra.spath.ASCII_CharStream;
import org.json.JSONArray;

/**
 *
 * @author Isaac
 */
@WebServlet(name = "actorcontrolador", urlPatterns = {"/actor"})
public class actorcontrolador extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            int opcion=Integer.parseInt(request.getParameter("opcion"));
              System.out.println("la opcion"+opcion);
            switch(opcion){
                case 1:
                    String option=request.getParameter("option");
                    Programa programa=new Programa();
                    ArrayList lista=new ArrayList();
                    int area_id=programa.selectprogramared(option);
                 lista=programa.consultaprogramared(area_id);
                 String json=new Gson().toJson(lista);
                 out.print(json);
                 break;
                case 2:
                    Producto_Virtual pv=new Producto_Virtual();
                    ArrayList infoa=new ArrayList();
                    infoa=pv.consultahabilitados();
                    String infopv=new Gson().toJson(infoa);
                    out.print(infopv);
                    break;
                case 3:
            String nombre=request.getParameter("nombre");
            String apellido=request.getParameter("apellido");
            int tipoUsuario=Integer.parseInt(request.getParameter("tipoUsuario"));
            String tipoIdenti=request.getParameter("tipoIdenti");
            String numeroIdentificacion=request.getParameter("numeroIdentificacion");
            String email=request.getParameter("email");
            String centroFormacion=request.getParameter("centroFormacion");
            String reddeconocimiento=request.getParameter("centroFormacion");
            String ipSena=request.getParameter("ipSena");
            String cargo=request.getParameter("cargo");
            Random random =new Random();
           String clave=String.valueOf(random.nextInt(1000));
           ArrayList guardarabcedario=new ArrayList();
           for(int i=97;i<123;i++){
               guardarabcedario.add((char)i);
           } 
           for(int j=0;j<6;j++){
               clave=clave+guardarabcedario.get(random.nextInt(26));
           }
          FuncionarioVO funcionariovo=new FuncionarioVO(nombre, apellido, tipoUsuario, tipoIdenti, numeroIdentificacion, email, centroFormacion, reddeconocimiento, ipSena, cargo,clave);
          Funcionario funcionario=new Funcionario();
          DJCorreoHTML correo=new DJCorreoHTML();
           if(funcionario.registrarUsuario(funcionariovo)){
               request.getRequestDispatcher("administrador/administradorPrincipal.jsp").forward(request, response);
           }
           correo.mandarCorreo(email,"Clave de Sarapro",clave);
            break;
            }  
        }
                
    }
    

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
