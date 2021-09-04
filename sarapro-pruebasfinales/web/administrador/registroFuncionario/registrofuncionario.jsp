<%@page import="M_Modelo.Red_deConocimiento"%>
<%@page import="java.util.ArrayList"%>
<div class="content">
    <link href="css/carg.css" rel="stylesheet"/>
   <div class="modal" tabindex="-1" role="dialog" id="modalcargamasiva">
                                <div class="modal-dialog" role="document">
                                  <div class="modal-content">
                                    <div class="modal-header">
                                      <h5 class="modal-title">Carga Masiva</h5>
                                      <label>Seleccione un archivo y el tipo de Usuario</label>
                                      <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                      </button>
                                    </div>
                                      <form action="CargaMasiva" method="POST" enctype="multipart/form-data">
                                    <div class="modal-body">
                                       <input type="file" name="archivoacargar" accept=".csv" id="archivocsv">       
                                    </div>
                                    <div class="modal-footer" id="camposrol">
                                    </div>
                                     </form>
                                  </div>
                                </div>
                              </div>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-13">
                <div class="contenedor">
                    <div id="formulario1">
                        <div id="AnimacionCargando" class="col-md-12" style="display: none;">  
                        <div id="caja">
                        <span style="color: black;">
                              Usuario satisfactoriamente registrado   
                         </span>
                         </div>
                        </div>
                        <section class="col col-md-6">
                            
                            <p><h3>Datos Personales</h3></p>
                            <label  class="col-md-12"  for="Centro">Tipo de Usuario</label>
                            <select class="form-control select" id="tipoUsuario" name="tipoUsuario">
                                <option value="A0" selected="selected">Seleccionar...</option>
                            </select>
                            <label>Nombre:</label>
                            <input type="text" class="form-control input" placeholder="Digite Nombre" id="nombre" maxlength="45" name="nombre">
                            <label>Apellido:</label>
                            <input type="text" class="form-control input" placeholder=" Digite Apellido" id="apellido" maxlength="100">
                            <label>Tipo Identificación:</label>
                            <select class="form-control select"  name="tipoIdenti" id="tipoIdenti">
                                <option value="A0" selected="selected">Selecciona...</option>
                            </select>
                            <label>Número Identificación:</label>
                            <input type="text" class="form-control input" placeholder="Digite Numero de Identificación" id="numeroIdentificacion" maxlength="20">
                            <label>Correo Eléctronico:</label>
                            <input type="text" class="form-control input" placeholder=" Digite Correo Eléctronico" id="email" maxlength="125">
                        </section>
                        <section class="col col-md-6">
                            <p><h3>Datos SENA:</h3> </p>
                            <label>Centro de Formación:</label>
                            <div class="form-group">
                                <select class="form-control select"  id="centroFormacion">
                                    <option value="A0" selected="selected">Seleccionar...</option>
                                </select>
                            </div>
                            <label  class="col-md-12"  for="area" id="redlabel">Red de Conocimiento:</label>
                            <select class="form-control select" id="reddeconocimiento">
                            <option value="A0" selected="selected">Seleccionar...</option>
                            <%Red_deConocimiento reddeconocimiento=new Red_deConocimiento();
                                ArrayList lista=reddeconocimiento.selectred();
                           for(int i=0;i<lista.size();i++){
                              %>
                              <option><%=lista.get(i)%></option>
                            <%}%>
                            </select>
                            <label>Telefono:</label>
                            <input type="text" class="form-control input" placeholder=" Digite Ip SENA" id="ipSena" maxlength="6">
                            <label  for="cargo">Cargo</label>
                            <input type="text" class="form-control input" placeholder=" Digite cargo" id="cargo" maxlength="45">              
                            <center>
                                <br/>
                                <div id="divBtn">
                                    <button type="action" id="boton1" class="btn btn-info">Registrar Funcionario</button>
                                    <button type="action" id="cargarmasivamente" class="btn btn-info">Registrar Varios funcionarios</button>
                                </div>
                            </center>
                        </section>
                    </div>
                  </div>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="js/notify.js"></script>
    <script type="text/javascript" src="js/jquery.cecily.js"></script>
    <script type="text/javascript" src="administrador/registroFuncionario/js/registroCoordinador.js"></script>
    <script>
$("#cargarmasivamente").click(function(){
 $("#modalcargamasiva").show();
});
$(".close").click(function(){
    $("#modalcargamasiva").hide();
    $(".modal-footer").empty();
});
    </script>
</div>
