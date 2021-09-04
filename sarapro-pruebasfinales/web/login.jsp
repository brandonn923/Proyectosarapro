<%-- 
    Document   : login
    Created on : 15/05/2019, 05:03:50 PM
    Author     : Proyecto
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
                    <link href="https://fonts.googleapis.com/css?family=Grand+Hotel" rel="stylesheet">
        <title>JSP Page</title>
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
          <input type="text" class="login__input name" placeholder="Usuario" id="email" name="user"/>
        </div>
        <div class="login__row">
          <svg class="login__icon pass svg-icon" viewBox="0 0 20 20">
            <path d="M0,20 20,20 20,8 0,8z M10,13 10,16z M4,8 a6,8 0 0,1 12,0" />
          </svg>
          <input type="password" class="login__input pass" placeholder="Contraseña" id="pwd" name="pwd"/>
        </div>
          <input name="op" value="1" type="hidden">
          <div>
           <a href="OlvidoClave.jsp" style="font-size:200%;top:10px;position: relative;">OLVIDASTE TU CONTRASEÑA?</a>
           <div>
        <button type="submit" class="login__submit">Ingresar</button>
        </form>   
      </div>
    </div>
  </div>
      </div>
    </body>
    <script>
        if(<%=request.getAttribute("mensaje")!=null%>)
        alert(<%=request.getAttribute("mensaje")%>);
    </script>
</html>
