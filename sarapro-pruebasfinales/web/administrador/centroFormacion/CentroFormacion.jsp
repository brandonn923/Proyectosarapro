<div class="content">
    <link rel="stylesheet" type="text/css" href="css/multi-select.css">
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.12/css/jquery.dataTables.css">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="contenedorFormulario col-md-11" >
                    <div class="form-group contenedorInsert col-md-12"  id="idcentro">
                        <div class="col-md-12" id="idpre">
                        <div class="col-md-6">
                            <label>Nombre del centro de formación</label>
                            <input required type="text" id="nomCentro" class="form-control inputs" placeholder="Digite el nombre del centro de formación">
                        </div>

                        <div class="col-md-6">
                            <label>Numero del centro de formación</label>
                            <input required type="text"  id="numCentro" class="form-control inputs" placeholder="Digite el numero del centro de formación">
                        </div>
                        
                        
                        <div class="col-md-6">
                            <label>Dirreción del centron de formación</label>
                            <input required type="text" id="nomDirrecion" class="form-control inputs" placeholder="Digite la dirrecion del centro de formación">
                        </div>
                        
                        
                        <div class="col-md-6" s>
                            <label>Ciudad</label>
                            <select class="form-control select" id="ciudad">
                                <option value="A0">Seleccionar...</option>
                            </select>
                        </div>
                        <div class="col-md-6" id="idaarea">
                            <label>Areas</label>
                            <select  id="MultTemasFormacion" class="MultTemasFormacion"  multiple='multiple' title="Busca un tema..">
                                <option>Null</option>
                            </select>
                        </div>
                    </div>
                        <div class="col-md-3" id="btnCentro">
                            <button type="button" class="btn btn-primary">Guardar centro</button>
                        </div>

                        <div class="col-md-12 col-md-offset-1" id="idtabla">
                            <article  class="col-md-12 testilo">
                            <table id="tablaCentro" class="table table-hover">
                                <thead>
                                    <tr class="active">
                                        <td>N°</td>
                                        <td>Nombre del centro</td>
                                        <td>Numero</td>
                                        <td>Dirrecion del centro</td>
                                        <td>Ciudad</td>
                                        <td>Modificar</td>
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
        <script type="text/javascript" charset="utf8" type="text/javascript" src="js/jquery.js"></script>
        <script type="text/javascript" src="js/notify.js"></script>
        <script type="text/javascript" charset="utf8" src="js/jquery.dataTables.js"></script>
        <script type="text/javascript" src="js/jquery.multi-select.js"></script>
        <script type="text/javascript" src="js/jquery.quicksearch.js"></script>
        <script type="text/javascript" charset="utf8" src="js/jquery.cecily.js"></script>
        <script type="text/javascript" charset="utf8" src="administrador/centroFormacion/js/centroFormacion.js"></script>
    </div>
</div>
