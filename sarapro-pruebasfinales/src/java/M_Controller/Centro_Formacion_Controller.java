/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package M_Controller;
import M_Modelo.Centro;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author FAMILIA NOVOA
 */
@WebServlet(name = "Centro_Formacion_Controller", urlPatterns = {"/Centro_Controller"})
public class Centro_Formacion_Controller extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            
           
           String nom=request.getParameter("nom");
           int num=Integer.parseInt(request.getParameter("num"));
           String direccion=request.getParameter("direccion");
           int ciudad=Integer.parseInt(request.getParameter("ciudad"));
           String [] areas=request.getParameterValues("areas[]");
           int opcion=Integer.parseInt(request.getParameter("opcion"));
           switch(opcion){
               case 1:
                   Centro centroredcrud=new Centro();
                   centroredcrud.insertarCentros(nom, num, direccion,ciudad,areas);
                   out.print(new Gson().toJson(nom+"se registró correctamente"));
                   break;
               case 2:
                   Centro centrico=new Centro();
                   centrico.actualizarCentro(nom,num,direccion,ciudad,areas);
                   out.print(new Gson().toJson(nom+"se actualizo de forma correcta"));
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
