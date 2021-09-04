<%@page import="VO.Reporte_AreaVO"%>
<%@page import="M_Modelo.Area"%>
<%@page import="java.util.ArrayList"%>
<div class="content">
     <link href="assets/css/paper-dashboardCoordinador.css" rel="stylesheet"/>
       <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <link href="assets/css/jquery-uitab.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.12/css/jquery.dataTables.css">
   <link rel="stylesheet" href="assets/css/estilo_1.css"/>
    <div class="">
        <div class="">
            <div class="col-md-12">
                <div class="contenedorFormulario col-md-10" style="margin-left:9%">
                    <div class="col-md-12" id="red">
                     <h4 class="title">Tablas de consulta por reporte</h4>
                        <div id="tabs">
                            <ul>
                                <li><a href="#tabs-1">Area</a></li>
                                <li><a href="#tabs-2">Formato</a></li>
                                <li><a href="#tabs-3">Categoria</a></li>
                                <li><a href="#tabs-4">Visitas del producto virtual</a></li>
                                <li><a href="#tabs-5">Producto virtual</a></li>
                                <li><a href="#tabs-6">Productos publicados/inhabilitados</a></li>
                                <li><a href="#tabs-7">Publicaciones de los funcionarios</a></li>
                                <li><a href="#tabs-8">Puestos de los productos virtuales</a></li>
                            </ul>
                            <div id="tabs-1" >

                                <div> 
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio1" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes1" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info btnReporte" id="1">Consultar</button>
                                    </div>
                                      <article class="testilo">
                                <table id="tablareportearea" class="table table-striped table-dark testilos">
                                    <th>Nombre Área</th>
                                    <th>Nombre del Centro Correspondiente</th>
                                    <% Area area=new Area();
                                        Reporte_AreaVO reportearea=new Reporte_AreaVO();
                                        ArrayList<Reporte_AreaVO> listas=area.Areareporte();
                                        for (int i = 0; i < listas.size(); i++) {
                                         reportearea=listas.get(i);                                           
                                    %>
                                    <tr>
                                    <td><%=reportearea.getNom_area()%></td>
                                    <td><%=reportearea.getNom_centro()%></td>
                                    </tr>
                                    <%}%>
                                </table>
                                </article>
<!--                                    
                                    <table id="tablaReporte1" class="table-hover testilos" style="width: 120px">

                                    </table>-->
                                </div>
                              

                            </div>
                            <div id="tabs-2">
                                <div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio2" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes2" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info btnReporte" id="2">Consultar</button>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte2" class="table table-striped table-dark testilos">

                                    </table>
                                        </article>
                                    </div>                                
                            </div>
                            <div id="tabs-3">
                                <div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio3" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes3" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>

                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info btnReporte" id="3">Consultar</button>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte3" class="table table-striped table-dark testilos">

                                    </table>
                                    </article>
                                </div>
                                
                            </div>
                            <div id="tabs-4">
                                <div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio4" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes4" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>

                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info btnReporte" id="4">Consultar</button>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte4" class="table table-striped table-dark ">

                                    </table>
                                        </article>
                                </div>
                            </div>
                            <div id="tabs-5">
                                <div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio5" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes5" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>

                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info btnReporte" id="5">Consultar</button>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte5" class="table table-striped table-dark ">

                                    </table>
                                        </article>
                                </div>
                            </div>
                            <div id="tabs-6">
                                <div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio6" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes6" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info btnReporte" id="6">Consultar</button>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte6" class="table table-striped table-dark ">

                                    </table>
                                        </article>
                                </div>
                            </div>
                            <div id="tabs-7">
                                <div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Año: </p>
                                        <select class="anio form-control" id="anio7" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="col-md-12">Mes:</p>
                                        <select class="mes form-control" id="mes7" style="border:1px solid #C0BEBE;">
                                            <option value="A0">Selecione...</option>
                                        </select>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte7" class="table table-striped table-dark ">

                                    </table>
                                        </article>
                                </div>
                            </div>
                            <div id="tabs-8">
                                <div>                                  
                                    <div class="col-md-6 col-md-offset-5">
                                        <button type="button" class="btn btn-info" id="btnPublicacioneFunciones">Consultar</button>
                                    </div>
                                    <article class="testilo">
                                    <table id="tablaReporte8" class="table table-striped table-dark ">
                                    </table>
                                        </article>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" charset="utf8" src="js/jquery.js"></script>
    <script type="text/javascript" charset="utf8" src="js/jqueryUi.js"></script>
    <script type="text/javascript" charset="utf8" src="js/jquery.dataTables.js"></script>
    <script type="text/javascript" charset="utf8" src="js/jquery.cecily.js"></script>
    <script type="text/javascript" charset="utf8" src="coordinador/consultarReportes/js/ConsultarReportes.js"></script>
</div>