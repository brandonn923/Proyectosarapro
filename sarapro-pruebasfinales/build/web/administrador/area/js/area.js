$(document).on('ready', function () {
    var selector = [], hilo = [], jso = [], data = [], datos = [], estado = "", idArea, arraySelecion = [], nuevosprogramas=[];
    var ob = new $.Luna("Area", $("#tablaarea"));
    ob.Vivo("Areaq");
    jso[0] = ['Modificar_Controller', '[{opcion:3,AreaAdmin:[0,0,0,0,0]}]']
    selector[0] = $("#tablaarea");
    datos[0] = {nombre: "Area"};
    ob.TablaEspa(selector[0]);
    ajax(0, datos[0]);
    var men = "";
    $(".modal").hide();
    $("#programas").hide();
    $('.itemselect').multiSelect({
        selectableHeader: "<input type='text' class='search-input form-control' autocomplete='off' placeholder='Busca un item...'>",
        selectionHeader: "<input type='text' class='search-input form-control' autocomplete='off' placeholder='Busca un item...'>",
        afterInit: function (ms) {
            var that = this,
                    $selectableSearch = that.$selectableUl.prev(),
                    $selectionSearch = that.$selectionUl.prev(),
                    selectableSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selectable:not(.ms-selected)',
                    selectionSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selection.ms-selected';

            that.qs1 = $selectableSearch.quicksearch(selectableSearchString)
                    .on('keydown', function (e) {
                        if (e.which === 40) {
                            that.$selectableUl.focus();
                            return false;
                        }
                    });

            that.qs2 = $selectionSearch.quicksearch(selectionSearchString)
                    .on('keydown', function (e) {
                        if (e.which == 40) {
                            that.$selectionUl.focus();
                            return false;
                        }
                    });
        },
        afterSelect: function (val) {
            this.qs1.cache();
            this.qs2.cache();
            arraySelecion.push(val);
        },
        afterDeselect: function (val) {
            this.qs1.cache();
            this.qs2.cache();
            var busqueda = $.inArray(val, arraySelecion);
            arraySelecion.splice(busqueda, 1);
        }
    });


    $("#btnArea").on('click', function () {
        $(".remove").remove();
        var boo = 0;
        var inputs = $(".inputs");
        var selec = $(".select");
        var input, selet;
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].value == "") {
                input = $(inputs[i]);
                input.focus().after("<div class='remove'><font color='#D23939'>Rellene este campo</font><div>");       
            } else {
                boo++;
            }
        }
        if ((boo == 1) && (arraySelecion.length > 0)) {
            BtnArea();
        }
        if($("#btnArea").text()=="Modificar Área"){
        //console.log("MODIFICANDO.."+nuevosprogramas);
        $.ajax({
        type:'POST',
        data:{opcion:3,redconsultanueva:$("#areaC").val(),nuevosprogramas:nuevosprogramas},
        url:'Red_Controller',
        success: function (data) {
        estado=("success");
        data=$("#areaC").val()+" modificada";
        $.notify(data,estado);
        },
        error: function (xhr) { 
            xhr.statusText;
            }    
        });  
        }
    });
    $("#btnprograma").click(function (){
        $(".modal").show();
    });
    $("#selectprograma").change(function(){
        $(".custom-select").append("<option selected>'"+document.getElementById("selectprograma").value+"'</option>");
        nuevosprogramas.push(document.getElementById("selectprograma").value);
        $(".modal").hide();
    });
    $(document).on('click', '.botonArea', function (e) {
        $("#btnArea").html("Modificar Área");
        $(".custom-select").empty();
        $.ajax({
        type:'POST',
        data:{opcion:2,redconsulta:$("#areaC").val()},
        url:'Red_Controller',
        success: function (data) {
        $("#programasnuevos").hide();
        var jsondata=JSON.parse(data);
        for(var i=0;i<jsondata.length;i++){
        $(".custom-select").append("<option selected>'"+jsondata[i]+"'</option>");    
         }
         $("#programasnuevos").hide();
         $("#programas").show();
        },
        error: function (xhr) { 
            xhr.statusText;
            }    
        });  
    });
    
    function BtnArea() {
        $.ajax({
        type:'POST',
        data:{opcion:1,reddeconocimiento:$("#areaC").val(),"programas[]":arraySelecion.valueOf()},
        url:'Red_Controller',
        success: function (data) {
        if(data==1){
        estado=("success");
        data=$("#areaC").val()+" registrada";
        $.notify(data,estado);
        }else{
        estado=("error");
        data=$("#areaC").val()+" no fue registrada";
        $.notify(data,estado);  
        }
        },
        error: function (xhr) { 
            xhr.statusText;
        }    
        });
    }
    
    
        
//        var Nom = $("#btnArea").text();
//        selector[1] = $("#tablaarea");
//        men = $("#areaC").val();
//        if (Nom == "Guardar Área") {
//            jso[1] = ['Modificar_Controller', '[{opcion:3,AreaAdmin:[1,0,' + $("#areaC").val() + ',' + arraySelecion + ']}]']
//            datos[1] = {nombre: "btn"};
//            ajax(1, datos[1]);
//        } else if (Nom == "Modificar Área") {
//            jso[2] = ['Modificar_Controller', '[{opcion:3,AreaAdmin:[2,' + idArea + ',' + $("#areaC").val() + ',' + $("#areaL").val() + ',' + arraySelecion + ']}]']
//            datos[2] = {nombre: "btn"};
//            $("#btnArea").html("Guardar Área");
//            ajax(2, datos[2]);
//        }
//        $("#areaC").val("");
//        $("#SelectItem").html("");
//        peticionCompleta(0);
   // }
   
    function ajax(i, datos) {
        hilo[i] = new Worker("js/worker.js");
        hilo[i].postMessage(jso[i]);
        hilo[i].onmessage = function (event) {
            data[i] = event.data;
            ob.cargarTabla(data[i], selector[i], datos);
            hilo[i].terminate();
            peticionCompleta(i);
        };
    }
    function peticionCompleta(i) {
        if (i == 0) {
            jso[5] = ['Crud_Controller', '[{opcion:3,tabla2:45,tipo:1,elegir:[0,1],delimitador:[],id:0,opSelect:4}]'];
            selector[5] = $("#SelectItem");
            datos[5] = {nombre: "MultiSelect"};
            ajax(5, datos[5]);
        }
//        if (i == 1) {//agregar area
//            if (data[1].length > data[0].length) {
//                ob.limpiarTabla($("#tablaformato"));
//                datos[7] = {nombre: "Area"};
//                ob.cargarTabla(data[i], selector[1], datos[7]);
//                estado = ("success");
//                men = "La area " + men + "  correctamente";
//
//            } else {
//                estado = ("error");
//                men = "La area " + men + " no se a agregado";
//            }
//            $.notify(men, estado);
//
//        } else if (i == 2) {
//            try {
//                var response = jQuery.parseJSON(data[i]);
//                if (typeof response == 'object') {
//                    ob.limpiarTabla($("#tablaformato"));
//                    datos[7] = {nombre: "Formato"};
//                    ob.cargarTabla(data[i], selector[1], datos[7]);
//                    estado = ("success");
//                    men = "La area" + men + " se a modificado correctamente";
//                }
//            } catch (e) {
//                estado = ("error");
//                men = "La area" + men + " no se a modificado";
//            }
//            $.notify(men, estado);
//        }
   }
});