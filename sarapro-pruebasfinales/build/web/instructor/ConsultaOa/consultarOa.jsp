<%@page import="M_Modelo.Centro"%>
<%@page import="M_Modelo.Ciudad"%>
<%@page import="java.util.ArrayList"%>
<%@page import="M_Modelo.Red_deConocimiento"%>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    <link rel="stylesheet" href="//code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css">
    <link rel="stylesheet" type="text/css" href="css/multi-select.css"> 
    <link rel="stylesheet" href="assets/css/estilo_1.css"/>
    <link href="assets/css/paper-dashboard.css" rel="stylesheet"/>
    <link href="assets/css/consultarOa.css" rel="stylesheet" type="text/css"/>
     <link rel="stylesheet" href="assets/css/estilo_1.css"/>
</head>
<body>    
     <div class="content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-md-12">
                        <div class="contenedor">
                            <section class="col-md-12">
                                 <div class="col-md-10" >
            <div class="col-md-5" >  
                <label for="txtBuscarTitle" class="col-md-12">Buscar producto virtual por título</label>
                <div class="col-md-12">
                    <input required type="text" id="txtBuscarTitle" value="" class="form-control inputs" placeholder="Titulo del producto virtual">
                </div>
            </div>
                <div class="col-md-6" id="AaAutor" >
                <label for="Autores" class="col-md-5">Autor</label>
                <div class="col-md-10">
                    <input required type="text" id="Autores" value="" class="form-control inputs" placeholder="Autores del producto virtual">
                </div>
            </div>
                </div>
                                
                                       <div class="col-md-10" id="ABusqueda">
                <div class="col-md-6" id="labelBuque" >
                    <label><a id="BusquedaAvanzada">Busqueda avanzada</a></label>    
                </div>
                <div id="Avando" style="display: none;" class="col-md-10">
                    <div class="col-md-10">
                        <label class="col-md-12">Buscar por:</label>
                        <label class="col-md-6">Programa de formación <input type="checkbox" id="Programas"></label>    
                        <label class="col-md-6">Categoría <input type="checkbox" id="Categoria"></label>
                        <div id="ElementoFormacion" style="display: none;" class="col-md-12">
                            <div class="col-md-6">
                                <label for="CiudadFormacion" class="col-md-12">Cíudad</label>
                                <select id="CiudadFormacion" class="form-control">
                                    <option>Seleccionar...</option>
                                    <%Ciudad ciudad=new Ciudad();
                                ArrayList listaciudad=ciudad.consultaciudad();
                           for(int i=0;i<listaciudad.size();i++){
                              %>
                              <option><%=listaciudad.get(i)%></option>
                            <%}%>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="CentroF" class="col-md-12">Centro de Formación</label>
                                <select  id="CentroF" class="form-control">
                                    <option value="A0">Seleccionar...</option>
                                    <%Centro centro=new Centro();
                                ArrayList listacentro=centro.consultacentro();
                           for(int i=0;i<listacentro.size();i++){
                              %>
                              <option><%=listacentro.get(i)%></option>
                            <%}%>
                                </select>    
                            </div>
                            <div class="col-md-6">
                                <label for="Area" class="col-md-12">Area de Formación:</label>
                                <select  id="Area" class="form-control">
                                    <option value="A0">Seleccionar...</option>
                                    <%Red_deConocimiento reddeconocimiento=new Red_deConocimiento();
                                ArrayList lista=reddeconocimiento.selectred();
                           for(int i=0;i<lista.size();i++){
                              %>
                                <option><%=lista.get(i)%></option>
                            <%}%>
                            </select>                                
                            </div>
                            <div id="ElementoPrograma" style="display: none;" class="col-md-12">
                                <label class="col-md-12">Programa de formacion:</label>
                                <select id="Programa" class="Programa" multiple="multiple">
                                </select>
                            </div>
                        </div>
                        <div id="ElementoCategoria" style="display: none;">
                            <div  id="CategoriaTem" >
                                <label>Categorías de los productos virtuales</label>
                                <select id="SelectCategoria" class="SelectCategoria" multiple="multiple">
                                    <option>null</option>
                                </select>
                            </div>
                        </div>
                    </div>
<!--                    <div class="col-md-12">
                        <div class="col-md-6">
                            <label for="dataInicialA">Fecha Inicial</label>  
                            <br>
                            <input required class="form-control inputs" type="text" id="dataInicialA" placeholder="D/M/A">
                        </div>
                        <div class="col-md-6">
                            <label for="dataFinalA">Fecha Final:</label>
                            <br> 
                            <input required class="form-control inputs" type="text" id="dataFinalA" placeholder="D/M/A">
                        </div>
                    </div>-->
                    <div class="col-md-12">
                        <div class="col-md-6">
                            <label for="Palabras">Palabras Clave</label>
                            <input type="text" id="Palabras" value="" placeholder="Palabras clave" class="form-control inputs">
                        </div>
                    </div>
                </div>
            </div>
                              <div class="col-md-offset-1 col-md-6">
    <div class="col-md-6">
        <br>    
        <button id="btnBuscar" type="button" class="btn btn-block">Buscar Productos</button>        
    </div> 
    <div class="col-md-6">
        <br>   
        <button id="btnActu" type="button" class="btn btn-block">Actualizar Lista</button>        
    </div>
</div>
        </div>
      <div id="formulario1">
<!--    <section class="col col-md-10" id="Contenedora">
        <article class="col-md-3">
            <figure id="figure">
                <img src="" id="imagenproducto">
            </figure>
        </article>
        <article class="col-md-9">
            <div class="col-md-6">
                <div class="row">
                <div id="titulop">
                <label>Titulo de la publicación</label>
                <p id="TituloOa" name="titulooa"></p>
                </div>
                </div>
                <label>Autor(es)</label>
                <p id="AutoresOa"></p>
                <label>Fecha de publicación</label>
                <p id="FechaPublicacionOa"></p>
            </div>
            <div class="col-md-6">
                <label>Descripción</label>
                <p id="DescripcionOa"></p>
                <div class="col-md-8">
                    <button type="button" class="btn btn-block" id="BtnDescargar">Detalles P.V</button>
                   
                        <button type="button" class="btn btn-block"><a href="descargar?opcion=1" download>Descargar</a></button>
                </div>
            </div>
        </article>
        
    </section>-->
<div class="modal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">RECUERDE DERECHOS DE AUTOR</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="cerrar">X</button>
      </div>
      <div class="modal-body">       
      </div>
      <div class="modal-footer">
          <!--<button type="button" class="btn btn-secondary" data-dismiss="modal" id="cerrar" >Cerrar</button>!-->
      </div>
    </div>
  </div>
</div>
</div>
    </article>
<div id="resultadosProductos" class="col-md-8 col-md-offset-1 ">
    <div class="col-md-8 col-md-offset-1 Consulta" id='answer'>
        
    </div>
    <ul class="pagination col-md-8 col-md-offset-2" id="paginador">
        <li id="pag1" class='pagination'><a><lavel>1</label></a></li>
    </ul>
</div>
                            </section>
                        </div>
                    </div>
            </div>
        </div>
<input value="pag0" id="pagActual" style="display: none;">
<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/jqueryUi.js"></script>    
<script src="js/jquery.multi-select.js"></script></script>
<script src="js/jquery.quicksearch.js"></script></script>
<script type="text/javascript" src="js/jquery.cecily.js"></script>    
<script type="text/javascript" src="instructor/ConsultaOa/js/consultarOa.js"></script>
</body>
</html>