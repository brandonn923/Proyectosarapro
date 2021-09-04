/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package M_Controller;

import M_Modelo.Red_deConocimiento;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Array;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author FAMILIA NOVOA
 */
@WebServlet(name = "Red_de_conocimiento", urlPatterns = {"/Red_Controller"})
public class Red_de_conocimiento extends HttpServlet {

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
         Red_deConocimiento red=new Red_deConocimiento();
         switch(opcion){
             case 1:
            String reddeconocimiento=request.getParameter("reddeconocimiento");
            String programas[]= request.getParameterValues("programas[]");
            if(red.registrored(reddeconocimiento,programas)){
            out.println(new Gson().toJson(1));
            }else{ 
            out.println(new Gson().toJson(2));
            }
            break;
             case 2:
                 String redconsulta=request.getParameter("redconsulta");
                 out.println(new Gson().toJson(red.consultaprogramas(redconsulta)));
                 break;
             case 3:
                 String redconsultanueva=request.getParameter("redconsultanueva");
                 String nuevosprogramas[]=request.getParameterValues("nuevosprogramas[]");
                 red.actualizar(redconsultanueva,nuevosprogramas);
                 break;
             case 4:
                 try {
                    ArrayList resultados=red.consultadatosestadisticos();
                 out.print(new Gson().toJson(resultados));
                 } catch (Exception e) {
                     e.printStackTrace();
                 }
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
