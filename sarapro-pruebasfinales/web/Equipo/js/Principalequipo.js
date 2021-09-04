function carga(ti, rol) {
     var toggle=false;
    var hilo = [], jso = [], data = [], datos = [];
   
    var ob = new $.Luna("equipo", "");
    ob.Vivo("PricipalEquipos");
    jso[0] = ['Equipo_Controller', '[{opcion:2,ti:' + rol + '}]'];
    datos[0] = {caso: "Consultar productos virtuales"};
    ajax(0);

    $(document).on('click', '.Notify', function (e) {
        ajax(0);
    });
    $("#tis").text(rol);
    if (rol==2) {
     $("#tituloPLantilla").html("Sara-Equipo Tècnico");       
    }else{
          $("#tituloPLantilla").html("Sara-Equipo Pedagogico");
    }

    $('.menu li').click(function (e) {
        if (this.value == 5) {
            jso[2] = ['principal', '[{opcion:2,se:' + ti + '}]'];
            //ajax(2);
        } else {
            casoUso = "text" + this.value;
            casoUso = $("#" + casoUso).text();
            jso[1] = ['Equipo_Controller', '[{opcion:' + this.value + ',ti:' + rol + '}]'];
            datos[1] = {caso: casoUso, en: this.value};
            if (this.value == 2) {
                casoUso = "Consultar Productos Virtuales";
            }
            ajax(1);
        }
    });
    /*clean:both*/
    $(window).resize(function () {
                console.log($(window).width())
                console.log(toggle)
            if ($(window).width() < 1000 && !toggle) {
                toggle=true;
                $(".navbar-toggle").click(function () {
                    $('.navbar-nav li').click(function (e) {
//                        alert("prueba")
                        jso[1] = ['Equipo_Controller', '[{opcion:' + this.value + ',ti:' + rol + '}]'];
                        casoUso = "text" + this.value;
                        datos[1] = {caso: $("#" + casoUso).text(), tipo: 4};
                        if (this.value == 0) {
                            datos[1] = {caso: "Notificaciones de los Productos Virtuales", tipo: 3};
                        } else if (this.value == 1) {
                            datos[1] = {caso: "Crear Lista de Chequeo", tipo: 1};
                        } else if (this.value == 2) {
                            datos[1] = {caso: "Editar Lista de Chequeo", tipo: 1};
                        } else if (this.value == 3) {
                            datos[1] = {caso: "Consultar P.V", tipo: 1};
                        } 
                        ajax(1);
                    });
                })
            }else{
                toggle=false;
            }
        });
    function ajax(i) {
        hilo[i] = new Worker("js/worker.js");
        hilo[i].postMessage(jso[i]);
        hilo[i].onmessage = function (event) {
            data[i] = event.data;
            hilo[i].terminate();
            peticionCompleta(i);
        };
    }
    function peticionCompleta(i) {
        if ((i == 0) || (i == 1)) {
            $("#CasoNombre").text(datos[i].caso);
            $("#cuerpo").empty();
            $("#cuerpo").append(data[i]);
            if (datos[i].en == 0) {
                $("#cssUsuario").attr("href", "assets/css/paper-dashboardEquipo.css");
            }
        }else if (i == 2) {
            $("#estru").empty();
            $("#estru").append(data[i]);
        }
    }

}

