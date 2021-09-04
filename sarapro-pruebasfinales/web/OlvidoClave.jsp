<%-- 
    Document   : OlvidoClave
    Created on : 16-sep-2019, 9:57:54
    Author     : FAMILIA NOVOA
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
         <link href="https://fonts.googleapis.com/css?family=Grand+Hotel" rel="stylesheet">
        <title>Recuperacion Clave</title>
    </head>
    <body>
   <div class="cont">
  <div class="demo">
    <div class="login">
        <div class="login__check">
            <img src="img/logofinal.png" class="logo"> 
        </div>
        <link href="login.css" rel="stylesheet" type="text/css"/>
        <div class="modal-body">
     <form method="POST" action="principal">
      <div class="login__form">
        <div class="login__row">
          <svg class="login__icon name svg-icon" viewBox="0 0 20 20">
            <path d="M0,20 a10,8 0 0,1 20,0z M10,0 a4,4 0 0,1 0,8 a4,4 0 0,1 0,-8" />
          </svg>
          <input type="text" class="login__input name" placeholder="Numero de Identificacion"  name="identificacion" id="identificacion"/>
        </div>
          <input name="opcion" value="2" type="hidden">
          <button type="submit" class="login__submit">Cambiar Contraseña</button>
        </form>
      </div>
    </div>
  </div>
      </div>
    </body>
    <script src="assets/js/jquery-1.10.2.js" type="text/javascript"></script>
    <script src="assets/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="assets/js/bootstrap-notify.js" type="text/javascript"></script>
</html>
