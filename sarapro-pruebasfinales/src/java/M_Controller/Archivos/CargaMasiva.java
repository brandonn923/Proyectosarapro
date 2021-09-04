/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package M_Controller.Archivos;

import M_Modelo.Archivo;
import M_Modelo.Funcionario;
import com.google.gson.Gson;
import com.opencsv.CSVReader;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
@MultipartConfig
/**
 *
 * @author userdata06
 */
@WebServlet(name = "CargaMasiva", urlPatterns = {"/CargaMasiva"})
public class CargaMasiva extends HttpServlet {

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
           Archivos a=new Archivos();
           String mensaje="INSERTE UN ARCHIVO CSV VALIDO!!!";
           int contador=0;
           int valor=0;
        try{
        ServletFileUpload sf=new ServletFileUpload(new DiskFileItemFactory());
        List<FileItem> multifiles=sf.parseRequest(request);
        if(multifiles.get(contador).getName().charAt(multifiles.get(contador).getName().length()-1)=='v' && multifiles.get(contador).getName().charAt(multifiles.get(contador).getName().length()-2)=='s' && multifiles.get(contador).getName().charAt(multifiles.get(contador).getName().length()-3)=='c'){
        ArrayList lista=new ArrayList();
        Funcionario funcionario=new Funcionario();
        InputStream in=null;
        String lector="";
        for(FileItem item:multifiles){
        contador=contador+1;
        if(contador==2)
        valor=Integer.parseInt(item.getString());
         in=item.getInputStream();
         BufferedReader bfreader=new BufferedReader(new InputStreamReader(in));
         while((lector=bfreader.readLine())!=null){
             lista.add(lector);
         }
         bfreader.close();
         in.close();
        }
        funcionario.CargaMasiva(lista,valor);
       out.println("<script type=\"text/javascript\">");
       out.println("alert('FUNCIONARIOS REGISTRADOS');");
       out.println("</script>");
        request.getRequestDispatcher("principal").forward(request, response);
        }else{
       out.println("<script type=\"text/javascript\">");
       out.println("alert('"+mensaje+"');");
       out.println("</script>");
        }
        } catch (FileUploadException ex) {
            Logger.getLogger(CargaMasiva.class.getName()).log(Level.SEVERE, null, ex);
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
