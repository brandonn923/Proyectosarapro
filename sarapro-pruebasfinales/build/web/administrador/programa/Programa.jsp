<div class="content">
    <link rel="stylesheet" type="text/css" href="css/multi-select.css">
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.12/css/jquery.dataTables.css">
    <link rel="stylesheet" href="assets/css/estilo_1.css"/>
    <div class="container-fluid">
        <div class="row" id="rowww">
            <div class="col-md-12">
                <div class="contenedorFormulario col-md-10"style="margin-top: 3%;">
                    <div class="form-group contenedorInsert">
                        <div class="col-md-6">
                            <label>Programa de Formación</label>
                            <input required type="text" id="nomPro" class="form-control inputs" placeholder="Digite el programa de formacion">
                        </div>
                        <div class="col-md-6">
                            <label>Nivel de Formación</label>
                            <select class="form-control select" id="nivel">
                                <option value="A0">Seleccionar...</option>>
                                <option value="Técnico">Técnico</option>
                                <option value="Tecnólogo">Tecnólogo</option>
                                <option value="Especialidad">Especialidad</option>
                            </select>
                        </div>
                          <div class="col-md-6" id="idcrear">
                                <div class="col-md-6" >
                                    <label>Crear Tema</label>
                                </div>
                                <label for="NombreTema" class="col-md-12">Nombre del tema:</label>
                                <input type="text" class="form-control  " id="NombreTema" placeholder="Digite Nombre del Tema" onkeydown="sinpuntosycoma(event)">
                                <label for="DescripcionCategoria" class="col-md-12">Descripción del Tema:</label>
                                <input type="text" class="form-control" id="DescripcionTema" placeholder="Digite Descripción del Tema" onkeydown="sinpuntosycoma(event)">
                                <button type="button" id="btnTemaP" class="btn btn-info">Guardar Tema</button>
                            </div>
                        <div class="col-md-6" id="temma">
                            <div class="col-md-6">
                                <label>Temas</label>
                                <select  id="MultTemasFormacion" class="MultTemasFormacion"  multiple='multiple' title="Busca un tema..">
                                    <option>Null</option>
                                </select>
                            </div>
                          
                        </div>
                        <div class="col-md-4" id="idprograma">
                        <button id="btnPrograma" type="button" class="btn btn-primary">Guardar Programa</button>
                        </div>
                        <div class="col-md-11 col-md-offset-1">
                            <article  class="col-md-11 testilo">
                            <table id="tablaPrograma" class="table table-hover">
                                <thead>
                                    <tr class="active">
                                        <td>N°</td>
                                        <td>Nombre del programa</td>
                                        <td>Nivel de formacion</td>
                                        <td>Modificar programa</td>
                                    </tr>
                                </thead>
                                <tbody id="tablabody">
                                </tbody>
                            </table>                           
                           </article>     
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            function sinpuntosycoma(event){
                var codigo=event.keyCode();
                if(codigo===110 || codigo===190 || codigo===188 ){
                    event.preventDefault();
                    alert("Inserte temas sin puntos o comas");
                }
            }
        </script>
        <script type="text/javascript" charset="utf8" type="text/javascript" src="js/jquery.js"></script>
        <script type="text/javascript" src="js/notify.js"></script>
        <script type="text/javascript" charset="utf8" src="js/jquery.dataTables.js"></script>
        <script type="text/javascript" src="js/jquery.multi-select.js"></script>
        <script type="text/javascript" src="js/jquery.quicksearch.js"></script>
        <script type="text/javascript" charset="utf8" src="js/jquery.cecily.js"></script>
        <script type="text/javascript" charset="utf8" src="administrador/programa/js/programa.js"></script>
    </div>
</div>
