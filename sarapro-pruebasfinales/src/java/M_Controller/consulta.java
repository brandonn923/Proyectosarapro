/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package M_Controller;

import M_Controller.Archivos.Archivos;
import M_Modelo.Centro;
import M_Modelo.Ciudad;
import M_Modelo.Producto_Virtual;
import M_Modelo.Programa;
import M_Modelo.Red_deConocimiento;
import VO.ConsultaVO;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.JsonElement;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import javax.activation.MimetypesFileTypeMap;
import javax.servlet.ServletOutputStream;
import org.json.JSONArray;
/**
 *
 * @author Isaac
 */
@WebServlet(name = "consulta", urlPatterns = {"/consulta"})
public class consulta extends HttpServlet {

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
       
        try  {
               PrintWriter out = response.getWriter();
                int opcion=Integer.parseInt(request.getParameter("opcion"));
                String option=request.getParameter("option");
                switch(opcion){
                    case 1:
                        
                        Programa consultaprograma=new Programa();
                        System.out.print("red"+option);
                        ArrayList informacion=consultaprograma.consultaprograma(option);
                        String info=new Gson().toJson(informacion);
                        out.print(info);
                      break;
            case 2:
                
                    String titulo=request.getParameter("titulo");
                    String autor=request.getParameter("autor");
                    Producto_Virtual pv=new Producto_Virtual();
                    boolean constante=Boolean.parseBoolean(request.getParameter("constante"));
                    if(constante){
                    String respuesta=new Gson().toJson(pv.searchnormal(titulo,autor));
                    out.print(respuesta);
                    }else{
                    String ciudad=request.getParameter("ciudad");
                    String centro=request.getParameter("centro");
                    String area=request.getParameter("area");
                    String palabraclave=request.getParameter("palabraclave");
                    String categoria=request.getParameter("categoria");
                    ConsultaVO consultavo=new ConsultaVO(titulo, autor, ciudad, centro, area, palabraclave, categoria);
                    String infoadvance=new Gson().toJson(pv.searchadvance(consultavo));
                    out.println(infoadvance);
                    }   
                break;
        }
    
        }finally{
            
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
