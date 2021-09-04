package org.apache.jsp.administrador.programa;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class Programa_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.List<String> _jspx_dependants;

  private org.glassfish.jsp.api.ResourceInjector _jspx_resourceInjector;

  public java.util.List<String> getDependants() {
    return _jspx_dependants;
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;

    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;
      _jspx_resourceInjector = (org.glassfish.jsp.api.ResourceInjector) application.getAttribute("com.sun.appserv.jsp.resource.injector");

      out.write("<div class=\"content\">\n");
      out.write("    <link rel=\"stylesheet\" type=\"text/css\" href=\"css/multi-select.css\">\n");
      out.write("    <link rel=\"stylesheet\" type=\"text/css\" href=\"//cdn.datatables.net/1.10.12/css/jquery.dataTables.css\">\n");
      out.write("    <link rel=\"stylesheet\" href=\"assets/css/estilo_1.css\"/>\n");
      out.write("    <div class=\"container-fluid\">\n");
      out.write("        <div class=\"row\" id=\"rowww\">\n");
      out.write("            <div class=\"col-md-12\">\n");
      out.write("                <div class=\"contenedorFormulario col-md-10\"style=\"margin-top: 3%;\">\n");
      out.write("                    <div class=\"form-group contenedorInsert\">\n");
      out.write("                        <div class=\"col-md-6\">\n");
      out.write("                            <label>Programa de Formación</label>\n");
      out.write("                            <input required type=\"text\" id=\"nomPro\" class=\"form-control inputs\" placeholder=\"Digite el programa de formacion\">\n");
      out.write("                        </div>\n");
      out.write("                        <div class=\"col-md-6\">\n");
      out.write("                            <label>Nivel de Formación</label>\n");
      out.write("                            <select class=\"form-control select\" id=\"nivel\">\n");
      out.write("                                <option value=\"A0\">Seleccionar...</option>>\n");
      out.write("                                <option value=\"Técnico\">Técnico</option>\n");
      out.write("                                <option value=\"Tecnólogo\">Tecnólogo</option>\n");
      out.write("                                <option value=\"Especialidad\">Especialidad</option>\n");
      out.write("                                <option value=\"Operario\">Operario</option>\n");
      out.write("                            </select>\n");
      out.write("                        </div>\n");
      out.write("                          <div class=\"col-md-6\" id=\"idcrear\">\n");
      out.write("                                <div class=\"col-md-6\" >\n");
      out.write("                                    <label>Crear Tema</label>\n");
      out.write("                                </div>\n");
      out.write("                                <label for=\"NombreTema\" class=\"col-md-12\">Nombre del tema:</label>\n");
      out.write("                                <input type=\"text\" class=\"form-control  \" id=\"NombreTema\" placeholder=\"Digite Nombre del Tema\" onkeydown=\"nopuntosycoma( event )\">\n");
      out.write("                                <label for=\"DescripcionCategoria\" class=\"col-md-12\">Descripción del Tema:</label>\n");
      out.write("                                <input type=\"text\" class=\"form-control\" id=\"DescripcionTema\" placeholder=\"Digite Descripción del Tema\" onkeydown=\"nopuntosycoma( event )\">\n");
      out.write("                                <button type=\"button\" id=\"btnTemaP\" class=\"btn btn-info\">Guardar Tema</button>\n");
      out.write("                            </div>\n");
      out.write("                        <div class=\"col-md-6\" id=\"temma\">\n");
      out.write("                            <div class=\"col-md-6\">\n");
      out.write("                                <label>Temas</label>\n");
      out.write("                                <select  id=\"MultTemasFormacion\" class=\"MultTemasFormacion\"  multiple='multiple' title=\"Busca un tema..\">\n");
      out.write("                                    <option>Null</option>\n");
      out.write("                                </select>\n");
      out.write("                            </div>\n");
      out.write("                          \n");
      out.write("                        </div>\n");
      out.write("                        <div class=\"col-md-4\" id=\"idprograma\">\n");
      out.write("                        <button id=\"btnPrograma\" type=\"button\" class=\"btn btn-primary\">Guardar Programa</button>\n");
      out.write("                        </div>\n");
      out.write("                        <div class=\"col-md-11 col-md-offset-1\">\n");
      out.write("                            <article  class=\"col-md-11 testilo\">\n");
      out.write("                            <table id=\"tablaPrograma\" class=\"table table-hover\">\n");
      out.write("                                <thead>\n");
      out.write("                                    <tr class=\"active\">\n");
      out.write("                                        <td>N°</td>\n");
      out.write("                                        <td>Nombre del programa</td>\n");
      out.write("                                        <td>Nivel de formacion</td>\n");
      out.write("                                        <td>Modificar programa</td>\n");
      out.write("                                    </tr>\n");
      out.write("                                </thead>\n");
      out.write("                                <tbody id=\"tablabody\">\n");
      out.write("                                </tbody>\n");
      out.write("                            </table>                           \n");
      out.write("                           </article>     \n");
      out.write("                        </div>\n");
      out.write("                    </div>\n");
      out.write("                </div>\n");
      out.write("            </div>\n");
      out.write("        </div>\n");
      out.write("        <script>\n");
      out.write("           function nopuntosycoma(event){\n");
      out.write("               var evento=event;         \n");
      out.write("               if(evento.keyCode===110 || evento.keyCode===190 || evento.keyCode===188){\n");
      out.write("                   evento.preventDefault();\n");
      out.write("                   alert('Inserte temas sin puntos o comas');\n");
      out.write("               }\n");
      out.write("           }\n");
      out.write("        </script>\n");
      out.write("        <script type=\"text/javascript\" charset=\"utf8\" type=\"text/javascript\" src=\"js/jquery.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" src=\"js/notify.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" charset=\"utf8\" src=\"js/jquery.dataTables.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" src=\"js/jquery.multi-select.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" src=\"js/jquery.quicksearch.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" charset=\"utf8\" src=\"js/jquery.cecily.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" charset=\"utf8\" src=\"administrador/programa/js/programa.js\"></script>\n");
      out.write("    </div>\n");
      out.write("</div>\n");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          out.clearBuffer();
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
