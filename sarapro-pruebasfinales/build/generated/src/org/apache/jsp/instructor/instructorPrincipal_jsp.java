package org.apache.jsp.instructor;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class instructorPrincipal_jsp extends org.apache.jasper.runtime.HttpJspBase
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
      response.setContentType("text/html;charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;
      _jspx_resourceInjector = (org.glassfish.jsp.api.ResourceInjector) application.getAttribute("com.sun.appserv.jsp.resource.injector");

      out.write("\n");
      out.write("\n");
      out.write("<!doctype html>\n");
      out.write("<html lang=\"es\" id=\"estru\">\n");
      out.write("    <head>\n");
      out.write("        <meta charset=\"utf-8\" />\n");
      out.write("        <link rel=\"apple-touch-icon\" sizes=\"76x76\" href=\"assets/img/apple-icon.png\">\n");
      out.write("        <link rel=\"shotrcut icon\" href=\"recursos/flavicon.ico\">\n");
      out.write("        <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\" />\n");
      out.write("        <title>Sara-Instructor</title>\n");
      out.write("        <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport' />\n");
      out.write("        <meta name=\"viewport\" content=\"width=device-width\" />\n");
      out.write("        <link href=\"assets/css/bootstrap.min.css\" rel=\"stylesheet\" />\n");
      out.write("        <link href=\"assets/css/animate.min.css\" rel=\"stylesheet\"/>\n");
      out.write("        <link href=\"assets/css/demo.css\" rel=\"stylesheet\" />\n");
      out.write("        <link href=\"https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css\" rel=\"stylesheet\">\n");
      out.write("        <link href='https://fonts.googleapis.com/css?family=Muli:400,300' rel='stylesheet' type='text/css'>\n");
      out.write("        <link href=\"assets/css/themify-icons.css\" rel=\"stylesheet\">\n");
      out.write("        <link href=\"assets/css/estilo.css\" rel=\"stylesheet\" type=\"text/css\"/>\n");
      out.write("        <link href=\"assets/css/paper-dashboard.css\" rel=\"stylesheet\"/>\n");
      out.write("\n");
      out.write("        <link href=\"assets/css/line-awesome-font-awesome.css\" rel=\"stylesheet\" type=\"text/css\"/>\n");
      out.write("        <link href=\"assets/css/line-awesome-font-awesome.min.css\" rel=\"stylesheet\" type=\"text/css\"/>\n");
      out.write("        <link href=\"assets/css/line-awesome.css\" rel=\"stylesheet\" type=\"text/css\"/>\n");
      out.write("        <link href=\"assets/css/line-awesome.min.css\" rel=\"stylesheet\" type=\"text/css\"/>\n");
      out.write("    </head>\n");
      out.write("    <body> \n");
      out.write("        <div class=\"wrapper\">\n");
      out.write("            <div class=\"sidebar\" data-background-color=\"white\" data-active-color=\"danger\">\n");
      out.write("                <div class=\"sidebar-wrapper\">\n");
      out.write("                    <div class=\"logo\">\n");
      out.write("                        <a  class=\"simple-text\">\n");
      out.write("                            <img src=\"assets/img/logoazulprueba.png\" alt=\"\" />\n");
      out.write("                        </a>\n");
      out.write("                    </div>\n");
      out.write("                    <ul class=\"nav menu\" id=\"menus\">\n");
      out.write("                        <li class=\"active\"><a><i class=\"la la-user\"></i><p>Instructor</p></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"4\"><a><i class=\"la la-edit\"></i><p><label style='cursor:pointer;' id=\"text4\">Actualizar contraseña kgnhkldjhkldf</label></p></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"1\"><a><i class=\"la la-cloud-upload\"></i><label style='cursor:pointer;' id=\"text1\">Subir </label></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"0\"><a><i class=\"la la-search\"></i><label style='cursor:pointer;' id=\"text0\">Consultar </label></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"3\"><a><i class=\"la la-bell-o\"></i><label style='cursor:pointer;' id=\"text3\">Notificaciones </label></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"2\"><a><i class=\"la la-pencil-square\"></i><label style='cursor:pointer;' id=\"text2\">Correguir </label></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"6\"><a><i class=\"la la-cloud-download\"></i><label style='cursor:pointer;' id=\"text6\">Versión</label></a></li>\n");
      out.write("                        <li class=\"btntt\" value=\"\"><a href=\"principal?opcion=2\"><i class=\"glyphicon glyphicon-off\" aria-hidden=\"true\"></i><label style='cursor:pointer;' id=\"text3\">Cerrar Sesión</label></a></li>\n");
      out.write("                        <!--form method=\"POST\" action=\"principal\">\n");
      out.write("                        </form-->\n");
      out.write("                    </ul>\n");
      out.write("                </div>\n");
      out.write("            </div>\n");
      out.write("\n");
      out.write("            <div class=\"main-panel\">\n");
      out.write("                <nav class=\"navbar navbar-default\">\n");
      out.write("                    <div class=\"container-fluid\">\n");
      out.write("                        <div class=\"navbar-header\">\n");
      out.write("                            <button type=\"button\" class=\"navbar-toggle\">\n");
      out.write("                                <span class=\"sr-only\">Toggle navigation</span>\n");
      out.write("                                <span class=\"icon-bar bar1\"></span>\n");
      out.write("                                <span class=\"icon-bar bar2\"></span>\n");
      out.write("                                <span class=\"icon-bar bar3\"></span>\n");
      out.write("                            </button>\n");
      out.write("                            <h3 style=\"color:#218276;\">  <label id=\"CasoNombre\">Notificaciones del producto virtual</label></h3>\n");
      out.write("                        </div>\n");
      out.write("                        <div class=\"collapse navbar-collapse\">\n");
      out.write("                            <ul class=\"nav navbar-nav navbar-right\">\n");
      out.write("                                <li class=\"dropdown\">\n");
      out.write("                                    <a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\">\n");
      out.write("                                        <i class=\"ti-bell\"></i>\n");
      out.write("                                        <p class=\"notification\"><label id=\"ccNoti\">0</label></p>\n");
      out.write("                                        <p>Notificaciones</p>\n");
      out.write("                                        <b class=\"caret\"></b>\n");
      out.write("                                    </a>\n");
      out.write("                                    <ul class=\"dropdown-menu\" id=\"tablaNotificacionP\">\n");
      out.write("                                        <li><a><label class=\"Notify\">No hay notificaciones de productos virtuales</label></a></li>\n");
      out.write("                                    </ul>\n");
      out.write("                                </li>\n");
      out.write("                            </ul>\n");
      out.write("                        </div>\n");
      out.write("                    </div>\n");
      out.write("                </nav>\n");
      out.write("                <div id=\"cuerpo\" > \n");
      out.write("                </div>\n");
      out.write("                <footer class=\"text-center footerDown\" style=\"margin-top: 3%;\">\n");
      out.write("                    <div class=\"container\">\n");
      out.write("                        <div class=\"row\">\n");
      out.write("                            <div class=\"footer col-md-4 img-responsive\" style=\"margin-top:-10px;\">\n");
      out.write("                                <img src=\"assets/img/saranegro.png\">\n");
      out.write("                            </div>\n");
      out.write("                            <div class=\"footer-col col-md-4\">\n");
      out.write("                                <h3 style=\"color:black; font-size:20px; margin-top:12px;\">Siguenos en:</h3>\n");
      out.write("                                <ol class=\"list-inline\" style=\"margin-top:-5px;\">\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("                                    <li>\n");
      out.write("                                        <a href=\"#\" class=\"btn-social btn-outline\"><i class=\"fa fa-fw fa-google-plus\"></i></a>\n");
      out.write("                                    </li>\n");
      out.write("\n");
      out.write("\n");
      out.write("                                    <li>\n");
      out.write("                                        <a href=\"#\" class=\"btn-social btn-outline\"><i class=\"fa fa-fw fa-github\"></i></a>\n");
      out.write("                                    </li>\n");
      out.write("                                </ol>\n");
      out.write("                            </div>\n");
      out.write("                            <div class=\"footer-col col-md-4\">\n");
      out.write("\n");
      out.write("                                <img src=\"assets/img/senanegro.png\">\n");
      out.write("                            </div>\n");
      out.write("                        </div>\n");
      out.write("                    </div>\n");
      out.write("                </footer>\n");
      out.write("            </div>\n");
      out.write("        </div>\n");
      out.write("    </body>\n");
      out.write("    <script src=\"perfil/js/perfilUsuario.js\" type=\"text/javascript\"></script>\n");
      out.write("    <script src=\"assets/js/jquery-1.10.2.js\" type=\"text/javascript\"></script>\n");
      out.write("    <script src=\"assets/js/bootstrap.min.js\" type=\"text/javascript\"></script>\n");
      out.write("    <script src=\"assets/js/bootstrap-checkbox-radio.js\"></script>\n");
      out.write("    <script src=\"assets/js/chartist.min.js\"></script>\n");
      out.write("    <script src=\"assets/js/bootstrap-notify.js\"></script>\n");
      out.write("    <script src=\"assets/js/paper-dashboard.js\"></script>\n");
      out.write("    <script src=\"assets/js/demo.js\"></script>\n");
      out.write("    <script src=\"instructor/js/InstrutorPrincipal.js\"></script>\n");
      out.write("    <script type=\"text/javascript\">\n");
      out.write("\n");
      out.write("        var nomUser = '");
      out.print( session.getAttribute("nomUser"));
      out.write("';\n");
      out.write("        var idUser = '");
      out.print( session.getAttribute("idUser"));
      out.write("';\n");
      out.write("        var idRol = '");
      out.print( session.getAttribute("idRol"));
      out.write("';\n");
      out.write("        var idCentro = '");
      out.print( session.getAttribute("idCentro"));
      out.write("';\n");
      out.write("        var tem = '[{nomUser:' + nomUser + ',idUser:' + idUser + ',idRol:' + idRol + ',idCentro:' + idCentro + '}]';\n");
      out.write("        var js = {nomUser: nomUser, idUser: idUser, idRol: idRol, idCentro: idCentro};\n");
      out.write("\n");
      out.write("        if (idUser == null || idRol == null || nomUser == null || idCentro == null) {\n");
      out.write("            location.replace('index.jsp');\n");
      out.write("        } else {\n");
      out.write("            cargaI(idRol, tem, js);\n");
      out.write("            $.notify({\n");
      out.write("                message: \"Bienvenido a <b>Sara Pro</b> - Instructor \" + nomUser + \".\"\n");
      out.write("            }, {\n");
      out.write("                type: 'success',\n");
      out.write("                timer: 4000\n");
      out.write("            });\n");
      out.write("        }\n");
      out.write("    </script>\n");
      out.write("\n");
      out.write("\n");
      out.write("    <script>\n");
      out.write("\n");
      out.write("        if ($(window).width() < 1280) {\n");
      out.write("            alert('Less than 1280');\n");
      out.write("        } else {\n");
      out.write("            alert('More than 1280');\n");
      out.write("        }\n");
      out.write("//        $(\".navbar-toggle\").click(function () {\n");
      out.write("//            $('.navbar-nav li').click(function (e) {\n");
      out.write("//                alert(\"prueba\")\n");
      out.write("//                jso[1] = ['Instrutor_Controller', '[{opcion:' + this.value + ',ti:' + idRol + '}]'];\n");
      out.write("//                casoUso = \"text\" + this.value;\n");
      out.write("//                datos[1] = {caso: $(\"#\" + casoUso).text(), tipo: 4};\n");
      out.write("//                if (this.value == 3) {\n");
      out.write("//                    datos[1] = {caso: \"Notificaciones de los Productos Virtuales\", tipo: 3};\n");
      out.write("//                } else if (this.value == 1) {\n");
      out.write("//                    datos[1] = {caso: \"Subir un Producto Virtual\", tipo: 1};\n");
      out.write("//                } else if (this.value == 0) {\n");
      out.write("//                    datos[1] = {caso: \"Consultar Productos Virtuales\", tipo: 1};\n");
      out.write("//                } else if (this.value == 2) {\n");
      out.write("//                    datos[1] = {caso: \"Correguir Productos Virtuales\", tipo: 1};\n");
      out.write("//                } else if (this.value == 6) {\n");
      out.write("//                    datos[1] = {caso: \"Agregar una Version al Producto Virtual\", tipo: 1};\n");
      out.write("//                }\n");
      out.write("//                ajax(1);\n");
      out.write("//            });\n");
      out.write("//        })\n");
      out.write("\n");
      out.write("    </script>\n");
      out.write("</html>");
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
