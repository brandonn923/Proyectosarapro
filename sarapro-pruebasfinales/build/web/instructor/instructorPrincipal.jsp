<%@page session = "true"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es" id="estru">
    <head>
        <meta charset="utf-8" />
        <link rel="apple-touch-icon" sizes="76x76" href="assets/img/apple-icon.png">
        <link rel="shotrcut icon" href="recursos/flavicon.ico">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <title>Sara-Instructor</title>
        <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport' />
        <meta name="viewport" content="width=device-width" />
        <link href="assets/css/bootstrap.min.css" rel="stylesheet" />
        <link href="assets/css/animate.min.css" rel="stylesheet"/>
        <link href="assets/css/demo.css" rel="stylesheet" />
        <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <link href='https://fonts.googleapis.com/css?family=Muli:400,300' rel='stylesheet' type='text/css'>
        <link href="assets/css/themify-icons.css" rel="stylesheet">
        <link href="assets/css/estilo.css" rel="stylesheet" type="text/css"/>
        <link href="assets/css/paper-dashboard.css" rel="stylesheet"/>
        
         <link href="assets/css/line-awesome-font-awesome.css" rel="stylesheet" type="text/css"/>
        <link href="assets/css/line-awesome-font-awesome.min.css" rel="stylesheet" type="text/css"/>
        <link href="assets/css/line-awesome.css" rel="stylesheet" type="text/css"/>
        <link href="assets/css/line-awesome.min.css" rel="stylesheet" type="text/css"/>
    </head>
    <body> 
        <div class="wrapper">
            <div class="sidebar" data-background-color="white" data-active-color="danger">
                <div class="sidebar-wrapper">
                    <div class="logo">
                        <a  class="simple-text">
                            <img src="assets/img/logoazulprueba.png" alt="" />
                        </a>
                    </div>
                    <ul class="nav menu" id="menus">
                        <li class="active"><a><i class="la la-user"></i><p>Instructor</p></a></li>
                        <li class="btntt" value="4"><a><i class="la la-edit"></i><p><label style='cursor:pointer;' id="text4">Actualizar contraseña</label></p></a></li>
                        <li class="btntt" value="1"><a><i class="la la-cloud-upload"></i><label style='cursor:pointer;' id="text1">Subir </label></a></li>
                        <li class="btntt" value="0"><a><i class="la la-search"></i><label style='cursor:pointer;' id="text0">Consultar </label></a></li>
                        <li class="btntt" value="3"><a><i class="la la-bell-o"></i><label style='cursor:pointer;' id="text3">Notificaciones </label></a></li>
                        <li class="btntt" value="2"><a><i class="la la-pencil-square"></i><label style='cursor:pointer;' id="text2">Correguir </label></a></li>
                        <li class="btntt" value="6"><a><i class="la la-cloud-download"></i><label style='cursor:pointer;' id="text6">Versión</label></a></li>
                        <li class="btntt" value=""><a href="linkoff"><i class="glyphicon glyphicon-off" aria-hidden="true"></i><label style='cursor:pointer;' id="text3">Cerrar Sesión</label></a></li>
                        <!--form method="POST" action="principal">
                        </form-->
                    </ul>
                </div>
            </div>

            <div class="main-panel">
                <nav class="navbar navbar-default">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <button type="button" class="navbar-toggle">
                                <span class="sr-only">Toggle navigation</span>
                                <span class="icon-bar bar1"></span>
                                <span class="icon-bar bar2"></span>
                                <span class="icon-bar bar3"></span>
                            </button>
                            <h3 style="color:#218276;">  <label id="CasoNombre">Notificaciones del producto virtual</label></h3>
                        </div>
                        <div class="collapse navbar-collapse">
                            <ul class="nav navbar-nav navbar-right">
                                <li class="dropdown">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                        <i class="ti-bell"></i>
                                        <p class="notification"><label id="ccNoti">0</label></p>
                                        <p>Notificaciones</p>
                                        <b class="caret"></b>
                                    </a>
                                    <ul class="dropdown-menu" id="tablaNotificacionP">
                                        <li><a><label class="Notify">No hay notificaciones de productos virtuales</label></a></li>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                    </div>
                </nav>
                <div id="cuerpo" > 
                </div>
                <footer class="text-center footerDown" style="margin-top: 3%;">
                    <div class="container">
                        <div class="row">
                            <div class="footer col-md-4 img-responsive" style="margin-top:-10px;">
                                <img src="assets/img/saranegro.png">
                            </div>
                            <div class="footer-col col-md-4">
                                <h3 style="color:black; font-size:20px; margin-top:12px;">Siguenos en:</h3>
                                <ol class="list-inline" style="margin-top:-5px;">



                                    <li>
                                        <a href="#" class="btn-social btn-outline"><i class="fa fa-fw fa-google-plus"></i></a>
                                    </li>


                                    <li>
                                        <a href="#" class="btn-social btn-outline"><i class="fa fa-fw fa-github"></i></a>
                                    </li>
                                </ol>
                            </div>
                            <div class="footer-col col-md-4">

                                <img src="assets/img/senanegro.png">
                            </div>
                        </div>
                    </div>
                </footer>
            </div>
        </div>
    </body>
    <script src="perfil/js/perfilUsuario.js" type="text/javascript"></script>
    <script src="assets/js/jquery-1.10.2.js" type="text/javascript"></script>
    <script src="assets/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="assets/js/bootstrap-checkbox-radio.js"></script>
    <script src="assets/js/chartist.min.js"></script>
    <script src="assets/js/bootstrap-notify.js"></script>
    <script src="assets/js/paper-dashboard.js"></script>
    <script src="assets/js/demo.js"></script>
    <script src="instructor/js/InstrutorPrincipal.js"></script>
    <script type="text/javascript">
        
        var nomUser = '<%= session.getAttribute("nomUser")%>';
        var idUser = '<%= session.getAttribute("idUser")%>';
        var idRol = '<%= session.getAttribute("idRol")%>';
        var idCentro = '<%= session.getAttribute("idCentro")%>';
        var tem = '[{nomUser:' + nomUser + ',idUser:' + idUser + ',idRol:' + idRol + ',idCentro:' + idCentro + '}]';
        var js = {nomUser: nomUser, idUser: idUser, idRol: idRol, idCentro: idCentro};

        if (idUser == null || idRol == null || nomUser == null || idCentro == null) {
            location.replace('index.jsp');
        } else {
            cargaI(idRol, tem, js);
            $.notify({
                message: "Bienvenido a <b>Sara Pro</b> - Instructor " + nomUser + "."
            }, {
                type: 'success',
                timer: 4000
            });
        }
    </script>
</html>