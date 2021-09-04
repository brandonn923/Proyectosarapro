
package M_Controller;
import M_Modelo.Programa;
import M_Util.Elomac;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "Programa_Controller", urlPatterns = {"/Programa_Controller"})
public class Programa_Controller extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
           response.setContentType("application/json;charset=UTF-8");
           PrintWriter respuesta = response.getWriter();
            String programa=request.getParameter("programa");
            String nivel=request.getParameter("nivel");
            String [] temas=request.getParameterValues("temas[]");
             Programa p = new Programa();
            for(String tema:temas){
                 System.out.println(""+tema);
             }
            if(p.RegistrarPrograma(programa,nivel,temas)){
            out.print(new Gson().toJson(programa+" ha sido insertado"));
            }
//                   try {
//                       if(p.RegistrarPrograma(programainfo, areas, temas)){
//                            respuesta.println("[{valor:true,mensaje:'Registro Completo'}]");
//                            System.out.println("bien registroprograma");
//                       } else{
//                            respuesta.println("[{valor:false,mensaje:'Registro Fallido'}]");
//                            System.out.println("mal registroprograma");
//                       }
//                    } catch (Exception e) {
//                        e.printStackTrace();
//                         respuesta.println("[{valor:false,mensaje:'"+e.getMessage()+"'}]");
//                    }
           
        }catch(Exception ex){
            response.getWriter().print(ex.getMessage());
            ex.printStackTrace();
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
