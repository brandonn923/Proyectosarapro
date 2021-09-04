-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-07-2019 a las 18:01:35
-- Versión del servidor: 10.1.30-MariaDB
-- Versión de PHP: 7.2.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `saradb`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarpuestorankin` ()  begin
  set sql_safe_updates = 0;
  drop temporary table if exists actualizarpuesto1;
  create temporary table actualizarpuesto1 (
    idrankin1  integer not null,
    puesto1    integer not null
  );
  
  set @contpuesto = 0;
  insert into actualizarpuesto1 (
    select id_rankin, @contpuesto := @contpuesto + 1 
    from  vistapuesto
    order by val_puesto desc
  );
  
  update rankin v1 
  inner join actualizarpuesto1 v2 on v1.id_rankin = v2.idrankin1 
  set v1.puesto = v2.puesto1;
  
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `all_autor` (IN `idversion` INTEGER, OUT `salida` VARCHAR(50))  begin
	select count(*) into @cont
    from version v1 inner join autor v2 on v1.id_version = v2.id_version
    where v1.id_version = idversion;
    
    set @idversion = idversion;
    set @c = 0;
    set @idis = "0";
    while(@c < @cont)do
			call macc(concat("select v2.id_funcionario into @idfun
			from version v1 inner join autor v2 on v1.id_version = v2.id_version inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
			where v2.id_version = ",@idversion," and v2.id_funcionario not in (",@idis,")
			order by v2.id_funcionario asc limit 1"));
            
            if(@c = 0)then
				set @idis = @idfun;
                else set @idis = concat(@idis,",",@idfun);
            end if;
            set @c = @c + 1;
    end while;
	set salida = @idis;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `aprobarpv` (IN `arrayaprobacion` VARCHAR(100), OUT `nomurl` VARCHAR(50))  begin
	declare idprod integer;
    
	call execute_array(
		arrayaprobacion,
        "~",
        "case @i 
			when 0 then set @idcoordinador = @valor;
			when 1 then set @idversion = @valor;
		end case"
    );
    
    call sara_crud("update","version",concat("id_estado~6|fecha_publicacion~",current_timestamp,""),concat("id_version = ",@idversion,""));
    
    -- ------------------- num version
    
    set @idverproxi = 0;
    
    select id_p_virtual into idprod 
    from version where id_version = @idversion;
    
	select id_version into @idverproxi
    from version 
    where id_estado = 11 and id_p_virtual = idprod
    order by num_version asc limit 1;
    
    if(@idverproxi != 0) then
		update version 
		set id_estado = 5
		where id_version = @idverproxi;
    end if;
    
    -- -------------------
    
    update version set url_version = nameurl(@idversion) where id_version = @idversion;-- nuevo nombre 16/04/2017
    set nomurl = nameurl(@idversion);-- retorna el nombre del archivo
    call all_autor(@idversion,@autores);
    call registarnotificaion(concat("el producto virtual fue publicado ins~3~",@idcoordinador,"~",@autores,"~",@idversion,""));	
    
    -- ----------------------------------------
    --  rankin
    insert into rankin (id_version)values (@idversion);
    
    -- call sara_crud("select","version","id_p_virtual~@idpro","id_version = @idversion");
    -- call sara_crud("select","version","num_version~@numver","id_version = @idversion");
    -- call sara_crud("update","version",concat("num_version~",@numver + 1,""),
			-- "id_p_virtual = @idpro and id_estado != 6 and num_version = @numver");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `area_procedure` (IN `arrayarea` VARCHAR(400))  begin

declare opcion integer(1);
declare idarea_var integer default 0;
declare nomarea_var varchar(100);
declare liderarea_var varchar(70);
declare arrayprogramas_var varchar(100) default "0";
declare i,num,cant integer default 0;
declare valor varchar(400) default "";

set @opcion = 0,
	@idarea_var = 0,
    @nomarea_var = "0",
	@liderarea_var = "0",
    @arrayprogramas_var = "0";

call execute_array(
		arrayarea,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idarea_var = @valor;
            when 2 then set @nomarea_var = @valor;
            when 3 then set @liderarea_var = @valor;
            when 4 then set @arrayprogramas_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idarea_var = @idarea_var,
    nomarea_var = @nomarea_var,
	liderarea_var = @liderarea_var,
    arrayprogramas_var = @arrayprogramas_var;
    

case opcion
when 1 then
begin -- crear area
	insert into area values (null,nomarea_var,liderarea_var);
    select id_area into idarea_var from area where nom_area = nomarea_var and lider_area = liderarea_var;
    select id_area,nom_area,lider_area from area;
end;
when 2 then 
begin -- modificar area
	update area
    set nom_area = nomarea_var, lider_area = liderarea_var
    where id_area = idarea_var;
    select id_area,nom_area,lider_area from area;
end;
when 3 then
begin -- multiselect - modificar

    select pr.id_programa, pr.nom_programa,
    case(
    select 1 from detalles_area v1
    where v1.id_programa = pr.id_programa and v1.id_area = idarea_var
    )when 1 then 1 
	else 0 end as tipo
    from programa pr;
    
end;
else select id_area,nom_area,lider_area from area;
end case;
if(opcion <> 3 and arrayprogramas_var <> "0")then 
	set num = m_length(arrayprogramas_var,",");
    while(i < num)do
		set valor = substring_index(arrayprogramas_var,",",1);
        set cant = char_length(arrayprogramas_var) - char_length(valor);
        set arrayprogramas_var = right(arrayprogramas_var,cant -1);
        
			call sara_crud("insert","detalles_area",concat("id_area~",idarea_var,"|id_programa~",valor,""),"");
        set i = i + 1;
    end while;
end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `asignar_rol` (IN `arrayasignarrol` VARCHAR(400))  begin

declare opcion integer(1); 
declare idcentro_var		 integer default 0;
declare idfuncionario_var	 integer default 0;
declare idrol_var	 		 integer default 0;
declare idfunold_var  		 integer default 0;
declare idestado_var		 integer default 0;


set	@contador			= 0;
set @idsdetanoti         = ""; 
set @opcion = 0,
	@idcentro_var = 0,
    @idfuncionario_var = "0",
    @idrol_var		  = 0;

call execute_array(
		arrayasignarrol,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idcentro_var = @valor;
            when 2 then set @idfuncionario_var = @valor;
            when 3 then set @idrol_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idcentro_var = @idcentro_var,
    idfuncionario_var = @idfuncionario_var,
    idrol_var = @idrol_var;
    
    
    
    

case opcion
when 1 then
begin -- modificar o insertar vigencia rol

	if(idrol_var = 2 or idrol_var = 3)then
        
		case idrol_var
			when 2 then set idestado_var = 3;
			when 3 then set idestado_var = 4;
		end case;
		
		select fu.id_funcionario into idfunold_var
		from funcionario fu 
		inner join rol_funcionario rf on fu.id_funcionario = rf.id_funcionario and rf.vigencia = 1 
		inner join rol ro on rf.id_rol = ro.id_rol and rf.id_rol = idrol_var
		inner join area_centro ac on fu.id_area_centro  = ac.id_area_centro
		where id_centro = idcentro_var and id_estado = 1;
		
		if(idfunold_var <> 0 and idfunold_var <> idfuncionario_var)then
        
			select  @idsdetanoti := concat(@idsdetanoti,",",id_detalles_notificacion), @contador := @contador + 1
			from 43_v_consultatodonotificacion v1 
			inner join version v2 on v1.ides_proceso = v2.id_version
			inner join producto_virtual v3 on v2.id_p_virtual = v3.id_p_virtual
			where v1.tipoides = 1 and idfuncionariorecibe = idfunold_var and v2.id_estado = idestado_var and v1.estadonotificacion = 0;  
			
			set @idsdetanoti = substring_index(@idsdetanoti,",",@contador * -1); 
			
			call macc(concat("
			update detalles_notificacion
			set id_funcionario = ",idfuncionario_var,"
			where id_detalles_notificacion in (",@idsdetanoti,")
			"));
			#validar cuando no se encuentre ningun registro en las notificaciones
			update rol_funcionario
			set vigencia = 0
			where id_funcionario = idfunold_var;
            
            update rol_funcionario
			set vigencia = 1
			where id_funcionario = idfunold_var and id_rol = 1;
			
		end if;
	
		
	end if;


	update rol_funcionario
	set vigencia = 0
	where id_funcionario = idfuncionario_var;

	if( select 1 from rol_funcionario where id_funcionario = idfuncionario_var and id_rol = idrol_var)then

		update rol_funcionario
		set vigencia = 1
		where id_funcionario = idfuncionario_var and id_rol = idrol_var;

	else
	begin
		insert into rol_funcionario 
		values (null,idrol_var,idfuncionario_var,1);
	end;

	end if;
    
    select fu.id_funcionario,concat(fu.nom_funcionario," ", fu.apellidos) as funcionario,ro.id_rol,ro.nom_rol as rol
    from funcionario fu 
    inner join rol_funcionario rf on fu.id_funcionario = rf.id_funcionario and rf.vigencia = 1 
    inner join rol ro on rf.id_rol = ro.id_rol and rf.id_rol = 1
    inner join area_centro ac on fu.id_area_centro  = ac.id_area_centro
	where id_centro = idcentro_var and id_estado = 1;
end;
when 2 then 
begin -- consulta inicial de la vista asignar roles
	
    select fu.id_funcionario,concat(fu.nom_funcionario," ", fu.apellidos) as funcionario,ro.id_rol,ro.nom_rol as rol
    from funcionario fu 
    inner join rol_funcionario rf on fu.id_funcionario = rf.id_funcionario and rf.vigencia = 1 
    inner join rol ro on rf.id_rol = ro.id_rol and rf.id_rol = 1
    inner join area_centro ac on fu.id_area_centro  = ac.id_area_centro
	where id_centro = idcentro_var and id_estado = 1;
	
end;
else select id_rol,nom_rol from rol where id_rol not in (1,4); -- trae todos los roles menos el coordinador
end case; 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `centro_procedure` (IN `arraycentro` VARCHAR(400))  begin

declare opcion integer(1);
declare idcentro_var integer default 0;
declare nomcentro_var varchar(100);
declare numcentro_var varchar(50);
declare direccion_var varchar(100);
declare idciudad_var integer default 0;
declare arrayareas_var varchar(100) default "0";
declare i,num,cant integer default 0;
declare valor varchar(400) default "";


set @opcion = 0,
	@idcentro_var = 0,
    @numcentro_var = "0",
	@nomcentro_var = "0",
    @direccion_var = "0",
	@idciudad_var = 0,
    @arrayareas_var = "0";

call execute_array(
		arraycentro,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idcentro_var = @valor;
            when 2 then set @nomcentro_var = @valor;
            when 3 then set @numcentro_var = @valor;
            when 4 then set @direccion_var = @valor;
            when 5 then set @idciudad_var = @valor;
            when 6 then set @arrayareas_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idcentro_var = @idcentro_var,
    nomcentro_var = @nomcentro_var,
    numcentro_var = @numcentro_var,
    direccion_var = @direccion_var,
    idciudad_var = @idciudad_var,
    arrayareas_var = @arrayareas_var;
    

case opcion
when 1 then
begin -- crear area
	insert into centro values (null,numcentro_var,nomcentro_var,direccion_var,idciudad_var);
    select id_centro into idcentro_var from centro 
    where num_centro = numcentro_var and nom_centro = nomcentro_var and direccion = direccion_var and id_ciudad = idciudad_var;
    
    select v1.id_centro,v1.num_centro,v1.nom_centro,v1.direccion,v2.id_ciudad,v2.nom_ciudad
    from centro v1 inner join ciudad v2 on v1.id_ciudad = v2.id_ciudad;
end;
when 2 then 
begin -- modificar area
	update centro
    set num_centro = numcentro_var ,
		nom_centro = nomcentro_var ,
		direccion =  direccion_var ,
		id_ciudad =  idciudad_var
    where id_centro = idcentro_var;
    
    select v1.id_centro,v1.num_centro,v1.nom_centro,v1.direccion,v2.id_ciudad,v2.nom_ciudad
    from centro v1 inner join ciudad v2 on v1.id_ciudad = v2.id_ciudad;
end;
when 3 then
begin -- multiselect - modificar

    select ar.id_area, ar.nom_area,
    case(
	select 1 from area_centro v1
    where v1.id_area = ar.id_area and v1.id_centro = idcentro_var
    )when 1 then 1 
    else 0 end as tipo
    from area ar;
    
end;
else select v1.id_centro,v1.num_centro,v1.nom_centro,v1.direccion,v2.id_ciudad,v2.nom_ciudad
    from centro v1 inner join ciudad v2 on v1.id_ciudad = v2.id_ciudad;
end case;
if(opcion <> 3 and arrayareas_var <> "0")then 
	select arrayareas_var;
	set num = m_length(arrayareas_var,",");
    while(i < num)do
		set valor = substring_index(arrayareas_var,",",1);
        set cant = char_length(arrayareas_var) - char_length(valor);
        set arrayareas_var = right(arrayareas_var,cant -1);
        
			call sara_crud("insert","area_centro",concat("id_area~",valor,"|id_centro~",idcentro_var,""),"");
        set i = i + 1;
    end while;
end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultargrafica` (IN `arrayconsultagrafica` VARCHAR(100))  begin

	declare grafica_var,idcentro_var,mes_var,anio_var integer default 0;
    
      call execute_array(
			arrayconsultagrafica,
            "~",
            "case @i
				when 0 then set @grafica_var = @valor;
                when 1 then set @idcentro_var = @valor;
				when 2 then set @mes_var = @valor;
                when 3 then set @anio_var = @valor;
			end case;"
        );
	
    set grafica_var 	= @grafica_var,
		idcentro_var 	= @idcentro_var,
        mes_var 		= @mes_var,
        anio_var 		= @anio_var;
	
    if(mes_var = 0) then set mes_var = date_format(current_time,'%m');end if;
    if(anio_var = 0) then set anio_var = date_format(current_time,'%y');end if;
    
    case (grafica_var)
		when 1 then
        begin
        	-- estadistica por formato

			select date_format(v1.fecha_publicacion,'%y') as "año" ,date_format(v1.fecha_publicacion,'%m') as mes,v9.nom_tipo_formato as formato,count(*) as publicaciones
			from version v1 inner join autor v2 on v1.id_version = v2.id_version
			inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
			inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
			inner join centro v5 on v4.id_centro = v5.id_centro
			inner join ciudad v6 on v5.id_ciudad = v6.id_ciudad
			inner join producto_virtual v7 on v1.id_p_virtual = v7.id_p_virtual
			inner join formato v8 on v7.id_formato = v8.id_formato
			inner join tipo_formato v9 on v8.id_tipo_formato = v9.id_tipo_formato
			where v1.id_estado in (6,7) and v2.principal = 1 
			and v5.id_centro = idcentro_var and date_format(v1.fecha_publicacion,'%y') = anio_var and date_format(v1.fecha_publicacion,'%m') = mes_var
			group by v9.nom_tipo_formato;
        end;
        when 2 then
        begin
			-- estadistica por area de acuerdo a los temas que se encuentran en dichas areas

			select date_format(v1.fecha_publicacion,'%y') as "año",date_format(v1.fecha_publicacion,'%m') as mes,v8.nom_area as area,count(*) as publicaciones
			from version v1 
			inner join producto_virtual v2 on v1.id_p_virtual = v2.id_p_virtual
			inner join detalles_tema v3 on v2.id_p_virtual = v3.id_p_virtual and v3.tipo_tema = 0
			inner join tema v4 on v4.id_tema = v3.id_tema
			inner join detalles_programa v5 on v4.id_tema = v5.id_tema
			inner join programa v6 on v5.id_programa = v6.id_programa
			inner join detalles_area v7 on  v6.id_programa = v7.id_programa
			inner join area v8 on v7.id_area = v8.id_area
			inner join area_centro v9 on v8.id_area = v9.id_area
			inner join autor v10 on v1.id_version = v10.id_version
			inner join funcionario v11 on v10.id_funcionario = v11.id_funcionario
			inner join area_centro v12 on v11.id_area_centro = v12.id_area_centro
			inner join centro v13 on v12.id_centro = v13.id_centro
			inner join ciudad v14 on v13.id_ciudad = v14.id_ciudad
			where v1.id_estado in (6,7) and v10.principal = 1 
			and v13.id_centro = idcentro_var and date_format(v1.fecha_publicacion,'%y') = anio_var and date_format(v1.fecha_publicacion,'%m') = mes_var
			group by v8.nom_area;
        end;
        when 3 then
        begin 
			-- estadistica por categoria de acuerdo a los temas que se encuentran en dichas categorias

			select date_format(v1.fecha_publicacion,'%y') as "año",date_format(v1.fecha_publicacion,'%m') as mes,v10.nom_categoria as categoria,count(*) as publicaciones
			from version v1 inner join autor v2 on v1.id_version = v2.id_version
			inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
			inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
			inner join centro v5 on v4.id_centro = v5.id_centro
			inner join ciudad v6 on v5.id_ciudad = v6.id_ciudad
			inner join producto_virtual v7 on v1.id_p_virtual = v7.id_p_virtual
			inner join detalles_tema v8 on v7.id_p_virtual = v8.id_p_virtual and v8.tipo_tema = 1
			inner join detalles_categoria v9 on v8.id_tema = v9.id_tema
			inner join categoria v10 on v9.id_categoria = v10.id_categoria
			where v1.id_estado in (6,7) and v2.principal = 1 
			and v5.id_centro = idcentro_var and date_format(v1.fecha_publicacion,'%y') = anio_var and date_format(v1.fecha_publicacion,'%m') = mes_var
			group by v10.nom_categoria;
        end;
    end case;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarnotificaciones` (IN `arrayconsunoti` VARCHAR(70))  begin
  -- tener todas las consultas de notificaciones en este procedimiento
  
  call execute_array(
			arrayconsunoti,
            "~",
            "case @i
				when 0 then set @idfuncionario = @valor;
                when 1 then set @idrol = @valor;
				when 2 then set @tipoconsulta = @valor;
			end case;"
        );
        
  case (@tipoconsulta)
    when 1 then -- consulta instructor-funcionario/principal 
      begin
        select id_notificacion,conte_notificacion,v1.fecha_envio,ides_proceso,
		nom_p_virtual,num_version,url_version
		from 43_v_consultatodonotificacion v1 inner join version v2 on v1.ides_proceso = v2.id_version and estadonotificacion = 0
		inner join producto_virtual v3 on v2.id_p_virtual = v3.id_p_virtual
        inner join rol_funcionario rf on v1.idfuncionariorecibe = rf.id_funcionario and rf.id_rol = @idrol and rf.vigencia = 1
		where v1.tipoides = 1 and idfuncionariorecibe = @idfuncionario
		union 
		select id_notificacion,conte_notificacion,v1.fecha_envio,ides_proceso,
		nom_p_virtual,num_version,url_version
		from 43_v_consultatodonotificacion v1 
		inner join evaluacion_general v2 on v1.ides_proceso = v2.id_evaluacion_general and estadonotificacion = 0
		inner join version v3 on v2.id_version = v3.id_version
		inner join producto_virtual v4 on v3.id_p_virtual = v4.id_p_virtual
        inner join rol_funcionario rf on v1.idfuncionariorecibe = rf.id_funcionario and rf.id_rol = @idrol and rf.vigencia = 1
		where v1.tipoides = 2 and idfuncionariorecibe = @idfuncionario
		order by fecha_envio desc;
      end;
    when 2 then -- consulta correccion
      begin
		select id_notificacion,conte_notificacion,v1.fecha_envio,ides_proceso,
		nom_p_virtual,v3.id_version,num_version,url_version
		from 43_v_consultatodonotificacion v1 
		inner join evaluacion_general v2 on v1.ides_proceso = v2.id_evaluacion_general
		inner join version v3 on v2.id_version = v3.id_version
		inner join producto_virtual v4 on v3.id_p_virtual = v4.id_p_virtual
        inner join autor v5 on v1.idfuncionariorecibe = v5.id_funcionario
		where v1.tipoides = 2 and idfuncionariorecibe = @idfuncionario and v3.id_estado in (9,10) and v1.estadonotificacion = 0
        and v5.principal = 1 and v3.id_version = v5.id_version;
		
      end;
    when 3 then -- consulta notificaciones de evaluacion 
      begin
        set @idestado = 0;
		case @idrol
			when 2 then set @idestado = 3;
            when 3 then set @idestado = 4;
        end case;
        
        select id_notificacion,conte_notificacion,v1.fecha_envio,ides_proceso,
		nom_p_virtual,num_version,url_version
		from 43_v_consultatodonotificacion v1 
		inner join version v2 on v1.ides_proceso = v2.id_version
		inner join producto_virtual v3 on v2.id_p_virtual = v3.id_p_virtual
		where v1.tipoides = 1 and idfuncionariorecibe = @idfuncionario and v2.id_estado = @idestado and v1.estadonotificacion = 0;  
      end;
	when 4 then -- consulta habilitar producto virtual
	  begin
        select id_notificacion,conte_notificacion,v1.fecha_envio,ides_proceso,
		nom_p_virtual,num_version,url_version
		from 43_v_consultatodonotificacion v1 
		inner join version v2 on v1.ides_proceso = v2.id_version
		inner join producto_virtual v3 on v2.id_p_virtual = v3.id_p_virtual
		where v1.tipoides = 1 and idfuncionariorecibe = @idfuncionario and v1.estadonotificacion = 0 and v2.id_estado = 5;
	  end;
	when 5 then -- consulta actualizar producto virtual
      begin
		select v1.id_p_virtual,v1.nom_p_virtual,v3.id_version,v3.num_version,v3.fecha_vigencia,v3.url_version,v2.nom_formato,v4.id_funcionario
		from producto_virtual v1 inner join formato v2 on v1.id_formato = v2.id_formato
		inner join version v3 on v1.id_p_virtual = v3.id_p_virtual
		inner join autor v4 on v3.id_version = v4.id_version
		where v4.id_funcionario = @idfuncionario and v3.id_estado in (6,7) and v3.id_version = (
		  select v33.id_version from version v33 where v33.id_p_virtual = v1.id_p_virtual and v33.id_estado in (6,7)
		  order by v33.num_version desc limit 1);
      end;
  end case;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarreporte` (IN `arrayconsultareporte` VARCHAR(100))  begin
declare contenido varchar(1200) default "";
declare where_var varchar(200) default "";
declare contenido2 varchar(500) default "";
declare reporte_var,idcentro_var,mes_var,anio_var integer default 0;
    
      call execute_array(
			arrayconsultareporte,
            "~",
            "case @i
				when 0 then set @reporte_var1 = @valor;
                when 1 then set @idcentro_var1 = @valor;
				when 2 then set @mes_var1 = @valor;
                when 3 then set @anio_var1 = @valor;
			end case;"
        );
	
    set reporte_var 	= @reporte_var1,
		idcentro_var 	= @idcentro_var1,
        mes_var 		= @mes_var1,
        anio_var 		= @anio_var1;


case (reporte_var)
when 1 then
	begin
		-- cantidad de publicaciones de pv por área
		set contenido = "
		select date_format(v1.fecha_publicacion,'%m %y') as mes,concat(v14.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro,concat(v8.nom_area) as area,count(*) as publicaciones
		from version v1 
		inner join producto_virtual v2 on v1.id_p_virtual = v2.id_p_virtual
		inner join detalles_tema v3 on v2.id_p_virtual = v3.id_p_virtual and v3.tipo_tema = 0
		inner join tema v4 on v4.id_tema = v3.id_tema
		inner join detalles_programa v5 on v4.id_tema = v5.id_tema
		inner join programa v6 on v5.id_programa = v6.id_programa
		inner join detalles_area v7 on  v6.id_programa = v7.id_programa
		inner join area v8 on v7.id_area = v8.id_area
		inner join area_centro v9 on v8.id_area = v9.id_area
		inner join autor v10 on v1.id_version = v10.id_version
		inner join funcionario v11 on v10.id_funcionario = v11.id_funcionario
		inner join area_centro v12 on v11.id_area_centro = v12.id_area_centro
		inner join centro ce on v12.id_centro = ce.id_centro
		inner join ciudad v14 on ce.id_ciudad = v14.id_ciudad
		where v1.id_estado in (6,7) and v10.principal = 1 ";
        
        set contenido2 = " group by v14.nom_ciudad, ce.nom_centro, v8.nom_area";
	end;
when 2 then
	begin
		-- cantidad de publicaciones de pv por tipo objeto
		set contenido = "
		select date_format(v1.fecha_publicacion,'%m %y') as mes,concat(v6.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro,concat(v9.nom_tipo_formato) as formato,concat(v8.nom_formato) as extencion,count(*) as publicaciones
		from version v1 inner join autor v2 on v1.id_version = v2.id_version
		inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
		inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
		inner join centro ce on v4.id_centro = ce.id_centro
		inner join ciudad v6 on ce.id_ciudad = v6.id_ciudad
		inner join producto_virtual v7 on v1.id_p_virtual = v7.id_p_virtual
		inner join formato v8 on v7.id_formato = v8.id_formato
		inner join tipo_formato v9 on v8.id_tipo_formato = v9.id_tipo_formato
		where v1.id_estado in (6,7) and v2.principal = 1 ";
        
        set contenido2 = "
		group by v6.nom_ciudad,ce.nom_centro,v8.nom_formato,v9.nom_tipo_formato";
	end;
when 3 then 
	begin
		-- cantidad de publicaciones de pv por categoria
		set contenido = "
		select date_format(v1.fecha_publicacion,'%m %y') as mes,concat(v6.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro, concat(v10.nom_categoria) as categoria,count(*) as publicaciones
		from version v1 inner join autor v2 on v1.id_version = v2.id_version
		inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
		inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
		inner join centro ce on v4.id_centro = ce.id_centro
		inner join ciudad v6 on ce.id_ciudad = v6.id_ciudad
		inner join producto_virtual v7 on v1.id_p_virtual = v7.id_p_virtual
		inner join detalles_tema v8 on v7.id_p_virtual = v8.id_p_virtual and v8.tipo_tema = 1
		inner join detalles_categoria v9 on v8.id_tema = v9.id_tema
		inner join categoria v10 on v9.id_categoria = v10.id_categoria
		where v1.id_estado in (6,7) and v2.principal = 1 ";
        
        set contenido2 = "
		group by v6.nom_ciudad,ce.nom_centro,v10.nom_categoria";
    end;
when 4 then 
	begin
		-- cantidad de publicaciones visitadas
		set contenido = "
		select date_format(v1.fecha_publicacion,'%m %y') as mes,concat(v6.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro,
        concat(v7.nom_p_virtual) as ""producto virtual"", concat(v8.cant_visitas) as visitas
		from version v1 inner join autor v2 on v1.id_version = v2.id_version
		inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
		inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
		inner join centro ce on v4.id_centro = ce.id_centro
		inner join ciudad v6 on ce.id_ciudad = v6.id_ciudad
		inner join producto_virtual v7 on v1.id_p_virtual = v7.id_p_virtual
		inner join rankin v8 on v1.id_version = v8.id_version 
        where 1 = 1";
        
        set contenido2 = "
		group by v6.nom_ciudad,ce.nom_centro,v7.nom_p_virtual, v8.cant_visitas";
    end;
when 5 then 
	begin
		-- cantidad de publicaciones descargadas
		set contenido = "
		select date_format(v1.fecha_publicacion,'%m %y') as mes,concat(v6.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro,concat(v7.nom_p_virtual) as ""producto virtual"",concat(v1.num_version) as version,concat(v8.cant_descargas) as descargas
		from version v1 inner join autor v2 on v1.id_version = v2.id_version
		inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario
		inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
		inner join centro ce on v4.id_centro = ce.id_centro
		inner join ciudad v6 on ce.id_ciudad = v6.id_ciudad
		inner join producto_virtual v7 on v1.id_p_virtual = v7.id_p_virtual
		inner join rankin v8 on v1.id_version = v8.id_version
        where 1 = 1";
        
        set contenido2 = "
		group by v6.nom_ciudad,ce.nom_centro,v7.nom_p_virtual, v8.cant_descargas";
    end;
when 6 then 
	begin
		-- cantidad de publicaciones de pv publicados e inhabilitados
		set contenido = "
		select date_format(v1.fecha_publicacion,'%m %y') as mes,concat(v6.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro,count(*) as publicados,
		(
			select count(*)
			from version v11 inner join autor v22 on v11.id_version = v22.id_version
			inner join funcionario v33 on v22.id_funcionario = v33.id_funcionario
			inner join area_centro v44 on v33.id_area_centro = v44.id_area_centro
			inner join centro v55 on v44.id_centro = v55.id_centro
			inner join ciudad v66 on v55.id_ciudad = v66.id_ciudad
			where v11.id_estado = 7 and date_format( v11.fecha_vigencia ,'%m %y') = mes 
			and v44.id_area_centro = v4.id_area_centro
			
		) as inhabilitados
		from version v1 inner join autor v2 on v1.id_version = v2.id_version
		inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario and v2.principal = 1
		inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
		inner join centro ce on v4.id_centro = ce.id_centro
		inner join ciudad v6 on ce.id_ciudad = v6.id_ciudad
		where v1.id_estado = 6 ";
        
        set contenido2 = "
		group by date_format(v1.fecha_publicacion,'%m %y'),v6.nom_ciudad,ce.nom_centro";
    end;
when 7 then 
	begin
		-- cantidad de pv creados o actualizaciones por cada funcionario
		set contenido = "
        select date_format(v1.fecha_publicacion,'%m') as mes,concat(v6.nom_ciudad) as ciudad,concat(ce.nom_centro) as centro,concat(v7.nom_area) as area,concat(v3.nom_funcionario,"" "",v3.apellidos) as funcionario,count(*) as publicaciones
		from version v1 inner join autor v2 on v1.id_version = v2.id_version
		inner join funcionario v3 on v2.id_funcionario = v3.id_funcionario 
		inner join area_centro v4 on v3.id_area_centro = v4.id_area_centro
		inner join centro ce on v4.id_centro = ce.id_centro
		inner join ciudad v6 on ce.id_ciudad = v6.id_ciudad
		inner join area   v7 on v4.id_area = v7.id_area
		where v1.id_estado in (6,7) ";
        
        set contenido2 = "
		group by date_format(v1.fecha_publicacion,'%m %y'),v6.nom_ciudad,ce.nom_centro,v7.nom_area,v3.nom_funcionario";
    end;
end case;

if (idcentro_var <> 0) then
	set where_var = concat(where_var , " and ce.id_centro = " , idcentro_var);
end if;
if (mes_var <> 0) then
	set where_var = concat(where_var , " and date_format(v1.fecha_publicacion,'%m') = " , mes_var);
end if;
if (anio_var <> 0) then
	set where_var = concat(where_var ," and date_format(v1.fecha_publicacion,'%y') = " , anio_var);
end if;

 call macc(concat(contenido,where_var,contenido2));
    -- select (concat(contenido,wherecentro,idcentro,contenido2));
     -- select (concat(contenido,where_var,contenido2));
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultavistaactualizar` (IN `arrayvistaactualizar` VARCHAR(50))  begin
    call execute_array(
			arrayvistaactualizar,
            "~",
            "case @i
				when 0 then set @idpv = @valor;
				when 1 then set @idversion = @valor;
				when 2 then set @val = @valor;
			end case;"
        );
     case (@val)
        when 1 then 
          select v1.* ,v2.nom_formato
          from producto_virtual v1 inner join formato v2 on v1.id_formato = v2.id_formato
          where id_p_virtual = @idpv;
        when 2 then
          select * from 22_v_autor_simple where id_version = @idversion;
        when 3 then
          select  id_tema, nom_tema
          from 06_v_detalles_tema 
          where id_p_virtual = @idpv and tipo_tema = 0;
        when 4 then
          select  id_tema, nom_tema
          from 06_v_detalles_tema 
          where id_p_virtual = @idpv and tipo_tema = 1;
     end case;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultavistasubirpv` (IN `arrayconsultavistasubir` VARCHAR(100))  begin
declare camino_var,idtipoformato_var integer default 0;

  call execute_array(
		arrayconsultavistasubir,
		"~",
		"case @i
			when 0 then set @camino_var = @valor;
			when 1 then set @idtipoformato_var = @valor;
		end case;"
	);

set camino_var 	= @camino_var,
	idtipoformato_var 	= @idtipoformato_var;

case (camino_var)
when 1 then
begin
	select id_tipo_formato, nom_tipo_formato
    from tipo_formato;
end;
when 2 then
begin
	select v2.id_formato, v2.nom_formato
    from tipo_formato v1 inner join formato v2 on v1.id_tipo_formato = v2.id_tipo_formato
    where v1.id_tipo_formato = idtipoformato_var;
end;
end case;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `correccionversion` (IN `arraycorrecion` VARCHAR(2000), OUT `nomurl` VARCHAR(50))  begin

	call execute_array(
		arraycorrecion,
        "~",
        "case @i
			when 0 then set @idfuncionario = @valor;
			when 1 then set @idversion = @valor;
		end case"
    );
    

	select id_funcionario into @idfun
    from version v1 inner join autor v2 on v1.id_version = v2.id_version
    where v1.id_version = @idversion and principal = 1;
    
    call sara_crud("select","version","id_estado into @oldestado","id_version = @idversion");
    call sara_crud("select","version","url_version into @oldurl","id_version = @idversion");
    
    select concat("id1",@idfuncionario,"---  id2",@idfun);
    
    if(@idfuncionario = @idfun)then -- cambio en la validacion ------------------------
		
		select id_centro into @idcentro
		from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro
		where id_funcionario = @idfun;
		
        if(@oldestado = 9 or @oldestado = 10)then-- cambio de estados 9-3 y 10-4
        
			case  @oldestado
				when 9 then set @rol = 2, @newestado = 3;-- @newestado 12/042017
                when 10 then set @rol = 3, @newestado = 4;-- @newestado 12/042017
            end case;
            
			select v1.id_funcionario into @ideval
			from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro 
			 inner join rol_funcionario v3 on v1.id_funcionario = v3.id_funcionario and v3.vigencia = 1
			where id_centro = @idcentro and id_rol = @rol;
            
            call sara_crud("update","version",concat("id_estado~",@newestado,"|fecha_envio~",current_timestamp,""),concat("id_version = ",@idversion,""));-- @newestado 12/042017
            call registarnotificaion(concat("nuevo producto virtual corregido ha evaluar para equipo~1~",@idfun,"~",@ideval,"~",@idversion,""));
            
            update version set url_version = nameurl(@idversion) where id_version = @idversion;-- nuevo nombre 16/04/2017
            set nomurl = nameurl(@idversion);-- retorna el nombre del archivo
        end if;
        else signal sqlstate "45000" set message_text = "usuario no aceptado o url no actualizado";
    end if;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `execute_array` (IN `array` VARCHAR(500), IN `separador` CHAR(1), IN `contenido` VARCHAR(1000))  begin
	
	set @i = 0;set @valor = "";set @cant = 0;
    bucle : while(true)do
		set @valor = substring_index(array,separador,1);
        set @cant = char_length(array) - char_length(@valor);
        set array = right(array,@cant-1);
        call macc(contenido);
        
        if(char_length(array) = 0) then
			leave bucle;
        end if;
        set @i = @i + 1;
    end while bucle;
    set @i = 0;set @valor = "";set @cant = 0;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `formato_procedure` (IN `arrayformato` VARCHAR(400))  begin

declare opcion integer(1);
declare idformato_var integer default 0;
declare nomformato_var varchar(50);
declare desformato_var varchar(100);
declare idtipoformato_var varchar(100);
declare i,num,cant integer default 0;
declare valor varchar(400) default "";


set @opcion = 0,
	@idformato_var = 0,
    @nomformato_var = "0",
	@desformato_var = "0",
    @idtipoformato_var = 0;

call execute_array(
		arrayformato,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idformato_var = @valor;
            when 2 then set @nomformato_var = @valor;
            when 3 then set @desformato_var = @valor;
            when 4 then set @idtipoformato_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idformato_var = @idformato_var,
    nomformato_var = @nomformato_var,
	desformato_var = @desformato_var,
    idtipoformato_var = @idtipoformato_var;
    

case opcion
when 1 then
begin -- crear area
	insert into formato values (null,nomformato_var,desformato_var,idtipoformato_var);
end;
when 2 then 
begin -- modificar area
	update formato 
    set nom_formato = nomformato_var, des_formato = desformato_var, id_tipo_formato = idtipoformato_var
    where id_formato = idformato_var;
end;
else select * from formato;
end case;
select * from formato;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `infodb` (IN `arrayinfodb` VARCHAR(200))  begin
	
    
    call execute_array(
		arrayinfodb,"~",
        "case @i 
			when 0 then set @valdb    	 	= @valor;
			when 1 then set @valint 	  	= @valor;
			when 2 then set @valtabla 	  	= @valor;
		end case;");
        
    set @cont = -1;
	case (@valint) 
		when 1 then 
                    set @cont1 = -1;
					select distinct it.table_name as tablas,1 as tipot, @cont := @cont + 1 as posicion
					from  information_schema.tables it
					where it.table_schema = @valdb and table_type = "base table"
					group by  it.table_name,table_type 
                    union 
                    select distinct it.table_name as tablas,2 as tipot, @cont1 := @cont1 + 1 as posicion
					from  information_schema.tables it
					where it.table_schema = @valdb and table_type = "view"
					group by  it.table_name,table_type 
                    order by tablas, tipot;
		when 2 then 
					select column_name as columnas, @cont := @cont + 1 as posicioncolum
                    from information_schema.columns ic
                    where ic.table_schema = @valdb and table_name = @valtabla;
		when 3 then 
					select distinct it.table_name as tablas
					from  information_schema.tables it
					where it.table_schema = @valdb and table_type = "base table" and it.table_name not like '%_log';
    end case;
 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `arraylogin` VARCHAR(100))  begin
	declare numfun_var double default 0;
    declare contrasenia_var varchar(300) default "";
    
    call execute_array(
		arraylogin,
        "~",
        "case @i
			when 0 then set @numfun_var = @valor;
			when 1 then set @contrasenia_var = @valor; 
        end case;"
    );
    
    set numfun_var = @numfun_var,
		contrasenia_var = @contrasenia_var;
	
    if(
		select 1 
        from funcionario 
        where num_documento = numfun_var and contraseña = contrasenia_var
    )then
        
        select 1 as tipouser,rf.id_rol,fu.id_funcionario,fu.nom_funcionario,ac.id_centro
        from funcionario fu 
        inner join rol_funcionario rf on fu.id_funcionario = rf.id_funcionario and rf.vigencia = 1
        inner join area_centro ac on fu.id_area_centro = ac.id_area_centro
        where fu.num_documento = numfun_var and fu.contraseña = contrasenia_var;
        
        else if(
			select 1 
            from admin where usuario = numfun_var and clave = contrasenia_var
        )then
			select 2 as tipouser,5 as id_rol 
            from admin where usuario = numfun_var and clave = contrasenia_var;
        end if;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `macc` (IN `concatenacion` VARCHAR(2000))  begin
	set @var = concatenacion;
    prepare var from @var;
    execute var;
    deallocate prepare var;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `misproductos` (IN `idfuncionario_var` VARCHAR(5))  begin

    select distinct pv.id_p_virtual,pv.nom_p_virtual,v.num_version, e.nom_estado,v.fecha_envio ,v.url_version,f.id_funcionario
    from version v 
    inner join producto_virtual pv on v.id_p_virtual = pv.id_p_virtual
    inner join autor a on v.id_version = a.id_version 
    inner join funcionario f on a.id_funcionario = f.id_funcionario
    inner join estado	e	 on v.id_estado = e.id_estado
    where f.id_funcionario = idfuncionario_var;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modificarcontraseña` (IN `arraycontraseña` VARCHAR(100))  begin
	declare idfun_var integer default 0;
	declare numfun_var double default 0; 
    declare contractual_var varchar(300);
    declare contrnueva_var varchar(300);
    
    call execute_array(
		arraycontraseña,
		"~",
		"case @i
			when 0 then set @idfun_var = @valor;
			when 1 then set @numfun_var = @valor;
            when 2 then set @contractual_var = @valor;
            when 3 then set @contrnueva_var = @valor;
		end case;"
	);
    
    set idfun_var = @idfun_var,
		numfun_var = @numfun_var,
        contractual_var = @contractual_var,
        contrnueva_var = @contrnueva_var;
	
    if( select 1
		from funcionario 
        where num_documento = numfun_var and id_funcionario = idfun_var and contraseña = contractual_var
    )then
		update funcionario 
        set contraseña = contrnueva_var
        where id_funcionario = idfun_var;
    end if;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modificarlista` (IN `arraymodificar` VARCHAR(400))  begin
	call execute_array(
		arraymodificar,
        "~",
        "case @i
			when 0 then set @id_lista_chequeo = @valor;
			when 1 then set @nom_lista_chequeo = @valor;
			when 2 then set @des_lista_chequeo = @valor;
			when 3 then set @array_items = @valor;
        end case;"
    );
    
    update lista_chequeo 
    set nom_lista_chequeo = @nom_lista_chequeo, des_lista_chequeo = @des_lista_chequeo
    where id_lista_chequeo = @id_lista_chequeo;
    
    if (@array_items)then
		set @i = 0;
		set @num = m_length(@array_items,",");
		while(@i < @num)do
			set @valor = substring_index(@array_items,",",1);
			set @cant = char_length(@array_items) - char_length(@valor);
			set @array_items = right(@array_items,@cant -1);
			call sara_crud("insert","detalles_lista",concat("id_lista_chequeo~",@id_lista_chequeo,"|id_item_lista~",@valor,""),"");
			set @i = @i + 1;
		end while;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modificarperfil` (IN `arrayperfil` VARCHAR(100))  begin
declare idfun_var integer default 0;
declare nomfun_var varchar(45) default "";
declare apefun_var varchar(100) default "";
declare idtipoident_var integer default 0;
declare numfun_var double default 0;
declare ipsena_var varchar(6);
declare cargo_var  varchar(45);
declare correo_var varchar(125);


  call execute_array(
		arrayperfil,
		"~",
		"case @i
			when 0 then set @idfun_var = @valor;
			when 1 then set @nomfun_var = @valor;
            when 2 then set @apefun_var = @valor;
            when 3 then set @idtipoident_var = @valor;
            when 4 then set @numfun_var = @valor;
            when 5 then set @ipsena_var = @valor;
            when 6 then set @cargo_var = @valor;
            when 7 then set @correo_var = @valor;
		end case;"
	);

set idfun_var 	= @idfun_var,
	nomfun_var 	= @nomfun_var,
    apefun_var 	= @apefun_var,
    idtipoident_var = @idtipoident_var,
    numfun_var 	= @numfun_var,
    ipsena_var 	= @ipsena_var,
    cargo_var 	= @cargo_var,
    correo_var 	= @correo_var;

update funcionario 
set id_tipo_documento 	= idtipoident_var,
	num_documento 		= numfun_var,
	nom_funcionario 	= nomfun_var,
	apellidos 			= apefun_var,
	correo 				= correo_var,
	cargo 				= cargo_var,
	ip_sena 			= ipsena_var
where id_funcionario = idfun_var;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `programa_procedure` (IN `arrayprograma` VARCHAR(400))  begin

declare opcion integer(1);
declare idprograma_var integer default 0;
declare nomprograma_var varchar(100);
declare nivelformacion_var varchar(45);
declare arraytemas_var varchar(100) default "0";
declare i,num,cant integer default 0;
declare valor varchar(400) default "";

set @opcion = 0,
	@idprograma_var = 0,
    @nomprograma_var = "0",
	@nivelformacion_var = "0",
    @arraytemas_var = "0";

call execute_array(
		arrayprograma,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idprograma_var = @valor;
            when 2 then set @nomprograma_var = @valor;
            when 3 then set @nivelformacion_var = @valor;
            when 4 then set @arraytemas_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idprograma_var = @idprograma_var,
    nomprograma_var = @nomprograma_var,
	nivelformacion_var = @nivelformacion_var,
    arraytemas_var = @arraytemas_var;
    

case opcion
when 1 then
begin -- crear programa
	insert into programa values(null,nomprograma_var,nivelformacion_var);
    select id_programa into idprograma_var from programa 
    where nom_programa = nomprograma_var and nivel_formacion = nivelformacion_var;
    select id_programa,nom_programa,nivel_formacion from programa;
end;
when 2 then 
begin -- modificar probrama
    update programa 
    set nom_programa = nomprograma_var, nivel_formacion = nivelformacion_var
    where id_programa = idprograma_var;
    select id_programa,nom_programa,nivel_formacion from programa;
end;
when 3 then
begin -- multiselect - modificar

    select te.id_tema,te.nom_tema,case(
		select 1 from detalles_programa v1 
        where v1.id_tema = te.id_tema and v1.id_programa = idprograma_var
    ) when 1 then 1 
	  else 0 end as tipo
    from tema te;
    
end;
else select id_programa,nom_programa,nivel_formacion from programa;
end case;
if(opcion <> 3 and arraytemas_var <> "0")then 
	set num = m_length(arraytemas_var,",");
    while(i < num)do
		set valor = substring_index(arraytemas_var,",",1);
        set cant = char_length(arraytemas_var) - char_length(valor);
        set arraytemas_var = right(arraytemas_var,cant -1);
			call sara_crud("insert","detalles_programa",concat("id_tema~",valor,"|id_programa~",idprograma_var,""),"");
        set i = i + 1;
    end while;
end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registaractualizacion` (IN `arrayactualizacion` VARCHAR(2000), OUT `nomurl` VARCHAR(50))  begin
  call execute_array(
		arrayactualizacion,
        "~",
        "case @i
			when 0 then set @idpro = @valor;
			when 1 then set @url_version = @valor;
			when 2 then set @url_img = @valor;
			when 3 then set @inst_instalacion = @valor;
			when 4 then set @reqst_instalacion = @valor;
			when 5 then set @arrayfuncionario = @valor;
			when 6 then set @arraytemas = @valor;
        end case;"
    );
    select "1";
    
    if(@arraytemas != "null")then-- 20/04/2017
		set @i = 0;
		set @num = m_length(@arraytemas,",");
		while(@i < @num)do
			 set @i = @i + 1;
				set @arrayt = substring_index(@arraytemas,",",1);
				set @cant = char_length(@arraytemas) - char_length(@arrayt);
				set @arraytemas = right(@arraytemas,@cant -1);
				set @a = 0;
				while(@a < 2)do
					set @val = substring_index(@arrayt,"-",1);
					set @cant = char_length(@arrayt) - char_length(@val);
					set @arrayt = right(@arrayt,@cant -1);
					case @a
						when 0 then set @idtema = @val; 
						when 1 then set @tipo 	= @val;
					end case;
					set @a = @a + 1;        
				end while;
				call sara_crud("insert","detalles_tema",concat("id_tema~",@idtema,"|id_p_virtual~",@idpro,"|tipo_tema~",@tipo,""),"");
				set @i = @i + 1;
			end while;
    end if;
    
    
    call registrarversion(concat("",@idpro,"~",@url_version,"~",@url_img,"~",@inst_instalacion,"~",@reqst_instalacion,"~",@arrayfuncionario,""),nomurl);
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registarnotificaion` (IN `arraydatos` VARCHAR(1000))  begin
		call execute_array(
			arraydatos,
            "~",
            "case @i
				when 0 then set @contenido = @valor;
				when 1 then set @idtipo = @valor;
				when 2 then set @idfun = @valor;
				when 3 then set @arrayfun = @valor;
                when 4 then set @ides = @valor;
			end case;"
        );
    
    
    set @numrt = 0;
    

        call macc(concat( 
		" select count(*) into @numrt
		 from 18_v_notificaciones v1 
		 inner join version v2 on v1.ides_proceso = v2.id_version
		 inner join funcionario v3 on v1.id_funcionarioenvio = v3.id_funcionario
		 inner join rol_funcionario v4 on v3.id_funcionario = v4.id_funcionario and v4.vigencia = 1
		 inner join rol v5 on v4.id_rol = v5.id_rol
		 where conte_notificacion = """,@contenido,"""
			and id_tipo_notificacion = 3
			and v4.id_rol = 4 
			and ides_proceso = ",@ides,"
			and v2.id_estado in (6,7)
			and v1.id_funcionarioenvio = ",@idfun,"
			and v1.id_funcionario in (",@arrayfun,");"));
       
    select @numrt,@contenido,@ides,@idfun,@arrayfun;
    
    if(@numrt = 0)then
		select "entro 1";
		call sara_crud("insert","notificacion",concat("conte_notificacion~",@contenido,"|id_tipo_notificacion~",@idtipo,"|id_funcionario~",@idfun,"|ides_proceso~",@ides,""),"");
		call sara_crud("select","notificacion","id_notificacion into @idnoti","conte_notificacion = @contenido and id_tipo_notificacion = @idtipo and id_funcionario = @idfun and ides_proceso = @ides order by id_notificacion desc limit 1");
       
        set @i = 0;
		set @num = m_length(@arrayfun,",");
		while(@i < @num)do
			set @valor = substring_index(@arrayfun,",",1);
			set @cant = char_length(@arrayfun) - char_length(@valor);
			set @arrayfun = right(@arrayfun,@cant -1);
            
                select  @idnoti,@valor,@num;
				call sara_crud("insert","detalles_notificacion",concat("id_notificacion~",@idnoti,"|id_funcionario~",@valor,""),"");
			set @i = @i + 1;
		end while;
		else signal sqlstate "45000" set message_text = "ya se encuentra un registro con dichos datos";
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarcategoria` (IN `arraycategoria` VARCHAR(500))  begin
	call execute_array(
    arraycategoria,
    "~",
    "case @i 
		when 0 then set @nomcategoria  = @valor; 
        when 1 then set @descategoria  = @valor;
        when 2 then set @idfuncionario = @valor;
        when 3 then set @arraytemas 	= @valor;
    end case;"
    );
    
    call sara_crud("insert","categoria",concat("nom_categoria~",@nomcategoria,"|des_categoria~",@descategoria,"|id_funcionario~",@idfuncionario,""),"");
    call sara_crud("select","categoria","id_categoria into @idcate","nom_categoria = @nomcategoria and des_categoria = @descategoria");
    
     set @i = 0;
    set @num = m_length(@arraytemas,",");
    while(@i < @num)do
		set @valor = substring_index(@arraytemas,",",1);
        set @cant = char_length(@arraytemas) - char_length(@valor);
        set @arraytemas = right(@arraytemas,@cant -1);
			call sara_crud("insert","detalles_categoria",concat("id_categoria~",@idcate,"|id_tema~",@valor,""),"");
        set @i = @i + 1;
    end while;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarevaluacion` (IN `arrayevaluacion` VARCHAR(500))  begin

    call execute_array(
		arrayevaluacion,"~",
        "case @i 
			when 0 then set @observaciong 	= @valor;
			when 1 then set @resultado 	  	= @valor;
			when 2 then set @idversion 	  	= @valor;
			when 3 then set @idlista 	  	= @valor;
			when 4 then set @idfuncionario 	= @valor;
            when 5 then set @fechavigencia  = @valor;
			when 6 then set @arrayevaitems 	= @valor;
		end case;");
        
	select "1";
	select  count(*) into @contrepro
    from evaluacion_general
    where id_version = @idversion and resultado = 0 and id_funcionario = @idfuncionario; 
    
    select id_estado into @idestado
    from version 
    where id_version = @idversion;
    
    
    if(@contrepro < 3 and @idestado in (3,4))then
    select "2";
		call sara_crud("insert","evaluacion_general",concat("observacion~",@observaciong,"|resultado~",@resultado,"|id_version~",@idversion,"|id_lista_chequeo~",@idlista,"|id_funcionario~",@idfuncionario,""),"");
		call sara_crud("select","evaluacion_general","id_evaluacion_general into @idevaluacion","id_evaluacion_general > 0 order by id_evaluacion_general desc limit 1");
    
    begin-- validacion de estado y actualizacion del mismo
    	
        set @idprod = 0;
        
        select id_p_virtual into @idprod from version where id_version = @idversion;
        
        if(@resultado = 1)then
    		case @idestado
    			when 3 then update version set id_estado = 4 where id_version = @idversion;
                when 4 then 
                begin 
    				
                    set @val = 0;
    				select count(*) into @val
    				from version 
    				where id_p_virtual = @idprod and id_estado = 5;
    				
    				if (@val > 0) then
                    
    					update version set id_estado = 11,num_version = round(num_version) where id_version = @idversion;
                        
                        else update version set id_estado = 5,num_version = round(num_version) where id_version = @idversion;
    				
    				end if;
                end;
                
            end case;
            
        end if;
    end;
    
    
    -- ------------------------------------ validacion solucion fecha-----------------------------------------------------------------------

 
		-- call sara_crud("select","08_v_funcionario","id_rol into @rol",
		-- concat("id_funcionario = ",@idfuncionario," and id_rol in (2,3)"));
        
        select id_rol into @rol
        from funcionario fu inner join rol_funcionario rf on fu.id_funcionario = rf.id_funcionario and rf.vigencia = 1
        where fu.id_funcionario = @idfuncionario and id_rol in (2,3);
    
	if(@rol = 2 and @resultado = 1)then
    
		if(@fechavigencia = "null")then 
			set @fechavigencia = concat(date_add(curdate(), interval 1 month)," 18:00:00");	
		end if;	
    
		 call sara_crud("update","version",concat("fecha_publicacion~",@fechavigencia,""),concat("id_version = ",@idversion,""));
         
         else if (@rol = 3 and @resultado = 1)then
    
			call sara_crud("select","version","fecha_publicacion into @fechavigencia",concat("id_version = ",@idversion,""));
            
            call sara_crud("update","version",concat("fecha_vigencia~",@fechavigencia,""),concat("id_version = ",@idversion,""));
            
            else if((@rol = 2 or  @rol = 3) and @resultado = 0) then
                
				if(@fechavigencia = "null")then 
					set @fechavigencia = concat(date_add(curdate(), interval 3 day)," 18:00:00");	
				end if;	
				call sara_crud("update","version",concat("fecha_vigencia~",@fechavigencia,""),concat("id_version = ",@idversion,""));
            
			end if;
         end if;
         
    end if;
    
    -- -------------------------------------------------------------------------------
	
    select "3";
    set @i = 0;
	set @num = m_length(@arrayevaitems,"|");
	while(@i < @num)do
		set @arraye = substring_index(@arrayevaitems,"|",1);
        set @cant = char_length(@arrayevaitems) - char_length(@arraye);
        set @arrayevaitems = right(@arrayevaitems,@cant -1);  
        set @a = 0;
        
        while(@a < 3 )do
			set @val = substring_index(@arraye,"¤",1);
			set @cant = char_length(@arraye) - char_length(@val);
			set @arraye = right(@arraye,@cant -1);
				
                case @a
					when 0 then set @valorizacion = @val;
                    when 1 then set @observacionitem = @val;
                    when 2 then set @iddetalleslista = @val;
                end case;
            set @a = @a + 1;        
        end while;
        select @valorizacion,@observacionitem,@iddetalleslista,@idevaluacion;
        call sara_crud("insert","detalles_evaluacion",concat("valorizacion~",@valorizacion,"|observacion~",@observacionitem,"|id_detalles_lista~",@iddetalleslista,"|id_evaluacion_general~",@idevaluacion,""),"");

        set @i = @i + 1;
    end while;
    
    -- si fue aceptado por parte del e tecnico
    call sara_crud("select","version","id_estado into @estado1","id_version = @idversion");
    call sara_crud("select","version","url_version into @urlver","id_version = @idversion");
    
    select id_centro into @idcentro
    from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro
    where id_funcionario = @idfuncionario;
    
    select  count(*) into @contrepro
    from evaluacion_general
    where id_version = @idversion and resultado = 0 and id_funcionario = @idfuncionario;
    
    select v3.nom_rol into @nomrol
    from funcionario v1 
	inner join rol_funcionario v2 on v1.id_funcionario = v2.id_funcionario and v2.vigencia = 1
	inner join rol v3 on v2.id_rol = v3.id_rol
	where v2.id_funcionario = @idfuncionario;
    
    select "entro0",@resultado,@estado1;
    if(@resultado = 1 and @estado1 = 4)then
		
        select v1.id_funcionario into @ideval
		from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro 
		inner join rol_funcionario v3 on v1.id_funcionario = v3.id_funcionario and v3.vigencia = 1
		where id_centro = @idcentro and id_rol = 3;
        
		call registarnotificaion(concat("nuevo producto virtual ha evaluar para ep~1~",@idfuncionario,"~",@ideval,"~",@idversion,""));
        
        -- call registarnotificaion(concat("el producto virtual ",@idversion," ",@estado1,"a pasado a la siguiente face de evaluacion",@i+@a,"~3~",@idfuncionario,"~",@idfun2,""));
        
        else if(@resultado = 1 and @estado1 = 5 or @estado1 = 11) then
			
            select v1.id_funcionario  into @idcoor
			from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro 
			inner join rol_funcionario v3 on v1.id_funcionario = v3.id_funcionario and v3.vigencia = 1
			where id_centro = @idcentro and id_rol = 4;
            
			call registarnotificaion(concat("nuevo producto virtual ha aprobar co~3~",@idfuncionario,"~",@idcoor,"~",@idversion,""));	
            
            
            -- codigooo largo para el numero version ---------------------------------------------------------
            
            -- cambiar numero version aprobada
				
            -- cambiar el numero de version de las otras versiones que estan en evaluacion
				
                set @lineas = 0;
                select id_p_virtual into @idpro1 from version 
				where id_version = @idversion;
                
				select count(*) into @lineas
				from version
				where id_p_virtual = @idpro1 and id_estado in (3,4,9,10); 
                
                if(@lineas > 0) then
					call updatenumeroversion(@idpro1,@idversion,@idcoor);
                end if;
				
                
            -- ------------------------------------------------------------------------------------------

				else if(@resultado = 0 and (@estado1 = 3 or @estado1 = 4) and @contrepro < 3)then
                
					call all_autor(@idversion,@autores);
					
                    case (@estado1)-- 13/04/2017
						when 3 then set @newestado = 9;
                        when 4 then set @newestado = 10;
                    end case;-- 
                    -- -------------- 12/04/2017
                    update version set id_estado = @newestado -- corregir
					where id_version  = @idversion;
                    -- -----------------
                    
					call registarnotificaion(concat("el producto virtual fue reprovado por el ",@nomrol,"~2~",@idfuncionario,"~",@autores,"~",@idevaluacion,""));	
                    
                    -- --------------------------------------tres intentos errados------------------------------------------------- cambio
                    else if(@contrepro = 3) then
                    
						call all_autor(@idversion,@autores);
                        
						select @autores as autores_1; -- verificacion del datos de autores por si lo pasa bien
                        
                        call registarnotificaion(concat("el producto virtual fue reprovado ins~2~",@idfuncionario,"~",@autores,"~",@idevaluacion,""));	
                    
						call registarnotificaion(concat("el producto virtual, fue reprobado 3 veses por el ",@nomrol,", dejando esta version cancelada~3~",@idfuncionario,"~",@autores,"~",@idversion,""));
                        
						update version set id_estado = 8 -- cancelado
                        where id_version  = @idversion;
                        
                    end if;
					-- ------------------------------------------------------------------------------------- cambio
				end if;
		end if;
    end if;
    else signal sqlstate "45000" set message_text = "la version se encuentra anulada";
    end if;
        
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarfuncionario` (IN `arrayreg` VARCHAR(800))  begin
	call execute_array(
		arrayreg,
        "~",
        "case @i
			when 0 then set @id_rol = @valor;
			when 1 then set @id_tipo_documento = @valor; 
			when 2 then set @num_documento = @valor;
			when 3 then set @nom_funcionario = @valor;
			when 4 then set @apellidos = @valor;
			when 5 then set @correo = @valor;
			when 6 then set @cargo = @valor;
			when 7 then set @ip_sena = @valor;
			when 8 then set @toquen = @valor;
			when 9 then set @id_centro = @valor;
			when 10 then set @id_area = @valor;
        end case;"
    );
    
    set @count = 0;
    if(@id_rol != 1)then
		select count(*) into @count
		from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro inner join
			 rol_funcionario v3 on v1.id_funcionario = v3.id_funcionario and v3.vigencia = 1
		where id_centro = @id_centro and id_rol = @id_rol;
    end if;
    select @count;
    if(@count = 0 )then
		call sara_crud("select","area_centro","id_area_centro into @idac","id_centro = @id_centro and id_area = @id_area");
		call sara_crud("insert","funcionario",concat("id_tipo_documento~",@id_tipo_documento,"|num_documento~",@num_documento,"|nom_funcionario~",@nom_funcionario,"|apellidos~",@apellidos,"|correo~",@correo,"|cargo~",@cargo,"|ip_sena~",@ip_sena,"|id_area_centro~",@idac,""),"");
		call sara_crud("select","funcionario","id_funcionario into @idfun","num_documento = @num_documento"); 
        
		call sara_crud("insert","rol_funcionario",concat("id_rol~",@id_rol,"|id_funcionario~",@idfun,"|vigencia~1"),"");
		call sara_crud("insert","toquen",concat("numero_toquen~",@toquen,"|funcionario~",@idfun,"|fechavigencia~",date_add(curdate(), interval 7 day)," 18:00:00"),"");
	else signal sqlstate "45000" set message_text = "lo siento, ya existe un funcionario con ese rol y centro de formacion";
    end if;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registraritem_tema` (IN `arrayitems_temas` VARCHAR(400))  begin
	call execute_array(
		arrayitems_temas,
        ",",
        "case @i
			when 0 then set @eleccion = @valor;
			when 1 then set @arrayeleccion = @valor;
        end case;"
    );
    if(@eleccion = 1)then
		call execute_array(
			@arrayeleccion,
			"~",
			"case @i
				when 0 then set @desitemlista = @valor;
				when 1 then set @tipoitem = @valor;
			end case;"
		);
        insert into item_lista values(null,@desitemlista,@tipoitem);
        select id_item_lista into @iditem from item_lista where des_item_lista = @desitemlista and tipo_item = @tipoitem;
        select id_item_lista, des_item_lista from item_lista where id_item_lista = @iditem;
        
        else if(@eleccion = 2)then
			call execute_array(
			@arrayeleccion,
			"~",
			"case @i
				when 0 then set @nomtema = @valor;
				when 1 then set @destema = @valor;
			end case;"
		);
        insert into tema values (null,@nomtema,@destema);
        select id_tema into @idtema from tema where nom_tema = @nomtema and des_tema = @destema;
        select id_tema, nom_tema from tema where id_tema = @idtema;
        end if;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarlista` (IN `arraylista` VARCHAR(500))  begin

	call execute_array(
		arraylista,
        "~",
        "case @i
			when 0 then set @nom_lista_chequeo = @valor;
			when 1 then set @des_lista_chequeo = @valor;
			when 2 then set @id_funcionario = @valor;
			when 3 then set @array_items = @valor;
        end case;"
    );
    call sara_crud("insert","lista_chequeo",concat("nom_lista_chequeo~",@nom_lista_chequeo,"|des_lista_chequeo~",@des_lista_chequeo,"|id_funcionario~",@id_funcionario,""),"");

	call sara_crud("select","lista_chequeo","id_lista_chequeo into @idlist","nom_lista_chequeo  = @nom_lista_chequeo");

    set @i = 0;
    set @num = m_length(@array_items,",");
    while(@i < @num)do
		set @valor = substring_index(@array_items,",",1);
        set @cant = char_length(@array_items) - char_length(@valor);
        set @array_items = right(@array_items,@cant -1);
		call sara_crud("insert","detalles_lista",concat("id_lista_chequeo~",@idlist,"|id_item_lista~",@valor,""),"");
        set @i = @i + 1;
    end while;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarrankin` (IN `arrayregistrarrankin` VARCHAR(50))  begin
  declare idprod        integer default 0;
  declare idrankin      integer default 0;
  declare numerocaso    integer(1)default 0;
  declare idver_prod    integer default 0;
  declare idfuncionario integer default 0;
  declare numvoto       integer(1) default 0;
  
  set @numerocaso = null,@idver_prod = null,@idfuncionario = null,@numvoto = null;
  
  call execute_array(
		arrayregistrarrankin,"~",
        "case @i 
			when 0 then set @numerocaso	 	      = @valor;
			when 1 then set @idver_prod 	  	  = @valor;
			when 2 then set @idfuncionario 	  	= @valor;
			when 3 then set @numvoto 	  	      = @valor;
		end case;");
   
  set numerocaso = @numerocaso,
  idver_prod = @idver_prod,
  idfuncionario = @idfuncionario,
  numvoto = @numvoto;

  select id_rankin into idrankin from rankin where id_version = idver_prod;
  
  case numerocaso
  
     when 1 then 
     -- aumenta una unidad a la cantidad de visitas que tiene un pv y este
     -- numero es compartido por todas las versiones
     begin
        
        select id_p_virtual into idprod 
        from version where id_version = idver_prod;
        
        update rankin v1 inner join version v2 on v1.id_version = v2.id_version
        set cant_visitas = cant_visitas + 1 
        where id_p_virtual = idprod;
        
     end; 
     when 2 then
     -- aumenta una unidad a la cantidad de descargas que tiene la version
     begin
        update rankin
        set cant_descargas = cant_descargas + 1 
        where id_rankin = idrankin;
     end;
     when 3 then 
     -- inserta o actualiza el voto que tiene un determinado usuario con respecto a una determinada version
     begin
        if (
          select true from voto
          where id_rankin = idrankin and id_funcionario = idfuncionario
        ) then
        
          update voto set num_voto = numvoto 
          where id_funcionario = idfuncionario and id_rankin = idrankin; 
          
          else begin
            insert into voto values ( null, numvoto,idfuncionario, idrankin );
            update rankin set cant_votos = cant_votos + 1 where id_rankin = idrankin;
          end;
        end if;
        
     end;
  end case;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarversion` (IN `arrayversion` VARCHAR(2000), OUT `nomurl` VARCHAR(50))  begin

declare numver float default 1;

set @idver = null;


	call execute_array(
		arrayversion,
        "~",
        "case @i
			when 0 then set @idpro = @valor;
			when 1 then set @url_version = @valor;
			when 2 then set @url_img = @valor;
			when 3 then set @inst_instalacion = @valor;
			when 4 then set @reqst_instalacion = @valor;
			when 5 then set @arrayfuncionario = @valor;
        end case;"
    );
    
    select count(*) into @lineas
    from version
    where id_p_virtual = @idpro and id_estado in (6,7);-- 7
    
    
    if(@lineas > 0 )then-- actualizacion
    
		-- -------- num version
        select "entra";
        select count(*) into @lineassub
        from version
        where id_p_virtual = @idpro and id_estado in (3,4,9,10);
        
        
		set @numver = (select max(num_version) 
		from version 
		where id_p_virtual = @idpro and id_estado in (5,6,7,11));-- 7
		
        if (@lineassub >= 0 and @lineassub < 5) then 
			call macc(concat("set @numver = @numver + 1.",(@lineassub + 1),""));
            
			else signal sqlstate "45000" set message_text = "imposible actualizar esta version";
            
        end if;
        set numver = @numver;
	
        -- ------------------
        
	end if;
    
		call sara_crud("insert","version",concat("num_version~",numver,"|url_version~",@url_version,"|url_img~",@url_img,"|inst_instalacion~",@inst_instalacion,"|reqst_instalacion~",@reqst_instalacion ,"|id_p_virtual~",@idpro,""),"");
		-- call sara_crud("select","version","id_version into @idver","inst_instalacion = @inst_instalacion and reqst_instalacion = @reqst_instalacion");
		
        
        select @inst_instalacion,@reqst_instalacion,@idpro,numver;
        
        
		select id_version into @idver
		from version v1 inner join producto_virtual v2 on v1.id_p_virtual = v2.id_p_virtual
		where inst_instalacion = @inst_instalacion 
			and reqst_instalacion = @reqst_instalacion 
			and v1.id_p_virtual = @idpro 
			and v1.id_estado = 3
			and v1.num_version = numver
		order by fecha_envio desc limit 1;
        
			
	   set @a = 0;
	   bucle : while (true) do
			set @valor = substring_index(@arrayfuncionario,",",1);
			set @cantidad = char_length(@arrayfuncionario) - char_length(@valor);
			set @arrayfuncionario = right(@arrayfuncionario,@cantidad -1);
				
				if(@a = 0)then
					set @prin = 1;
					set @funprin = @valor;
					else set @prin = 0;
				end if;
                select @idver,@valor;
				call sara_crud("insert","autor",concat("id_version~",@idver,"|id_funcionario~",@valor,"|principal~",@prin,""),"");
			set @a = @a +1;
			if(char_length(@arrayfuncionario) = 0) then
				leave bucle;
			end if;
			
		end while bucle;
		
		select id_centro into @idcentro
		from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro
		where id_funcionario = @funprin; -- se puede hacer desde sara_crud
		
		select v1.id_funcionario,v4.nom_rol into @ideval,@nomrol-- anadir nomrol para la notificacion 14/04/2017
		from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro 
			 inner join rol_funcionario v3 on v1.id_funcionario = v3.id_funcionario and v3.vigencia = 1
			 inner join rol v4 on v3.id_rol = v4.id_rol
		where id_centro = @idcentro and v3.id_rol = 2; -- se puede hacer desde sara_crud
		
		call registarnotificaion(concat("nuevo producto virtual ha evaluar para el ",@nomrol,"~1~",@funprin,"~",@ideval,"~",@idver,""));-- anadir nomrol para la notificacion 14/04/2017
		
		update version set url_version = nameurl(@idver) where id_version = @idver;-- nuevo nombre 16/04/2017
		
		set nomurl = nameurl(@idver);-- retorna el nombre del archivo
        
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_pv` (IN `arraytodo` VARCHAR(2000), OUT `nomurl` VARCHAR(50))  begin

declare i,a,co,num,idpro,idtema,tipo integer default 0;

declare nom_p_virtual_var,des_p_virtual_var,palabras_clave_var,id_formato_var,
		url_version_var,url_img_var,inst_instalacion_var,reqst_instalacion_var,
        arrayfuncionario_var ,arraytema_var varchar(200);
        
declare arrayt varchar(100) default "";
declare cant   integer default 0;
declare val    varchar(100) default "";

select 1;

	call execute_array(
		arraytodo,
		"~",
		"case @i
			when 0 then set @nom_p_virtual = @valor;
			when 1 then set @des_p_virtual = @valor;
			when 2 then set @palabras_clave = @valor;
			when 3 then set @id_formato = @valor;
			when 4 then set @url_version = @valor;
			when 5 then set @url_img = @valor;
			when 6 then set @inst_instalacion= @valor;
			when 7 then set @reqst_instalacion = @valor;
			when 8 then set @arrayfuncionario = @valor;
			when 9 then set @arraytema = @valor;
		end case;"
	);	
    
set nom_p_virtual_var 	= @nom_p_virtual, 
	des_p_virtual_var 	= @des_p_virtual,
	palabras_clave_var 	= @palabras_clave,
	id_formato_var 		= @id_formato,
	url_version_var 	= @url_version,
	url_img_var 		= @url_img,
	inst_instalacion_var	= @inst_instalacion,
	reqst_instalacion_var 	= @reqst_instalacion,
	arrayfuncionario_var 	= @arrayfuncionario,
	arraytema_var 			= @arraytema;

    -- call sara_crud("select","producto_virtual","count(*) into @co","nom_p_virtual = @nom_p_virtual or des_p_virtual = @des_p_virtual");
    
    select count(*) -- into co
    from producto_virtual
    where nom_p_virtual = nom_p_virtual_var or des_p_virtual = des_p_virtual_var;
    
    if (co = 0) then 
		call sara_crud("insert","producto_virtual",concat("nom_p_virtual~",nom_p_virtual_var,"|des_p_virtual~",des_p_virtual_var,"|palabras_clave~",palabras_clave_var,"|id_formato~",id_formato_var,""),"");
		
        -- call sara_crud("select","producto_virtual","id_p_virtual into @idpro","nom_p_virtual = @nom_p_virtual");
        
        select id_p_virtual into idpro
        from producto_virtual
        where nom_p_virtual = nom_p_virtual_var;
        
        select idpro,nom_p_virtual_var; 
        
		set i = 0;
		set num = m_length(arraytema_var,",");
        
        select num;
        
        
		while(i < num)do
         -- set i = i + 1;
         
        select "entro1_";
        
			set arrayt = substring_index(arraytema_var,",",1);
			set cant = char_length(arraytema_var) - char_length(arrayt);
			set arraytema_var = right(arraytema_var,cant -1);
			set a = 0;
			while(a < 2)do
            
            select "entro2_";
				set val = substring_index(arrayt,"-",1);
				set cant = char_length(arrayt) - char_length(val);
				set arrayt = right(arrayt,cant -1);
				case a
					when 0 then set idtema = val; 
					when 1 then set tipo 	= val;
				end case;
				set a = a + 1;        
			end while;
            
            select idtema,tipo,idpro;
            
			call sara_crud("insert","detalles_tema",concat("id_tema~",idtema,"|id_p_virtual~",idpro,"|tipo_tema~",tipo,""),"");
			set i = i + 1;
		end while;
		call registrarversion(concat("",idpro,"~",url_version_var,"~",url_img_var,"~",inst_instalacion_var,"~",reqst_instalacion_var,"~",arrayfuncionario_var,""),nomurl);
        
        else signal sqlstate "45000" set message_text = "el nombre del producto o los detalles del mismo ya existen ";
	end if;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sara_crud` (IN `sentencia` VARCHAR(40), IN `tabla` VARCHAR(70), IN `array_datos1` VARCHAR(500), IN `array_datos2` VARCHAR(500))  begin
declare i integer default 0;declare a integer default 0;declare num integer default 0;
declare arraycolum varchar(500);declare val varchar(500);declare cant integer;
declare columnas varchar(500) default "";declare conjunto varchar(500) default "";declare valores  varchar(500) default "";

	set sentencia = m_remove(sentencia);
    set tabla = m_remove(tabla);
    set array_datos2 = m_remove(array_datos2);
    
    if(array_datos2 != " " or array_datos2 != null)then
		set array_datos2 = concat("where ", array_datos2);
    end if;
    
	set i = 0;
	set num = m_length(array_datos1,"|");
	while(i < num)do
        set array_datos1 = m_remove(array_datos1);
		set arraycolum = substring_index(array_datos1,"|",1);
        set cant = char_length(array_datos1) - char_length(arraycolum);
        set array_datos1 = right(array_datos1,cant -1);
        
        set a = 0;
        while(a < 2)do
			set arraycolum = m_remove(arraycolum);
			set val = substring_index(arraycolum,"~",1);
			set cant = char_length(arraycolum) - char_length(val);
			set arraycolum = right(arraycolum,cant -1);
            set val = m_remove(val);
            case a
				when 0 then 
					begin
						if(val != "")then
							if(i = 0 and (sentencia = "insert" or sentencia = "select"))then
								set columnas = val; 
                                elseif(i > 0 and (sentencia = "insert" or sentencia = "select"))then
									set columnas = concat(columnas ,",", val);
							end if;
                            if(i = (num-1) and sentencia = "insert")then 
								set columnas = rpad(columnas,char_length(columnas)+1,")");
								set columnas = lpad(columnas,char_length(columnas)+1,"(");
							end if;
                            elseif(sentencia = "select")then set columnas = "*";
								else set columnas = "";
                        end if;
                        
                        if(i = 0 and sentencia = "update")then
                            set conjunto = concat(val," = ");
                            elseif(i > 0 and sentencia = "update")then
                            set conjunto = concat(conjunto,",",val," = ");
                        end if;
                    end;
                when 1 then 
					begin
						if(i = 0 and sentencia = "insert")then
							set valores = concat("'",val,"'"); 
							elseif(i > 0 and sentencia = "insert")then
							set valores = concat(valores ,",'", val,"'");
                        end if;
                        if(sentencia = "update")then
                            set conjunto = concat(conjunto," '",val,"'");
                        end if;
                    end;
            end case;
            set a = a + 1; 
        end while;    
		set i = i + 1;
    end while;
    
	case sentencia
		when "insert" then set @exec = 	(concat("insert into ",tabla," ",columnas," values(",valores,")"));
        when "update" then set @exec =	(concat("update ",tabla," set ",conjunto," ",array_datos2,""));
        when "select" then set @exec =	(concat("select distinct ",columnas," from ",tabla," ",array_datos2,""));
        when "delete" then set @exec =	(concat("delete from ",tabla," ",array_datos2,""));
    end case;
    
    prepare exec from @exec;
    execute exec;
    deallocate prepare exec;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tema_procedure` (IN `arraytema` VARCHAR(200))  begin

declare	opcion		integer(1);
declare idtema_var integer default 0;
declare	nomtema_var varchar(45);
declare	destema_var varchar(100);

set @opcion = 0,
	@idtema_var = 0,
    @nomtema_var = "0",
	@destema_var = "0";
    
call execute_array(
		arraytema,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idtema_var = @valor;
            when 2 then set @nomtema_var = @valor;
            when 3 then set @destema_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idtema_var = @idtema_var,
    nomtema_var = @nomtema_var,
	destema_var = @destema_var;
    
case opcion
when 1 then 
begin -- crear tema
	insert into tema values(null,nomtema_var,destema_var);
end;
when 2 then
begin -- modificar tema
	update tema 
    set nom_tema = nomtema_var,
		des_tema = destema_var
	where id_tema = idtema_var;
end;
else select id_tema,nom_tema,des_tema from tema;-- retorna esto
end case;

select id_tema,nom_tema,des_tema from tema;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `time_limit` ()  begin

	declare done integer default false;
    declare idver integer;
    declare fechav timestamp;
    declare idest integer;
    declare cur cursor for 
    select id_version, date_format(fecha_vigencia,'%y-%m-%d'),id_estado
    from version where id_estado in (6,7);
    
    declare continue handler for not found set done = true;
    
    select id_version, date_format(fecha_vigencia,'%y-%m-%d') 
    from version where id_estado in (6,7);-- select
    
    set @fechaa  = date_format(current_timestamp,'%y-%m-%d');
    open cur;
    read_loop:loop
    
		fetch cur into idver,fechav,idest;
        
        if done then leave read_loop; end if;-- posible salida
        
        -- valida que el pv no tenga una nueva version
        select count(*) into @validarnuevov
		from version v1 inner join producto_virtual  v2 on v1.id_p_virtual = v2.id_p_virtual
		where v1.id_p_virtual = (select id_p_virtual from version where id_version = idver) 
			and id_estado in (6,7)-- num version 
			and num_version > (select num_version from version where id_version = idver); 
        
		
        select v1.id_funcionario into @idfunc
        from funcionario v1 inner join rol_funcionario v2 on v1.id_funcionario = v2.id_funcionario and v2.vigencia = 1
			inner join area_centro v3 on v1.id_area_centro = v3.id_area_centro
		where id_centro = 
        (
			select id_centro 
			from funcionario v1 
				inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro
				inner join autor v3 on v1.id_funcionario = v3.id_funcionario
			where v3.id_version = idver and principal = 1
        ) and id_rol = 4;
        
        select idver;-- 
        
        call all_autor(idver,@autores);
        
        select @autores as au;
        
        if(fechav = @fechaa and idest = 6)then
			select "time 1";-- 
            
			update version
            set id_estado = 7
            where id_version = idver;
            
            call registarnotificaion(concat("la version fue inhabilitada por ser obsoleta~3~",@idfunc,"~",@autores,"~",idver,""));	
            
            else if(fechav = date_add(@fechaa, interval 7 day ) and idest = 6 and @validarnuevov = 0)then
            
				select "time 2";-- 
                
				call registarnotificaion(concat("la version debe ser actualizada antes de 7 dias~3~",@idfunc,"~",@autores,"~",idver,""));
                
                else if( @fechaa = date_add(fechav, interval 7 day) and idest = 7 and @validarnuevov = 0)then
					
                    select "time 3";--



                    
					select @idfunc,@autores,idver;-- 
                    
					call registarnotificaion(concat("la version debe ser actualizada yaque fue inhabilitada hace 7 dias~3~",@idfunc,"~",@autores,"~",idver,""));
                    
                end if;
            end if;
        end if;
		
    end loop;
    close cur;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tipoformato_procedure` (IN `arraytipoformato` VARCHAR(400))  begin

declare opcion integer(1);
declare idtipoformato_var integer default 0;
declare nomtipoformato_var varchar(60);
declare urlimgtipoformato_var varchar(100);

set @opcion = 0,
	@idtipoformato_var = 0,
    @nomtipoformato_var = "0",
	@urlimgtipoformato_var = "0";

call execute_array(
		arraytipoformato,
        "~",
        "case @i
			when 0 then set @opcion = @valor;
			when 1 then set @idtipoformato_var = @valor;
            when 2 then set @nomtipoformato_var = @valor;
            when 3 then set @urlimgtipoformato_var = @valor;
        end case;"
    );

set opcion = @opcion,
	idtipoformato_var = @idtipoformato_var,
    nomtipoformato_var = @nomtipoformato_var,
	urlimgtipoformato_var = @urlimgtipoformato_var;
    

case opcion
when 1 then
begin -- crear tipo formato
	insert into tipo_formato values (null,nomtipoformato_var,urlimgtipoformato_var);
end;
when 2 then 
begin -- modificar tipo formato
	update tipo_formato 
    set nom_tipo_formato = nomtipoformato_var, urlimgtipoformato = urlimgtipoformato_var
    where id_tipo_formato = idtipoformato_var;
end;
else select * from tipo_formato;
end case;
select * from tipo_formato;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatenumeroversion` (IN `idpro` INTEGER, IN `idveraprobada` INTEGER, IN `idcoordinador` INTEGER)  begin
	declare u,c,cont integer;
    declare numid integer;
    declare idis varchar(100);
    declare valor varchar(100);
    declare cant  integer;
    declare autoresversion varchar(200);
    declare numver1 float(2);
	declare numold1 float(2);
    
	set sql_safe_updates = 0;
    drop temporary table if exists tmpversion;
    
    create temporary table tmpversion(
		idversion integer ,
        numversion float,
        numold float);
	
	set @o = 0;
    
	call macc(concat("
    insert into tmpversion
     select id_version, round(num_version + 1.0) + (@o := @o +1)*0.1 ,num_version
     from version
     where id_p_virtual = ",idpro," and id_estado in (3,4,9,10)
     order by fecha_envio asc;"));
     
     select * from tmpversion;
     
     update version v1
     set v1.num_version = (select v2.numversion from tmpversion v2 where v2.idversion = v1.id_version)
     where v1.id_p_virtual = idpro and v1.id_estado in (3,4,9,10);
        
	set cont = 0;
    select count(*) into cont
    from tmpversion;
    
    set c = 0;
    set idis = "0";
    while(c < cont)do
			call macc(concat("select idversion into @idver 
            from tmpversion where idversion not in (",idis,") order by idversion asc limit 1"));
            
            if(c = 0)then
				set idis = @idver;
                else set idis = concat(idis,",",@idver);
            end if;
            set c = c + 1;
    end while;
    
    select idis;
    
   
    
    set u = 0;
		set numid = m_length(idis,",");
		while(u < numid)do
			set valor = substring_index(idis,",",1);
			set cant = char_length(idis) - char_length(valor);
			set idis = right(idis,cant -1);
            
            call all_autor(valor,autoresversion);
            
            select numversion,numold into numver1,numold1 from tmpversion where idversion = valor;
            
            select @numver1,numold1 ,idcoordinador,autoresversion,valor,numid,u;
            
            call registarnotificaion(concat("el numero de la version a sido modificado de ",numold1," a ",numver1,"~3~",idcoordinador,"~",autoresversion,"~",valor,""));	
            
			set u = u + 1;
		end while;
	 select "---",numver1,numold1 ,idcoordinador,autoresversion,valor,numid,u;
     drop temporary table if exists tmpversion;
end$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `m_length` (`array` VARCHAR(1000), `separador` CHAR(1)) RETURNS INT(11) begin 
	declare	contador integer default 1;
    declare valor varchar(500);
    declare cantidad integer;
    bucle : while (true) do
		
        set valor = substring_index(array,separador,1);
        set cantidad = char_length(array) - char_length(valor);
        set array = right(array,cantidad -1);
        
        if(char_length(array) = 0) then
			leave bucle;
        end if;
        
        set contador = contador + 1; 
    end while bucle;
    return contador;
    
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `m_remove` (`cadena` VARCHAR(500)) RETURNS VARCHAR(500) CHARSET latin1 begin
	return replace(replace(trim(cadena),"\n",""),"\t","");
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `nameurl` (`idver` INTEGER) RETURNS VARCHAR(50) CHARSET latin1 begin
  set @idver = idver;
  select id_estado, id_p_virtual into @idestado,@idpro
  from version where id_version = @idver;
  
  if(@idestado in (6,7))then
    set @tipover = 2;
    elseif (@idestado in (3,4,5,9,10))then set @tipover = 1;
  end if;
  
  case (@tipover)
    when 1 then 
        select count(*) into @numver
        from 18_v_notificaciones 
        where id_tipo_notificacion = 1 and ides_proceso = @idver;
    when 2 then
        select num_version into @numver 
        from  version
        where id_version = @idver;
  end case;
  
  select v2.nom_formato into @formato 
  from producto_virtual v1 inner join formato v2 on v2.id_formato = v1.id_formato
  where v1.id_p_virtual = @idpro;
  
  set @idpro = lpad(@idpro,3,"0");
  set @numver = lpad(@numver/0.1,2,"0");-- num version 
  set @idver = lpad(@idver,3,"0");
  
  set @nomurl = concat(@tipover,"-",@idpro,"-",@numver,"-",@idver,".",@formato);
  
  return @nomurl;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `01_v_detalles_lista`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `01_v_detalles_lista` (
`id_lista_chequeo` int(11)
,`nom_lista_chequeo` varchar(100)
,`des_lista_chequeo` varchar(200)
,`fecha_creacion` timestamp
,`id_funcionario` int(11)
,`id_item_lista` int(11)
,`des_item_lista` varchar(300)
,`tipo_item` tinyint(1)
,`id_detalles_lista` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `02_v_area_centro`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `02_v_area_centro` (
`id_area_centro` int(11)
,`id_centro` int(11)
,`num_centro` varchar(50)
,`nom_centro` varchar(100)
,`direccion` varchar(100)
,`id_ciudad` int(11)
,`nom_ciudad` varchar(75)
,`id_area` int(11)
,`nom_area` varchar(100)
,`lider_area` varchar(70)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `03_v_detalles_area`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `03_v_detalles_area` (
`id_detalles_area` int(11)
,`id_area` int(11)
,`nom_area` varchar(100)
,`lider_area` varchar(70)
,`id_programa` int(11)
,`nom_programa` varchar(100)
,`nivel_formacion` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `04_v_detalles_programa`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `04_v_detalles_programa` (
`id_detalles_programa` int(11)
,`id_programa` int(11)
,`nom_programa` varchar(100)
,`nivel_formacion` varchar(45)
,`id_tema` int(11)
,`nom_tema` varchar(45)
,`des_tema` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `05_v_detalles_categoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `05_v_detalles_categoria` (
`id_categoria` int(11)
,`nom_categoria` varchar(45)
,`des_categoria` varchar(100)
,`fecha_creacion` timestamp
,`id_funcionario` int(11)
,`id_detalles_categoria` int(11)
,`id_tema` int(11)
,`nom_tema` varchar(45)
,`des_tema` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `06_v_detalles_tema`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `06_v_detalles_tema` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`palabras_clave` varchar(100)
,`id_formato` int(11)
,`nom_formato` varchar(50)
,`des_formato` varchar(100)
,`id_detalles_tema` int(11)
,`id_tema` int(11)
,`nom_tema` varchar(45)
,`des_tema` varchar(100)
,`tipo_tema` tinyint(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `07_v_version`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `07_v_version` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`palabras_clave` varchar(100)
,`id_formato` int(11)
,`id_version` int(11)
,`fecha_envio` timestamp
,`fecha_publicacion` timestamp
,`num_version` float
,`fecha_vigencia` timestamp
,`url_version` varchar(500)
,`url_img` varchar(500)
,`inst_instalacion` varchar(800)
,`reqst_instalacion` varchar(500)
,`id_estado` int(11)
,`nom_estado` varchar(50)
,`id_tipo_estado` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `08_v_funcionario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `08_v_funcionario` (
`id_rol_funcionario` int(11)
,`id_rol` int(11)
,`nom_rol` varchar(45)
,`des_rol` varchar(100)
,`id_funcionario` int(11)
,`id_tipo_documento` int(11)
,`nom_tipo_documento` varchar(100)
,`num_documento` double
,`nom_funcionario` varchar(45)
,`apellidos` varchar(100)
,`correo` varchar(125)
,`cargo` varchar(45)
,`ip_sena` varchar(6)
,`contraseña` varchar(300)
,`id_estado` int(11)
,`id_area_centro` int(11)
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `09_v_autor`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `09_v_autor` (
`id_autor` int(11)
,`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`palabras_clave` varchar(100)
,`id_formato` int(11)
,`id_version` int(11)
,`fecha_envio` timestamp
,`fecha_publicacion` timestamp
,`num_version` float
,`fecha_vigencia` timestamp
,`url_version` varchar(500)
,`url_img` varchar(500)
,`inst_instalacion` varchar(800)
,`reqst_instalacion` varchar(500)
,`id_estado` int(11)
,`nom_estado` varchar(50)
,`id_tipo_estado` int(11)
,`id_rol_funcionario` int(11)
,`id_rol` int(11)
,`nom_rol` varchar(45)
,`des_rol` varchar(100)
,`id_funcionario` int(11)
,`id_tipo_documento` int(11)
,`nom_tipo_documento` varchar(100)
,`num_documento` double
,`nom_funcionario` varchar(45)
,`apellidos` varchar(100)
,`correo` varchar(125)
,`cargo` varchar(45)
,`ip_sena` varchar(6)
,`contraseña` varchar(300)
,`id_estadofun` int(11)
,`id_area_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `10_habilitar_p`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `10_habilitar_p` (
`id_version` int(11)
,`nom_p_virtual` varchar(100)
,`num_version` float
,`fecha_vigencia` timestamp
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `11_v_area`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `11_v_area` (
`id_area` int(11)
,`nom_area` varchar(100)
,`id_centro` int(11)
,`nom_centro` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `12_inabilitar_funcionario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `12_inabilitar_funcionario` (
`id_funcionario` int(11)
,`nombrecompleto` varchar(146)
,`ip_sena` varchar(6)
,`cargo` varchar(45)
,`nom_rol` varchar(45)
,`nom_estado` varchar(50)
,`nom_area` varchar(100)
,`nom_centro` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `13_v_listas_chequeo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `13_v_listas_chequeo` (
`id_lista_chequeo` int(11)
,`nom_lista_chequeo` varchar(100)
,`des_lista_chequeo` varchar(200)
,`fecha_creacion` timestamp
,`id_funcionario` int(11)
,`id_rol` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `14_v_titulos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `14_v_titulos` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `15_v_subir_autores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `15_v_subir_autores` (
`id_funcionario` int(11)
,`nom_funcionario` varchar(45)
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `16_v_items_lista`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `16_v_items_lista` (
`id_item_lista` int(11)
,`des_item_lista` varchar(300)
,`tipo_item` tinyint(1)
,`id_lista_chequeo` int(11)
,`id_detalles_lista` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `17_v_productosevaluador`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `17_v_productosevaluador` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`id_version` int(11)
,`num_version` float
,`fecha_vigencia` timestamp
,`id_estado` int(11)
,`nom_estado` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `18_v_notificaciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `18_v_notificaciones` (
`id_funcionario` int(11)
,`nom_funcionario` varchar(45)
,`id_rol` int(11)
,`nom_rol` varchar(45)
,`id_notificacion` int(11)
,`fecha_envio` timestamp
,`conte_notificacion` varchar(600)
,`ides_proceso` int(11)
,`id_funcionarioenvio` int(11)
,`estado` tinyint(1)
,`id_centro` int(11)
,`id_tipo_notificacion` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `19_v_temasformacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `19_v_temasformacion` (
`id_tema` int(11)
,`nom_tema` varchar(45)
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `20_v_login`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `20_v_login` (
`id_rol` int(11)
,`id_funcionario` int(11)
,`nom_funcionario` varchar(45)
,`id_centro` int(11)
,`num_documento` double
,`contraseña` varchar(300)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `21_v_asignarrol`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `21_v_asignarrol` (
`id_funcionario` int(11)
,`nombrecompleto` varchar(146)
,`cargo` varchar(45)
,`id_centro` int(11)
,`nom_centro` varchar(100)
,`id_area` int(11)
,`nom_area` varchar(100)
,`id_ciudad` int(11)
,`nom_ciudad` varchar(75)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `22_v_autor_simple`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `22_v_autor_simple` (
`id_funcionario` int(11)
,`nombrecompleto` varchar(146)
,`id_version` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `23_v_consultar`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `23_v_consultar` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`palabras_clave` varchar(100)
,`fecha_publicacion` timestamp
,`fecha_vigencia` timestamp
,`inst_instalacion` varchar(800)
,`reqst_instalacion` varchar(500)
,`url_version` varchar(500)
,`id_version` int(11)
,`num_version` float
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `24_v_toquen`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `24_v_toquen` (
`numero_toquen` varchar(20)
,`funcionario` int(11)
,`fechavigencia` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `25_v_evaluarproductosv`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `25_v_evaluarproductosv` (
`id_funcionario` int(11)
,`nom_funcionario` varchar(45)
,`id_rol` int(11)
,`nom_rol` varchar(45)
,`id_notificacion` int(11)
,`fecha_envio` timestamp
,`conte_notificacion` varchar(600)
,`ides_proceso` int(11)
,`id_funcionarioenvio` int(11)
,`estado` tinyint(1)
,`id_centro` int(11)
,`id_tipo_notificacion` int(11)
,`url_version` varchar(500)
,`producto` varchar(113)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `26_v_comentarios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `26_v_comentarios` (
`id_comentario` int(11)
,`comentario` varchar(500)
,`id_funcionario` int(11)
,`nombre_completo` varchar(146)
,`id_version` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `27_v_autores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `27_v_autores` (
`id_funcionario` int(11)
,`nombrecompleto` varchar(146)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `28_v_consultacategoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `28_v_consultacategoria` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`id_formato` int(11)
,`fecha_publicacion` timestamp
,`id_funcionario` int(11)
,`id_categoria` int(11)
,`id_version` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `29_v_consultaprograma`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `29_v_consultaprograma` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`id_formato` int(11)
,`fecha_publicacion` timestamp
,`id_funcionario` int(11)
,`id_programa` int(11)
,`id_version` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `30_v_consultanormal`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `30_v_consultanormal` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`palabras_clave` varchar(100)
,`fecha_publicacion` timestamp
,`id_version` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `31_v_estadisticatipo1`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `31_v_estadisticatipo1` (
`id_formato` int(11)
,`nom_formato` varchar(50)
,`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`fecha_publicacion` timestamp
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `32_v_estadisticatipo2`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `32_v_estadisticatipo2` (
`id_formato` int(11)
,`nom_formato` varchar(50)
,`cantidad` bigint(21)
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `33_v_estadisticaarea1`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `33_v_estadisticaarea1` (
`id_area` int(11)
,`nom_area` varchar(100)
,`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`fecha_publicacion` timestamp
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `34_v_estadisticaarea2`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `34_v_estadisticaarea2` (
`id_area` int(11)
,`nom_area` varchar(100)
,`cantidad` bigint(21)
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `35_v_estadisticacategoria1`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `35_v_estadisticacategoria1` (
`id_categoria` int(11)
,`nom_categoria` varchar(45)
,`id_p_virtual` int(11)
,`fecha_publicacion` timestamp
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `36_v_estadisticacategoria2`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `36_v_estadisticacategoria2` (
`id_categoria` int(11)
,`nom_categoria` varchar(45)
,`canti` bigint(21)
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `37_v_evaluaciongeneral`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `37_v_evaluaciongeneral` (
`id_evaluacion_general` int(11)
,`id_lista_chequeo` int(11)
,`nom_lista_chequeo` varchar(100)
,`valorizacion` tinyint(1)
,`observacion` varchar(200)
,`id_item_lista` int(11)
,`des_item_lista` varchar(300)
,`observacion_general` varchar(250)
,`resultado` tinyint(1)
,`fecha_evaluacion` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `38_v_notificaciones_ar`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `38_v_notificaciones_ar` (
`id_funcionario` int(11)
,`nom_funcionario` varchar(45)
,`id_rol` int(11)
,`nom_rol` varchar(45)
,`id_notificacion` int(11)
,`fecha_envio` timestamp
,`conte_notificacion` varchar(600)
,`ides_proceso` int(11)
,`nom_p_virtual` varchar(100)
,`num_version` float
,`id_funcionarioenvio` int(11)
,`estado` tinyint(1)
,`id_centro` int(11)
,`id_tipo_notificacion` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `39_v_listacategoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `39_v_listacategoria` (
`id_categoria` int(11)
,`nom_categoria` varchar(45)
,`fecha_creacion` timestamp
,`id_centro` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `40_v_evaluaversion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `40_v_evaluaversion` (
`id_evaluacion_general` int(11)
,`nom_p_virtual` varchar(100)
,`num_version` float
,`id_version` int(11)
,`url_version` varchar(500)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `41_v_consultatodo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `41_v_consultatodo` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`des_p_virtual` varchar(200)
,`id_formato` int(11)
,`id_tipo_formato` int(11)
,`nom_tipo_formato` varchar(60)
,`fecha_publicacion` timestamp
,`id_version` int(11)
,`id_funcionario` int(11)
,`nombrecompleto` varchar(146)
,`id_programa` int(11)
,`id_categoria` int(11)
,`tipo_tema` tinyint(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `42_v_productosactualizar`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `42_v_productosactualizar` (
`id_p_virtual` int(11)
,`nom_p_virtual` varchar(100)
,`id_funcionario` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `43_v_consultatodonotificacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `43_v_consultatodonotificacion` (
`id_notificacion` int(11)
,`fecha_envio` timestamp
,`conte_notificacion` varchar(600)
,`ides_proceso` int(11)
,`tipoides` int(1)
,`id_tipo_notificacion` int(11)
,`idfuncionarioenvia` int(11)
,`nomfuncionarioenvia` varchar(45)
,`idareacentroenvia` int(11)
,`idcentroenvia` int(11)
,`idrolenvia` int(11)
,`estadonotificacion` tinyint(1)
,`id_detalles_notificacion` int(11)
,`idfuncionariorecibe` int(11)
,`idnomfuncionariorecibe` varchar(45)
,`idareacentrorecibe` int(11)
,`idcentrorecibe` int(11)
,`idrolrecibe` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `45_consultapuestos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `45_consultapuestos` (
`puesto` int(11)
,`producto` varchar(100)
,`version` float
,`centro` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `admin`
--

CREATE TABLE `admin` (
  `usuario` int(11) NOT NULL,
  `clave` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `admin`
--

INSERT INTO `admin` (`usuario`, `clave`) VALUES
(1029, 'e10adc3949ba59abbe56e057f20f883e');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area`
--

CREATE TABLE `area` (
  `id_area` int(11) NOT NULL,
  `nom_area` varchar(100) NOT NULL,
  `lider_area` varchar(70) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `area`
--

INSERT INTO `area` (`id_area`, `nom_area`, `lider_area`) VALUES
(1, 'teleinformatica', 'gustabo'),
(2, 'mercadeo', 'carmen'),
(3, 'Red de Cultura.', 'Gustavo');

--
-- Disparadores `area`
--
DELIMITER $$
CREATE TRIGGER `area_insert` AFTER INSERT ON `area` FOR EACH ROW begin
  insert into area_log (tipo_log,id_area,nom_area,lider_area) 
  values ('i',new.id_area,new.nom_area,new.lider_area);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `area_update` AFTER UPDATE ON `area` FOR EACH ROW begin
  insert into area_log (tipo_log,id_area,nom_area,lider_area) 
  values ('u',new.id_area,new.nom_area,new.lider_area); 
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area_centro`
--

CREATE TABLE `area_centro` (
  `id_area_centro` int(11) NOT NULL,
  `id_area` int(11) NOT NULL,
  `id_centro` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `area_centro`
--

INSERT INTO `area_centro` (`id_area_centro`, `id_area`, `id_centro`) VALUES
(1, 1, 1),
(3, 3, 1);

--
-- Disparadores `area_centro`
--
DELIMITER $$
CREATE TRIGGER `area_centro_insert` AFTER INSERT ON `area_centro` FOR EACH ROW begin
  insert into area_centro_log (tipo_log,id_area_centro,id_area,id_centro) 
  values ('i',new.id_area_centro,new.id_area,new.id_centro);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `area_centro_update` AFTER UPDATE ON `area_centro` FOR EACH ROW begin
  insert into area_centro_log (tipo_log,id_area_centro,id_area,id_centro) 
  values ('u',new.id_area_centro,new.id_area,new.id_centro);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area_centro_log`
--

CREATE TABLE `area_centro_log` (
  `id_area_centro_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_area_centro` int(11) NOT NULL,
  `id_area` int(11) NOT NULL,
  `id_centro` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `area_centro_log`
--

INSERT INTO `area_centro_log` (`id_area_centro_log`, `fecha_log`, `tipo_log`, `id_area_centro`, `id_area`, `id_centro`) VALUES
(1, '2019-05-24 14:23:42', 'i', 1, 1, 1),
(2, '2019-05-24 14:23:42', 'i', 2, 2, 2),
(3, '2019-05-24 15:17:28', 'i', 3, 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area_log`
--

CREATE TABLE `area_log` (
  `id_area_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_area` int(11) NOT NULL,
  `nom_area` varchar(100) NOT NULL,
  `lider_area` varchar(70) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `area_log`
--

INSERT INTO `area_log` (`id_area_log`, `fecha_log`, `tipo_log`, `id_area`, `nom_area`, `lider_area`) VALUES
(1, '2019-05-24 14:23:42', 'i', 1, 'teleinformatica', 'gustabo'),
(2, '2019-05-24 14:23:42', 'i', 2, 'mercadeo', 'carmen'),
(3, '2019-05-24 15:07:47', 'i', 3, 'Red de Cultura.', 'Gustavo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

CREATE TABLE `autor` (
  `id_autor` int(11) NOT NULL,
  `id_version` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `principal` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `autor`
--

INSERT INTO `autor` (`id_autor`, `id_version`, `id_funcionario`, `principal`) VALUES
(1, 1, 1, 1);

--
-- Disparadores `autor`
--
DELIMITER $$
CREATE TRIGGER `autor_insert` AFTER INSERT ON `autor` FOR EACH ROW begin
  insert into autor_log (tipo_log,id_autor,id_version,id_funcionario,principal) 
  values ('i',new.id_autor,new.id_version,new.id_funcionario,new.principal);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `autor_update` AFTER UPDATE ON `autor` FOR EACH ROW begin
  insert into autor_log (tipo_log,id_autor,id_version,id_funcionario,principal) 
  values ('u',new.id_autor,new.id_version,new.id_funcionario,new.principal);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor_log`
--

CREATE TABLE `autor_log` (
  `id_autor_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_autor` int(11) NOT NULL,
  `id_version` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `principal` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `autor_log`
--

INSERT INTO `autor_log` (`id_autor_log`, `fecha_log`, `tipo_log`, `id_autor`, `id_version`, `id_funcionario`, `principal`) VALUES
(1, '2019-07-15 14:00:53', 'i', 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id_categoria` int(11) NOT NULL,
  `nom_categoria` varchar(45) NOT NULL,
  `des_categoria` varchar(100) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`id_categoria`, `nom_categoria`, `des_categoria`, `fecha_creacion`, `id_funcionario`) VALUES
(1, 'base de datos', 'como crear', '2019-07-03 20:57:42', 4);

--
-- Disparadores `categoria`
--
DELIMITER $$
CREATE TRIGGER `categoria_insert` AFTER INSERT ON `categoria` FOR EACH ROW begin
  insert into categoria_log (tipo_log,id_categoria,nom_categoria,des_categoria,fecha_creacion,id_funcionario) 
  values ('i',new.id_categoria,new.nom_categoria,new.des_categoria,new.fecha_creacion,new.id_funcionario);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `categoria_update` AFTER UPDATE ON `categoria` FOR EACH ROW begin
  insert into categoria_log (tipo_log,id_categoria,nom_categoria,des_categoria,fecha_creacion,id_funcionario) 
  values ('u',new.id_categoria,new.nom_categoria,new.des_categoria,new.fecha_creacion,new.id_funcionario);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_log`
--

CREATE TABLE `categoria_log` (
  `id_categoria_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `nom_categoria` varchar(45) NOT NULL,
  `des_categoria` varchar(100) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `categoria_log`
--

INSERT INTO `categoria_log` (`id_categoria_log`, `fecha_log`, `tipo_log`, `id_categoria`, `nom_categoria`, `des_categoria`, `fecha_creacion`, `id_funcionario`) VALUES
(1, '2019-07-03 20:57:42', 'i', 1, 'base de datos', 'como crear', '2019-07-03 20:57:42', 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `centro`
--

CREATE TABLE `centro` (
  `id_centro` int(11) NOT NULL,
  `num_centro` varchar(50) NOT NULL,
  `nom_centro` varchar(100) NOT NULL,
  `direccion` varchar(100) NOT NULL,
  `id_ciudad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `centro`
--

INSERT INTO `centro` (`id_centro`, `num_centro`, `nom_centro`, `direccion`, `id_ciudad`) VALUES
(1, '1', 'centro de gestion de mercados, logistica y tecnologias de la información', 'crr 52#', 1);

--
-- Disparadores `centro`
--
DELIMITER $$
CREATE TRIGGER `centro_insert` AFTER INSERT ON `centro` FOR EACH ROW begin
  insert into centro_log (tipo_log,id_centro,num_centro,nom_centro,direccion,id_ciudad) 
  values ('i',new.id_centro,new.num_centro,new.nom_centro,new.direccion,new.id_ciudad);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `centro_update` AFTER UPDATE ON `centro` FOR EACH ROW begin
  insert into centro_log (tipo_log,id_centro,num_centro,nom_centro,direccion,id_ciudad) 
  values ('u',new.id_centro,new.num_centro,new.nom_centro,new.direccion,new.id_ciudad);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `centro_log`
--

CREATE TABLE `centro_log` (
  `id_centro_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_centro` int(11) NOT NULL,
  `num_centro` varchar(50) NOT NULL,
  `nom_centro` varchar(100) NOT NULL,
  `direccion` varchar(100) NOT NULL,
  `id_ciudad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `centro_log`
--

INSERT INTO `centro_log` (`id_centro_log`, `fecha_log`, `tipo_log`, `id_centro`, `num_centro`, `nom_centro`, `direccion`, `id_ciudad`) VALUES
(1, '2019-05-24 14:23:42', 'i', 1, '1', 'centro de gestion de mercados, logistica y tecnologias de la información', 'crr 52#', 1),
(2, '2019-05-24 14:23:42', 'i', 2, '2', 'centro de formacion 2', 'crr 30', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudad`
--

CREATE TABLE `ciudad` (
  `id_ciudad` int(11) NOT NULL,
  `nom_ciudad` varchar(75) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ciudad`
--

INSERT INTO `ciudad` (`id_ciudad`, `nom_ciudad`) VALUES
(1, 'bogotá'),
(2, 'bucaramanga');

--
-- Disparadores `ciudad`
--
DELIMITER $$
CREATE TRIGGER `ciudad_insert` AFTER INSERT ON `ciudad` FOR EACH ROW begin
  insert into ciudad_log (tipo_log,id_ciudad,nom_ciudad) 
  values ('i',new.id_ciudad,new.nom_ciudad);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ciudad_update` AFTER UPDATE ON `ciudad` FOR EACH ROW begin
  insert into ciudad_log (tipo_log,id_ciudad,nom_ciudad) 
  values ('u',new.id_ciudad,new.nom_ciudad);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudad_log`
--

CREATE TABLE `ciudad_log` (
  `id_ciudad_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_ciudad` int(11) NOT NULL,
  `nom_ciudad` varchar(75) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ciudad_log`
--

INSERT INTO `ciudad_log` (`id_ciudad_log`, `fecha_log`, `tipo_log`, `id_ciudad`, `nom_ciudad`) VALUES
(1, '2019-05-24 14:23:42', 'i', 1, 'bogotá'),
(2, '2019-05-24 14:23:42', 'i', 2, 'bucaramanga');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentario`
--

CREATE TABLE `comentario` (
  `id_comentario` int(11) NOT NULL,
  `comentario` varchar(500) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `id_version` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `comentario`
--
DELIMITER $$
CREATE TRIGGER `comentario_insert` AFTER INSERT ON `comentario` FOR EACH ROW begin
  insert into comentario_log (tipo_log,id_comentario,comentario,id_funcionario,id_version) 
  values ('i',new.id_comentario,new.comentario,new.id_funcionario,new.id_version);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `comentario_update` AFTER UPDATE ON `comentario` FOR EACH ROW begin
  insert into comentario_log (tipo_log,id_comentario,comentario,id_funcionario,id_version) 
  values ('u',new.id_comentario,new.comentario,new.id_funcionario,new.id_version);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentario_log`
--

CREATE TABLE `comentario_log` (
  `id_comentario_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_comentario` int(11) NOT NULL,
  `comentario` varchar(500) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `id_version` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_area`
--

CREATE TABLE `detalles_area` (
  `id_detalles_area` int(11) NOT NULL,
  `id_area` int(11) NOT NULL,
  `id_programa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_area`
--

INSERT INTO `detalles_area` (`id_detalles_area`, `id_area`, `id_programa`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 3);

--
-- Disparadores `detalles_area`
--
DELIMITER $$
CREATE TRIGGER `detalles_area_insert` AFTER INSERT ON `detalles_area` FOR EACH ROW begin
  insert into detalles_area_log (tipo_log,id_detalles_area,id_area,id_programa) 
  values ('i',new.id_detalles_area,new.id_area,new.id_programa);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_area_update` AFTER UPDATE ON `detalles_area` FOR EACH ROW begin
  insert into detalles_area_log (tipo_log,id_detalles_area,id_area,id_programa) 
  values ('u',new.id_detalles_area,new.id_area,new.id_programa);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_area_log`
--

CREATE TABLE `detalles_area_log` (
  `id_detalles_area_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_area` int(11) NOT NULL,
  `id_area` int(11) NOT NULL,
  `id_programa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_area_log`
--

INSERT INTO `detalles_area_log` (`id_detalles_area_log`, `fecha_log`, `tipo_log`, `id_detalles_area`, `id_area`, `id_programa`) VALUES
(1, '2019-05-24 14:23:43', 'i', 1, 1, 1),
(2, '2019-05-24 14:23:43', 'i', 2, 1, 2),
(3, '2019-05-24 14:23:43', 'i', 3, 2, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_categoria`
--

CREATE TABLE `detalles_categoria` (
  `id_detalles_categoria` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_categoria`
--

INSERT INTO `detalles_categoria` (`id_detalles_categoria`, `id_categoria`, `id_tema`) VALUES
(1, 1, 1),
(3, 1, 2),
(2, 1, 5);

--
-- Disparadores `detalles_categoria`
--
DELIMITER $$
CREATE TRIGGER `detalles_categoria_insert` AFTER INSERT ON `detalles_categoria` FOR EACH ROW begin
  insert into detalles_categoria_log (tipo_log,id_detalles_categoria,id_categoria,id_tema) 
  values ('i',new.id_detalles_categoria,new.id_categoria,new.id_tema);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_categoria_update` AFTER UPDATE ON `detalles_categoria` FOR EACH ROW begin
  insert into detalles_categoria_log (tipo_log,id_detalles_categoria,id_categoria,id_tema) 
  values ('u',new.id_detalles_categoria,new.id_categoria,new.id_tema);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_categoria_log`
--

CREATE TABLE `detalles_categoria_log` (
  `id_detalles_categoria_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_categoria` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_categoria_log`
--

INSERT INTO `detalles_categoria_log` (`id_detalles_categoria_log`, `fecha_log`, `tipo_log`, `id_detalles_categoria`, `id_categoria`, `id_tema`) VALUES
(1, '2019-07-03 20:57:43', 'i', 1, 1, 1),
(2, '2019-07-03 20:57:43', 'i', 2, 1, 5),
(3, '2019-07-03 20:57:43', 'i', 3, 1, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_evaluacion`
--

CREATE TABLE `detalles_evaluacion` (
  `id_detalles_evaluacion` int(11) NOT NULL,
  `valorizacion` tinyint(1) NOT NULL,
  `observacion` varchar(200) NOT NULL,
  `id_detalles_lista` int(11) NOT NULL,
  `id_evaluacion_general` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `detalles_evaluacion`
--
DELIMITER $$
CREATE TRIGGER `detalles_evaluacion_insert` AFTER INSERT ON `detalles_evaluacion` FOR EACH ROW begin
  insert into detalles_evaluacion_log (tipo_log,id_detalles_evaluacion,valorizacion,observacion,id_detalles_lista,id_evaluacion_general) 
  values ('i',new.id_detalles_evaluacion,new.valorizacion,new.observacion,new.id_detalles_lista,new.id_evaluacion_general);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_evaluacion_update` AFTER UPDATE ON `detalles_evaluacion` FOR EACH ROW begin
  insert into detalles_evaluacion_log (tipo_log,id_detalles_evaluacion,valorizacion,observacion,id_detalles_lista,id_evaluacion_general) 
  values ('u',new.id_detalles_evaluacion,new.valorizacion,new.observacion,new.id_detalles_lista,new.id_evaluacion_general);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_evaluacion_log`
--

CREATE TABLE `detalles_evaluacion_log` (
  `id_detalles_evaluacion_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_evaluacion` int(11) NOT NULL,
  `valorizacion` tinyint(1) NOT NULL,
  `observacion` varchar(200) NOT NULL,
  `id_detalles_lista` int(11) NOT NULL,
  `id_evaluacion_general` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_lista`
--

CREATE TABLE `detalles_lista` (
  `id_detalles_lista` int(11) NOT NULL,
  `id_lista_chequeo` int(11) NOT NULL,
  `id_item_lista` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_lista`
--

INSERT INTO `detalles_lista` (`id_detalles_lista`, `id_lista_chequeo`, `id_item_lista`) VALUES
(1, 1, 3),
(2, 1, 4),
(3, 1, 5),
(4, 1, 6),
(5, 2, 3),
(6, 2, 5),
(8, 3, 3),
(7, 3, 4),
(10, 4, 4),
(9, 4, 6),
(11, 5, 3);

--
-- Disparadores `detalles_lista`
--
DELIMITER $$
CREATE TRIGGER `detalles_lista_insert` AFTER INSERT ON `detalles_lista` FOR EACH ROW begin
  insert into detalles_lista_log (tipo_log,id_detalles_lista,id_lista_chequeo,id_item_lista) 
  values ('i',new.id_detalles_lista,new.id_lista_chequeo,new.id_item_lista);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_lista_update` AFTER UPDATE ON `detalles_lista` FOR EACH ROW begin
  insert into detalles_lista_log (tipo_log,id_detalles_lista,id_lista_chequeo,id_item_lista) 
  values ('u',new.id_detalles_lista,new.id_lista_chequeo,new.id_item_lista);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_lista_log`
--

CREATE TABLE `detalles_lista_log` (
  `id_detalles_lista_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_lista` int(11) NOT NULL,
  `id_lista_chequeo` int(11) NOT NULL,
  `id_item_lista` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_lista_log`
--

INSERT INTO `detalles_lista_log` (`id_detalles_lista_log`, `fecha_log`, `tipo_log`, `id_detalles_lista`, `id_lista_chequeo`, `id_item_lista`) VALUES
(1, '2019-07-15 14:02:35', 'i', 1, 1, 3),
(2, '2019-07-15 14:02:35', 'i', 2, 1, 4),
(3, '2019-07-15 14:02:35', 'i', 3, 1, 5),
(4, '2019-07-15 14:03:03', 'i', 4, 1, 6),
(5, '2019-07-16 13:47:50', 'i', 5, 2, 3),
(6, '2019-07-16 13:47:50', 'i', 6, 2, 5),
(7, '2019-07-16 14:03:02', 'i', 7, 3, 4),
(8, '2019-07-16 14:03:02', 'i', 8, 3, 3),
(9, '2019-07-16 14:05:05', 'i', 9, 4, 6),
(10, '2019-07-16 14:05:05', 'i', 10, 4, 4),
(11, '2019-07-16 14:19:32', 'i', 11, 5, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_notificacion`
--

CREATE TABLE `detalles_notificacion` (
  `id_detalles_notificacion` int(11) NOT NULL,
  `id_notificacion` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_notificacion`
--

INSERT INTO `detalles_notificacion` (`id_detalles_notificacion`, `id_notificacion`, `id_funcionario`) VALUES
(1, 1, 2);

--
-- Disparadores `detalles_notificacion`
--
DELIMITER $$
CREATE TRIGGER `detalles_notificacion_insert` AFTER INSERT ON `detalles_notificacion` FOR EACH ROW begin
  insert into detalles_notificacion_log (tipo_log,id_detalles_notificacion,id_notificacion,id_funcionario) 
  values ('i',new.id_detalles_notificacion,new.id_notificacion,new.id_funcionario);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_notificacion_update` AFTER UPDATE ON `detalles_notificacion` FOR EACH ROW begin
  insert into detalles_notificacion_log (tipo_log,id_detalles_notificacion,id_notificacion,id_funcionario) 
  values ('u',new.id_detalles_notificacion,new.id_notificacion,new.id_funcionario);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_notificacion_log`
--

CREATE TABLE `detalles_notificacion_log` (
  `id_detalles_notificacion_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_notificacion` int(11) NOT NULL,
  `id_notificacion` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_notificacion_log`
--

INSERT INTO `detalles_notificacion_log` (`id_detalles_notificacion_log`, `fecha_log`, `tipo_log`, `id_detalles_notificacion`, `id_notificacion`, `id_funcionario`) VALUES
(1, '2019-07-15 14:00:53', 'i', 1, 1, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_programa`
--

CREATE TABLE `detalles_programa` (
  `id_detalles_programa` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL,
  `id_programa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_programa`
--

INSERT INTO `detalles_programa` (`id_detalles_programa`, `id_tema`, `id_programa`) VALUES
(1, 1, 1),
(2, 2, 1),
(4, 3, 2),
(3, 4, 1),
(5, 4, 2);

--
-- Disparadores `detalles_programa`
--
DELIMITER $$
CREATE TRIGGER `detalles_programa_insert` AFTER INSERT ON `detalles_programa` FOR EACH ROW begin
  insert into detalles_programa_log (tipo_log,id_detalles_programa,id_tema,id_programa) 
  values ('i',new.id_detalles_programa,new.id_tema,new.id_programa);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_programa_update` AFTER UPDATE ON `detalles_programa` FOR EACH ROW begin
  insert into detalles_programa_log (tipo_log,id_detalles_programa,id_tema,id_programa) 
  values ('u',new.id_detalles_programa,new.id_tema,new.id_programa);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_programa_log`
--

CREATE TABLE `detalles_programa_log` (
  `id_detalles_programa_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_programa` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL,
  `id_programa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_programa_log`
--

INSERT INTO `detalles_programa_log` (`id_detalles_programa_log`, `fecha_log`, `tipo_log`, `id_detalles_programa`, `id_tema`, `id_programa`) VALUES
(1, '2019-05-24 14:23:44', 'i', 1, 1, 1),
(2, '2019-05-24 14:23:44', 'i', 2, 2, 1),
(3, '2019-05-24 14:23:44', 'i', 3, 4, 1),
(4, '2019-05-24 14:23:45', 'i', 4, 3, 2),
(5, '2019-05-24 14:23:45', 'i', 5, 4, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_tema`
--

CREATE TABLE `detalles_tema` (
  `id_detalles_tema` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL,
  `id_p_virtual` int(11) NOT NULL,
  `tipo_tema` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_tema`
--

INSERT INTO `detalles_tema` (`id_detalles_tema`, `id_tema`, `id_p_virtual`, `tipo_tema`) VALUES
(1, 1, 1, 1);

--
-- Disparadores `detalles_tema`
--
DELIMITER $$
CREATE TRIGGER `detalles_tema_insert` AFTER INSERT ON `detalles_tema` FOR EACH ROW begin
  insert into detalles_tema_log (tipo_log,id_detalles_tema,id_tema,id_p_virtual,tipo_tema) 
  values ('i',new.id_detalles_tema,new.id_tema,new.id_p_virtual,new.tipo_tema);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_tema_update` AFTER UPDATE ON `detalles_tema` FOR EACH ROW begin
  insert into detalles_tema_log (tipo_log,id_detalles_tema,id_tema,id_p_virtual,tipo_tema) 
  values ('u',new.id_detalles_tema,new.id_tema,new.id_p_virtual,new.tipo_tema);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_tema_log`
--

CREATE TABLE `detalles_tema_log` (
  `id_detalles_tema_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_detalles_tema` int(11) NOT NULL,
  `id_tema` int(11) NOT NULL,
  `id_p_virtual` int(11) NOT NULL,
  `tipo_tema` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalles_tema_log`
--

INSERT INTO `detalles_tema_log` (`id_detalles_tema_log`, `fecha_log`, `tipo_log`, `id_detalles_tema`, `id_tema`, `id_p_virtual`, `tipo_tema`) VALUES
(1, '2019-07-15 14:00:53', 'i', 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `id_estado` int(11) NOT NULL,
  `nom_estado` varchar(50) NOT NULL,
  `id_tipo_estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`id_estado`, `nom_estado`, `id_tipo_estado`) VALUES
(1, 'activo', 1),
(2, 'inactivo', 1),
(3, 'evaluando equipo tecnico', 2),
(4, 'evaluando equipo pedagogico', 2),
(5, 'pendiente coordinador', 2),
(6, 'habilitado', 2),
(7, 'inhabilitado', 2),
(8, 'cancelado', 2),
(9, 'corregir equipo tecnico', 2),
(10, 'corregir equipo pedagogico', 2),
(11, 'espera coordinador', 2);

--
-- Disparadores `estado`
--
DELIMITER $$
CREATE TRIGGER `estado_insert` AFTER INSERT ON `estado` FOR EACH ROW begin
  insert into estado_log (tipo_log,id_estado,nom_estado,id_tipo_estado) 
  values ('i',new.id_estado,new.nom_estado,new.id_tipo_estado);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `estado_update` AFTER UPDATE ON `estado` FOR EACH ROW begin
  insert into estado_log (tipo_log,id_estado,nom_estado,id_tipo_estado) 
  values ('u',new.id_estado,new.nom_estado,new.id_tipo_estado);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_log`
--

CREATE TABLE `estado_log` (
  `id_estado_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_estado` int(11) NOT NULL,
  `nom_estado` varchar(50) NOT NULL,
  `id_tipo_estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estado_log`
--

INSERT INTO `estado_log` (`id_estado_log`, `fecha_log`, `tipo_log`, `id_estado`, `nom_estado`, `id_tipo_estado`) VALUES
(1, '2019-05-24 14:23:48', 'i', 1, 'activo', 1),
(2, '2019-05-24 14:23:48', 'i', 2, 'inactivo', 1),
(3, '2019-05-24 14:23:48', 'i', 3, 'evaluando equipo tecnico', 2),
(4, '2019-05-24 14:23:48', 'i', 4, 'evaluando equipo pedagogico', 2),
(5, '2019-05-24 14:23:48', 'i', 5, 'pendiente coordinador', 2),
(6, '2019-05-24 14:23:48', 'i', 6, 'habilitado', 2),
(7, '2019-05-24 14:23:48', 'i', 7, 'inhabilitado', 2),
(8, '2019-05-24 14:23:48', 'i', 8, 'cancelado', 2),
(9, '2019-05-24 14:23:48', 'i', 9, 'corregir equipo tecnico', 2),
(10, '2019-05-24 14:23:48', 'i', 10, 'corregir equipo pedagogico', 2),
(11, '2019-05-24 14:23:48', 'i', 11, 'espera coordinador', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluacion_general`
--

CREATE TABLE `evaluacion_general` (
  `id_evaluacion_general` int(11) NOT NULL,
  `fecha_evaluacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `observacion` varchar(250) NOT NULL,
  `resultado` tinyint(1) NOT NULL,
  `id_version` int(11) NOT NULL,
  `id_lista_chequeo` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `evaluacion_general`
--
DELIMITER $$
CREATE TRIGGER `evaluacion_general_insert` AFTER INSERT ON `evaluacion_general` FOR EACH ROW begin
  insert into evaluacion_general_log (tipo_log,id_evaluacion_general,fecha_evaluacion,observacion,resultado,id_version,id_lista_chequeo,id_funcionario) 
  values ('i',new.id_evaluacion_general,new.fecha_evaluacion,new.observacion,new.resultado,new.id_version,new.id_lista_chequeo,new.id_funcionario);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `evaluacion_general_update` AFTER UPDATE ON `evaluacion_general` FOR EACH ROW begin
  insert into evaluacion_general_log (tipo_log,id_evaluacion_general,fecha_evaluacion,observacion,resultado,id_version,id_lista_chequeo,id_funcionario) 
  values ('u',new.id_evaluacion_general,new.fecha_evaluacion,new.observacion,new.resultado,new.id_version,new.id_lista_chequeo,new.id_funcionario);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluacion_general_log`
--

CREATE TABLE `evaluacion_general_log` (
  `id_evaluacion_general_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_evaluacion_general` int(11) NOT NULL,
  `fecha_evaluacion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `observacion` varchar(250) NOT NULL,
  `resultado` tinyint(1) NOT NULL,
  `id_version` int(11) NOT NULL,
  `id_lista_chequeo` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formato`
--

CREATE TABLE `formato` (
  `id_formato` int(11) NOT NULL,
  `nom_formato` varchar(50) NOT NULL,
  `des_formato` varchar(100) NOT NULL,
  `id_tipo_formato` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `formato`
--

INSERT INTO `formato` (`id_formato`, `nom_formato`, `des_formato`, `id_tipo_formato`) VALUES
(1, 'txt', 'texto plano', 2),
(2, 'log', 'texto plano', 2),
(3, 'dot', 'word', 2),
(4, 'doc', 'word', 2),
(5, 'xls', 'excel', 2),
(6, 'xlm', 'excel', 2),
(7, 'xlt', 'excel', 2),
(8, 'xlv', 'excel', 2),
(9, 'mdb', 'acces', 2),
(10, 'ppt', 'powerpoint', 2),
(11, 'pps', 'powerpoint', 2),
(12, 'pot', 'powerpoint', 2),
(13, 'pdf', 'pdf', 2),
(14, 'gif', 'imagen', 3),
(15, 'dib', 'imagen', 3),
(16, 'jpg', 'imagen', 3),
(17, 'png', 'imagen', 3),
(18, 'tga', 'imagen', 3),
(19, 'tif', 'imagen', 3),
(20, 'tiff', 'imagen', 3),
(21, 'pcx', 'imagen', 3),
(22, 'plic', 'imagen', 3),
(23, 'emf', 'image', 3),
(24, 'ico', 'imagen', 3),
(25, 'htm', 'html', 2),
(26, 'html', 'html', 2),
(27, 'asp', '.net', 2),
(28, 'jsp', 'java', 2),
(29, 'php', 'php', 2),
(30, 'css', 'css', 2),
(31, 'js', 'js', 2),
(32, 'arj', 'compress', 2),
(33, 'zip', 'compress', 2),
(34, 'iso', 'compress', 2),
(35, 'lha', 'compress', 2),
(36, 'izh', 'compress', 2),
(37, 'rar', 'compress', 2),
(38, 'img', 'compress', 2),
(39, 'bin', 'compress', 2);

--
-- Disparadores `formato`
--
DELIMITER $$
CREATE TRIGGER `formato_insert` AFTER INSERT ON `formato` FOR EACH ROW begin
  insert into formato_log (tipo_log,id_formato,nom_formato,des_formato,id_tipo_formato) 
  values ('i',new.id_formato,new.nom_formato,new.des_formato,new.id_tipo_formato);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `formato_update` AFTER UPDATE ON `formato` FOR EACH ROW begin
  insert into formato_log (tipo_log,id_formato,nom_formato,des_formato,id_tipo_formato) 
  values ('u',new.id_formato,new.nom_formato,new.des_formato,new.id_tipo_formato);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formato_log`
--

CREATE TABLE `formato_log` (
  `id_formato_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_formato` int(11) NOT NULL,
  `nom_formato` varchar(50) NOT NULL,
  `des_formato` varchar(100) NOT NULL,
  `id_tipo_formato` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `formato_log`
--

INSERT INTO `formato_log` (`id_formato_log`, `fecha_log`, `tipo_log`, `id_formato`, `nom_formato`, `des_formato`, `id_tipo_formato`) VALUES
(1, '2019-05-24 14:23:46', 'i', 1, 'txt', 'texto plano', 2),
(2, '2019-05-24 14:23:46', 'i', 2, 'log', 'texto plano', 2),
(3, '2019-05-24 14:23:46', 'i', 3, 'dot', 'word', 2),
(4, '2019-05-24 14:23:46', 'i', 4, 'doc', 'word', 2),
(5, '2019-05-24 14:23:46', 'i', 5, 'xls', 'excel', 2),
(6, '2019-05-24 14:23:46', 'i', 6, 'xlm', 'excel', 2),
(7, '2019-05-24 14:23:46', 'i', 7, 'xlt', 'excel', 2),
(8, '2019-05-24 14:23:46', 'i', 8, 'xlv', 'excel', 2),
(9, '2019-05-24 14:23:46', 'i', 9, 'mdb', 'acces', 2),
(10, '2019-05-24 14:23:46', 'i', 10, 'ppt', 'powerpoint', 2),
(11, '2019-05-24 14:23:46', 'i', 11, 'pps', 'powerpoint', 2),
(12, '2019-05-24 14:23:46', 'i', 12, 'pot', 'powerpoint', 2),
(13, '2019-05-24 14:23:46', 'i', 13, 'pdf', 'pdf', 2),
(14, '2019-05-24 14:23:46', 'i', 14, 'gif', 'imagen', 3),
(15, '2019-05-24 14:23:46', 'i', 15, 'dib', 'imagen', 3),
(16, '2019-05-24 14:23:46', 'i', 16, 'jpg', 'imagen', 3),
(17, '2019-05-24 14:23:47', 'i', 17, 'png', 'imagen', 3),
(18, '2019-05-24 14:23:47', 'i', 18, 'tga', 'imagen', 3),
(19, '2019-05-24 14:23:47', 'i', 19, 'tif', 'imagen', 3),
(20, '2019-05-24 14:23:47', 'i', 20, 'tiff', 'imagen', 3),
(21, '2019-05-24 14:23:47', 'i', 21, 'pcx', 'imagen', 3),
(22, '2019-05-24 14:23:47', 'i', 22, 'plic', 'imagen', 3),
(23, '2019-05-24 14:23:47', 'i', 23, 'emf', 'image', 3),
(24, '2019-05-24 14:23:47', 'i', 24, 'ico', 'imagen', 3),
(25, '2019-05-24 14:23:47', 'i', 25, 'htm', 'html', 2),
(26, '2019-05-24 14:23:47', 'i', 26, 'html', 'html', 2),
(27, '2019-05-24 14:23:47', 'i', 27, 'asp', '.net', 2),
(28, '2019-05-24 14:23:47', 'i', 28, 'jsp', 'java', 2),
(29, '2019-05-24 14:23:47', 'i', 29, 'php', 'php', 2),
(30, '2019-05-24 14:23:47', 'i', 30, 'css', 'css', 2),
(31, '2019-05-24 14:23:47', 'i', 31, 'js', 'js', 2),
(32, '2019-05-24 14:23:47', 'i', 32, 'arj', 'compress', 2),
(33, '2019-05-24 14:23:47', 'i', 33, 'zip', 'compress', 2),
(34, '2019-05-24 14:23:47', 'i', 34, 'iso', 'compress', 2),
(35, '2019-05-24 14:23:47', 'i', 35, 'lha', 'compress', 2),
(36, '2019-05-24 14:23:47', 'i', 36, 'izh', 'compress', 2),
(37, '2019-05-24 14:23:47', 'i', 37, 'rar', 'compress', 2),
(38, '2019-05-24 14:23:47', 'i', 38, 'img', 'compress', 2),
(39, '2019-05-24 14:23:47', 'i', 39, 'bin', 'compress', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `funcionario`
--

CREATE TABLE `funcionario` (
  `id_funcionario` int(11) NOT NULL,
  `id_tipo_documento` int(11) NOT NULL,
  `num_documento` double NOT NULL,
  `nom_funcionario` varchar(45) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `correo` varchar(125) NOT NULL,
  `cargo` varchar(45) NOT NULL,
  `ip_sena` varchar(6) NOT NULL,
  `contraseña` varchar(300) DEFAULT NULL,
  `id_estado` int(11) NOT NULL DEFAULT '2',
  `id_area_centro` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `funcionario`
--

INSERT INTO `funcionario` (`id_funcionario`, `id_tipo_documento`, `num_documento`, `nom_funcionario`, `apellidos`, `correo`, `cargo`, `ip_sena`, `contraseña`, `id_estado`, `id_area_centro`) VALUES
(1, 1, 1019133595, 'funcionario-1', 'inst1', 'funcionario1@outlook.es', 'ins', '123451', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(2, 1, 2019133595, 'funcionario-2', 'evalt1', 'funcionario2@outlook.es', 'ep', '123452', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(3, 1, 3019133595, 'funcionario-3', 'evalp1', 'funcionario3@outlook.es', 'et', '123453', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(4, 1, 4019133595, 'funcionario-4', 'coor1', 'funcionario4@outlook.es', 'co', '123454', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(5, 1, 5019133595, 'funcionario-5', 'inst2', 'funcionario5@outlook.es', 'ins', '123455', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(6, 1, 10013153, 'Isaac', 'Novoa', 'ianovoa3@misena.edu.co', 'Instructor', '123456', NULL, 2, 1);

--
-- Disparadores `funcionario`
--
DELIMITER $$
CREATE TRIGGER `funcionario_insert` AFTER INSERT ON `funcionario` FOR EACH ROW begin
  insert into funcionario_log (tipo_log,id_funcionario,id_tipo_documento,num_documento,nom_funcionario,apellidos,correo,cargo,ip_sena,contraseña,id_estado,id_area_centro) 
  values ('i',new.id_funcionario,new.id_tipo_documento,new.num_documento,new.nom_funcionario,new.apellidos,new.correo,new.cargo,new.ip_sena,new.contraseña,new.id_estado,new.id_area_centro);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `funcionario_update` AFTER UPDATE ON `funcionario` FOR EACH ROW begin
  insert into funcionario_log (tipo_log,id_funcionario,id_tipo_documento,num_documento,nom_funcionario,apellidos,correo,cargo,ip_sena,contraseña,id_estado,id_area_centro) 
  values ('u',new.id_funcionario,new.id_tipo_documento,new.num_documento,new.nom_funcionario,new.apellidos,new.correo,new.cargo,new.ip_sena,new.contraseña,new.id_estado,new.id_area_centro);

end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `funcionario_log`
--

CREATE TABLE `funcionario_log` (
  `id_funcionario_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `id_tipo_documento` int(11) NOT NULL,
  `num_documento` double NOT NULL,
  `nom_funcionario` varchar(45) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `correo` varchar(125) NOT NULL,
  `cargo` varchar(45) NOT NULL,
  `ip_sena` varchar(6) NOT NULL,
  `contraseña` varchar(300) DEFAULT NULL,
  `id_estado` int(11) NOT NULL,
  `id_area_centro` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `funcionario_log`
--

INSERT INTO `funcionario_log` (`id_funcionario_log`, `fecha_log`, `tipo_log`, `id_funcionario`, `id_tipo_documento`, `num_documento`, `nom_funcionario`, `apellidos`, `correo`, `cargo`, `ip_sena`, `contraseña`, `id_estado`, `id_area_centro`) VALUES
(1, '2019-05-24 14:23:49', 'i', 1, 1, 1019133595, 'funcionario-1', 'inst1', 'funcionario1@outlook.es', 'ins', '123451', NULL, 2, 1),
(2, '2019-05-24 14:23:50', 'i', 2, 1, 2019133595, 'funcionario-2', 'evalt1', 'funcionario2@outlook.es', 'ep', '123452', NULL, 2, 1),
(3, '2019-05-24 14:23:50', 'i', 3, 1, 3019133595, 'funcionario-3', 'evalp1', 'funcionario3@outlook.es', 'et', '123453', NULL, 2, 1),
(4, '2019-05-24 14:23:51', 'i', 4, 1, 4019133595, 'funcionario-4', 'coor1', 'funcionario4@outlook.es', 'co', '123454', NULL, 2, 1),
(5, '2019-05-24 14:23:51', 'i', 5, 1, 5019133595, 'funcionario-5', 'inst2', 'funcionario5@outlook.es', 'ins', '123455', NULL, 2, 1),
(6, '2019-05-24 14:23:51', 'u', 1, 1, 1019133595, 'funcionario-1', 'inst1', 'funcionario1@outlook.es', 'ins', '123451', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(7, '2019-05-24 14:23:51', 'u', 3, 1, 3019133595, 'funcionario-3', 'evalp1', 'funcionario3@outlook.es', 'et', '123453', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(8, '2019-05-24 14:23:52', 'u', 2, 1, 2019133595, 'funcionario-2', 'evalt1', 'funcionario2@outlook.es', 'ep', '123452', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(9, '2019-05-24 14:23:52', 'u', 5, 1, 5019133595, 'funcionario-5', 'inst2', 'funcionario5@outlook.es', 'ins', '123455', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(10, '2019-05-24 14:23:52', 'u', 4, 1, 4019133595, 'funcionario-4', 'coor1', 'funcionario4@outlook.es', 'co', '123454', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(11, '2019-05-24 14:23:52', 'u', 1, 1, 1019133595, 'funcionario-1', 'inst1', 'funcionario1@outlook.es', 'ins', '123451', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(12, '2019-05-24 14:23:52', 'u', 3, 1, 3019133595, 'funcionario-3', 'evalp1', 'funcionario3@outlook.es', 'et', '123453', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(13, '2019-05-24 14:23:52', 'u', 2, 1, 2019133595, 'funcionario-2', 'evalt1', 'funcionario2@outlook.es', 'ep', '123452', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(14, '2019-05-24 14:23:52', 'u', 5, 1, 5019133595, 'funcionario-5', 'inst2', 'funcionario5@outlook.es', 'ins', '123455', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(15, '2019-05-24 14:23:52', 'u', 4, 1, 4019133595, 'funcionario-4', 'coor1', 'funcionario4@outlook.es', 'co', '123454', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(16, '2019-05-24 14:50:15', 'i', 6, 1, 10013153, 'Isaac', 'Novoa', 'ianovoa3@misena.edu.co', 'Instructor', '123456', NULL, 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `item_lista`
--

CREATE TABLE `item_lista` (
  `id_item_lista` int(11) NOT NULL,
  `des_item_lista` varchar(300) NOT NULL,
  `tipo_item` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `item_lista`
--

INSERT INTO `item_lista` (`id_item_lista`, `des_item_lista`, `tipo_item`) VALUES
(1, 'el documento debe tener imagenes ilustrativas', 1),
(2, 'el documento debe tener buena ortografia', 1),
(3, 'el documento debe ser coherente con la introducción', 0),
(4, 'el documento debe contener una introduccion', 0),
(5, 'prueba 2', 0),
(6, 'hola mundo', 0),
(7, 'undefined', 0),
(8, 'prueba 4', 0),
(9, 'prueba5', 0),
(10, 'prueba6', 0),
(11, 'prueba final', 0),
(12, 'rty', 0),
(13, 'tretrret', 0);

--
-- Disparadores `item_lista`
--
DELIMITER $$
CREATE TRIGGER `item_lista_insert` AFTER INSERT ON `item_lista` FOR EACH ROW begin
  insert into item_lista_log (tipo_log,id_item_lista,des_item_lista,tipo_item) 
  values ('i',new.id_item_lista,new.des_item_lista,new.tipo_item);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `item_lista_update` AFTER UPDATE ON `item_lista` FOR EACH ROW begin
  insert into item_lista_log (tipo_log,id_item_lista,des_item_lista,tipo_item) 
  values ('u',new.id_item_lista,new.des_item_lista,new.tipo_item);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `item_lista_log`
--

CREATE TABLE `item_lista_log` (
  `id_item_lista_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_item_lista` int(11) NOT NULL,
  `des_item_lista` varchar(300) NOT NULL,
  `tipo_item` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `item_lista_log`
--

INSERT INTO `item_lista_log` (`id_item_lista_log`, `fecha_log`, `tipo_log`, `id_item_lista`, `des_item_lista`, `tipo_item`) VALUES
(1, '2019-05-24 14:23:49', 'i', 1, 'el documento debe tener imagenes ilustrativas', 1),
(2, '2019-05-24 14:23:49', 'i', 2, 'el documento debe tener buena ortografia', 1),
(3, '2019-05-24 14:23:49', 'i', 3, 'el documento debe ser coherente con la introducción', 0),
(4, '2019-05-24 14:23:49', 'i', 4, 'el documento debe contener una introduccion', 0),
(5, '2019-07-15 14:02:33', 'i', 5, 'prueba 2', 0),
(6, '2019-07-15 14:02:57', 'i', 6, 'hola mundo', 0),
(7, '2019-07-15 19:44:03', 'i', 7, 'undefined', 0),
(8, '2019-07-15 19:45:01', 'i', 8, 'prueba 4', 0),
(9, '2019-07-15 19:45:58', 'i', 9, 'prueba5', 0),
(10, '2019-07-15 19:46:30', 'i', 10, 'prueba6', 0),
(11, '2019-07-16 13:30:12', 'i', 11, 'prueba final', 0),
(12, '2019-07-16 13:46:29', 'i', 12, 'rty', 0),
(13, '2019-07-16 14:19:55', 'i', 13, 'tretrret', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_chequeo`
--

CREATE TABLE `lista_chequeo` (
  `id_lista_chequeo` int(11) NOT NULL,
  `nom_lista_chequeo` varchar(100) NOT NULL,
  `des_lista_chequeo` varchar(200) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `lista_chequeo`
--

INSERT INTO `lista_chequeo` (`id_lista_chequeo`, `nom_lista_chequeo`, `des_lista_chequeo`, `fecha_creacion`, `id_funcionario`) VALUES
(1, 'prueba 2', 'hola mundo', '2019-07-15 14:02:35', 2),
(2, 'gs', 'gdsfg', '2019-07-16 13:47:50', 2),
(3, 'dsfdsf', 'dfsdfsdf', '2019-07-16 14:03:02', 2),
(4, 'dsfgdfghdgh', 'gfhghgfh', '2019-07-16 14:05:05', 2),
(5, 'sdsad', 'gfhghjfgj', '2019-07-16 14:19:32', 2);

--
-- Disparadores `lista_chequeo`
--
DELIMITER $$
CREATE TRIGGER `lista_chequeo_insert` AFTER INSERT ON `lista_chequeo` FOR EACH ROW begin
  insert into lista_chequeo_log (tipo_log,id_lista_chequeo,nom_lista_chequeo,des_lista_chequeo,fecha_creacion,id_funcionario) 
  values ('i',new.id_lista_chequeo,new.nom_lista_chequeo,new.des_lista_chequeo,new.fecha_creacion,new.id_funcionario);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `lista_chequeo_update` AFTER UPDATE ON `lista_chequeo` FOR EACH ROW begin
  insert into lista_chequeo_log (tipo_log,id_lista_chequeo,nom_lista_chequeo,des_lista_chequeo,fecha_creacion,id_funcionario) 
  values ('u',new.id_lista_chequeo,new.nom_lista_chequeo,new.des_lista_chequeo,new.fecha_creacion,new.id_funcionario);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_chequeo_log`
--

CREATE TABLE `lista_chequeo_log` (
  `id_lista_chequeo_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_lista_chequeo` int(11) NOT NULL,
  `nom_lista_chequeo` varchar(100) NOT NULL,
  `des_lista_chequeo` varchar(200) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_funcionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `lista_chequeo_log`
--

INSERT INTO `lista_chequeo_log` (`id_lista_chequeo_log`, `fecha_log`, `tipo_log`, `id_lista_chequeo`, `nom_lista_chequeo`, `des_lista_chequeo`, `fecha_creacion`, `id_funcionario`) VALUES
(1, '2019-07-15 14:02:35', 'i', 1, 'prueba 2', 'hola mundo', '2019-07-15 14:02:35', 2),
(2, '2019-07-15 14:03:03', 'u', 1, 'prueba 2', 'hola mundo', '2019-07-15 14:02:35', 2),
(3, '2019-07-16 13:47:50', 'i', 2, 'gs', 'gdsfg', '2019-07-16 13:47:50', 2),
(4, '2019-07-16 14:03:02', 'i', 3, 'dsfdsf', 'dfsdfsdf', '2019-07-16 14:03:02', 2),
(5, '2019-07-16 14:05:05', 'i', 4, 'dsfgdfghdgh', 'gfhghgfh', '2019-07-16 14:05:05', 2),
(6, '2019-07-16 14:19:32', 'i', 5, 'sdsad', 'gfhghjfgj', '2019-07-16 14:19:32', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificacion`
--

CREATE TABLE `notificacion` (
  `id_notificacion` int(11) NOT NULL,
  `fecha_envio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `conte_notificacion` varchar(600) NOT NULL,
  `ides_proceso` int(11) NOT NULL,
  `id_tipo_notificacion` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `notificacion`
--

INSERT INTO `notificacion` (`id_notificacion`, `fecha_envio`, `conte_notificacion`, `ides_proceso`, `id_tipo_notificacion`, `id_funcionario`, `estado`) VALUES
(1, '2019-07-15 14:00:53', 'nuevo producto virtual ha evaluar para el lider equipo tecnico', 1, 1, 1, 0);

--
-- Disparadores `notificacion`
--
DELIMITER $$
CREATE TRIGGER `notificacion_insert` AFTER INSERT ON `notificacion` FOR EACH ROW begin
  insert into notificacion_log (tipo_log,id_notificacion,fecha_envio,conte_notificacion,ides_proceso,id_tipo_notificacion,id_funcionario,estado) 
  values ('i',new.id_notificacion,new.fecha_envio,new.conte_notificacion,new.ides_proceso,new.id_tipo_notificacion,new.id_funcionario,new.estado);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `notificacion_update` AFTER UPDATE ON `notificacion` FOR EACH ROW begin
  insert into notificacion_log (tipo_log,id_notificacion,fecha_envio,conte_notificacion,ides_proceso,id_tipo_notificacion,id_funcionario,estado) 
  values ('u',new.id_notificacion,new.fecha_envio,new.conte_notificacion,new.ides_proceso,new.id_tipo_notificacion,new.id_funcionario,new.estado);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificacion_log`
--

CREATE TABLE `notificacion_log` (
  `id_notificacion_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_notificacion` int(11) NOT NULL,
  `fecha_envio` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `conte_notificacion` varchar(600) NOT NULL,
  `ides_proceso` int(11) NOT NULL,
  `id_tipo_notificacion` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `notificacion_log`
--

INSERT INTO `notificacion_log` (`id_notificacion_log`, `fecha_log`, `tipo_log`, `id_notificacion`, `fecha_envio`, `conte_notificacion`, `ides_proceso`, `id_tipo_notificacion`, `id_funcionario`, `estado`) VALUES
(1, '2019-07-15 14:00:53', 'i', 1, '2019-07-15 14:00:53', 'nuevo producto virtual ha evaluar para el lider equipo tecnico', 1, 1, 1, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_virtual`
--

CREATE TABLE `producto_virtual` (
  `id_p_virtual` int(11) NOT NULL,
  `nom_p_virtual` varchar(100) NOT NULL,
  `des_p_virtual` varchar(200) NOT NULL,
  `palabras_clave` varchar(100) NOT NULL,
  `id_formato` int(11) NOT NULL,
  `derechosdeautor` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `producto_virtual`
--

INSERT INTO `producto_virtual` (`id_p_virtual`, `nom_p_virtual`, `des_p_virtual`, `palabras_clave`, `id_formato`, `derechosdeautor`) VALUES
(1, 'prueba1', 'hola mundo', 'pre', 1, 'r');

--
-- Disparadores `producto_virtual`
--
DELIMITER $$
CREATE TRIGGER `producto_virtual_insert` AFTER INSERT ON `producto_virtual` FOR EACH ROW begin
  insert into producto_virtual_log (tipo_log,id_p_virtual,nom_p_virtual,des_p_virtual,palabras_clave,id_formato) 
  values ('i',new.id_p_virtual,new.nom_p_virtual,new.des_p_virtual,new.palabras_clave,new.id_formato);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `producto_virtual_update` AFTER UPDATE ON `producto_virtual` FOR EACH ROW begin
  insert into producto_virtual_log (tipo_log,id_p_virtual,nom_p_virtual,des_p_virtual,palabras_clave,id_formato) 
  values ('u',new.id_p_virtual,new.nom_p_virtual,new.des_p_virtual,new.palabras_clave,new.id_formato);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_virtual_log`
--

CREATE TABLE `producto_virtual_log` (
  `id_p_virtual_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_p_virtual` int(11) NOT NULL,
  `nom_p_virtual` varchar(100) NOT NULL,
  `des_p_virtual` varchar(200) NOT NULL,
  `palabras_clave` varchar(100) NOT NULL,
  `id_formato` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `producto_virtual_log`
--

INSERT INTO `producto_virtual_log` (`id_p_virtual_log`, `fecha_log`, `tipo_log`, `id_p_virtual`, `nom_p_virtual`, `des_p_virtual`, `palabras_clave`, `id_formato`) VALUES
(1, '2019-07-15 14:00:53', 'i', 1, 'prueba1', 'hola mundo', 'pre', 1),
(2, '2019-07-15 14:00:53', 'u', 1, 'prueba1', 'hola mundo', 'pre', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programa`
--

CREATE TABLE `programa` (
  `id_programa` int(11) NOT NULL,
  `nom_programa` varchar(100) NOT NULL,
  `nivel_formacion` varchar(45) NOT NULL,
  `id_programa_red` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `programa`
--

INSERT INTO `programa` (`id_programa`, `nom_programa`, `nivel_formacion`, `id_programa_red`) VALUES
(1, 'analisis y desarrollo de sistemas de informacion', 'tecnólogo', 0),
(2, 'mantenimiento', 'tecnólogo', 0),
(3, 'negocios internacionales', 'tecnologo', 0);

--
-- Disparadores `programa`
--
DELIMITER $$
CREATE TRIGGER `programa_insert` AFTER INSERT ON `programa` FOR EACH ROW begin
  insert into programa_log (tipo_log,id_programa,nom_programa,nivel_formacion) 
  values ('i',new.id_programa,new.nom_programa,new.nivel_formacion);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `programa_update` AFTER UPDATE ON `programa` FOR EACH ROW begin
  insert into programa_log (tipo_log,id_programa,nom_programa,nivel_formacion) 
  values ('u',new.id_programa,new.nom_programa,new.nivel_formacion);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programa_log`
--

CREATE TABLE `programa_log` (
  `id_programa_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_programa` int(11) NOT NULL,
  `nom_programa` varchar(100) NOT NULL,
  `nivel_formacion` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `programa_log`
--

INSERT INTO `programa_log` (`id_programa_log`, `fecha_log`, `tipo_log`, `id_programa`, `nom_programa`, `nivel_formacion`) VALUES
(1, '2019-05-24 14:23:42', 'i', 1, 'analisis y desarrollo de sistemas de informacion', 'tecnólogo'),
(2, '2019-05-24 14:23:43', 'i', 2, 'mantenimiento', 'tecnólogo'),
(3, '2019-05-24 14:23:43', 'i', 3, 'negocios internacionales', 'tecnologo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rankin`
--

CREATE TABLE `rankin` (
  `id_rankin` int(11) NOT NULL,
  `puesto` int(11) NOT NULL DEFAULT '0',
  `cant_visitas` int(11) NOT NULL DEFAULT '0',
  `cant_descargas` int(11) NOT NULL DEFAULT '0',
  `cant_votos` int(11) NOT NULL DEFAULT '0',
  `id_version` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `rankin`
--
DELIMITER $$
CREATE TRIGGER `rankin_insert` AFTER INSERT ON `rankin` FOR EACH ROW begin
  insert into rankin_log (tipo_log,id_rankin,puesto,cant_visitas,cant_descargas,cant_votos,id_version) 
  values ('i',new.id_rankin,new.puesto,new.cant_visitas,new.cant_descargas,new.cant_votos,new.id_version);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rankin_update` AFTER UPDATE ON `rankin` FOR EACH ROW begin
  insert into rankin_log (tipo_log,id_rankin,puesto,cant_visitas,cant_descargas,cant_votos,id_version) 
  values ('u',new.id_rankin,new.puesto,new.cant_visitas,new.cant_descargas,new.cant_votos,new.id_version);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rankin_log`
--

CREATE TABLE `rankin_log` (
  `id_rankin_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_rankin` int(11) NOT NULL,
  `puesto` int(11) NOT NULL,
  `cant_visitas` int(11) NOT NULL,
  `cant_descargas` int(11) NOT NULL,
  `cant_votos` int(11) NOT NULL,
  `id_version` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `red_deconocimiento`
--

CREATE TABLE `red_deconocimiento` (
  `id_red` int(11) NOT NULL,
  `nom_red` varchar(120) NOT NULL,
  `lider_red` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `red_deconocimiento`
--

INSERT INTO `red_deconocimiento` (`id_red`, `nom_red`, `lider_red`) VALUES
(1, 'Red de Cultura', 'Gustavo'),
(2, 'Red de Artesanías', 'Gustavo'),
(3, 'Red de Artes gráficas', ''),
(4, 'Red de Comercio y ventas', ''),
(5, 'Red de Gestión administrativa y financiera', ''),
(6, 'Red de Mecánica industrial', ''),
(7, 'Red de Energía eléctrica', ''),
(8, 'Red de Electrónica y automatización', ''),
(9, 'Red de Telecomunicaciones', ''),
(10, 'Red de Química aplicada', ''),
(11, 'Red de Informática, diseño y desarrollo de software', ''),
(12, 'Red Automotor', ''),
(13, 'Red Aeroespacial', ''),
(14, 'Red Textil, confección, diseño y moda', ''),
(15, 'Red de Cuero, calzado y marroquinería', ''),
(16, 'Red de Materiales para la industria', ''),
(17, 'Red de Minería', ''),
(18, 'Red de Hidrocarburos', ''),
(19, 'Red de Logística y gestión de la producción', ''),
(20, 'Red de Construcción', ''),
(21, 'Red de Infraestructura', ''),
(22, 'Red Agrícola', ''),
(23, 'Red Pecuaria', ''),
(24, 'Red Acuícola y de pesca', ''),
(25, 'Red Ambiental', ''),
(26, 'Red de Biotecnología', ''),
(27, 'Red de Salud', ''),
(28, 'Red de Hotelería y turismo', ''),
(29, 'Red de Actividad física, recreación y deporte', ''),
(30, 'Red de Transporte', ''),
(31, 'Red de Servicios personales', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `red_programa`
--

CREATE TABLE `red_programa` (
  `id_programa` int(11) NOT NULL,
  `nom_programa` varchar(100) NOT NULL,
  `nivel_formacion` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nom_rol` varchar(45) NOT NULL,
  `des_rol` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nom_rol`, `des_rol`) VALUES
(1, 'instructor', 'suprincipal participacion es el envio de los oa'),
(2, 'lider equipo tecnico', 'evaluara los oa tecnicamente'),
(3, 'lider equipo pedagogico', 'evaluara los oa pedagogicamente'),
(4, 'coordinador formacion profecional', 'controla la publicacion de las oas');

--
-- Disparadores `rol`
--
DELIMITER $$
CREATE TRIGGER `rol_insert` AFTER INSERT ON `rol` FOR EACH ROW begin
  insert into rol_log (tipo_log,id_rol,nom_rol,des_rol) 
  values ('i',new.id_rol,new.nom_rol,new.des_rol);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rol_update` AFTER UPDATE ON `rol` FOR EACH ROW begin
  insert into rol_log (tipo_log,id_rol,nom_rol,des_rol) 
  values ('u',new.id_rol,new.nom_rol,new.des_rol);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_funcionario`
--

CREATE TABLE `rol_funcionario` (
  `id_rol_funcionario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `vigencia` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol_funcionario`
--

INSERT INTO `rol_funcionario` (`id_rol_funcionario`, `id_rol`, `id_funcionario`, `vigencia`) VALUES
(1, 1, 1, 1),
(2, 2, 2, 1),
(3, 3, 3, 1),
(4, 4, 4, 1),
(5, 1, 5, 1),
(6, 1, 6, 1);

--
-- Disparadores `rol_funcionario`
--
DELIMITER $$
CREATE TRIGGER `rol_funcionario_bi` BEFORE INSERT ON `rol_funcionario` FOR EACH ROW begin
	set @count = 0;
    set @idcentro = 0;
    select id_centro into @idcentro
    from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro
    where id_funcionario = new.id_funcionario;
    
    
    if(new.id_rol != 1)then
		select count(*) into @count
		from funcionario v1 inner join area_centro v2 on v1.id_area_centro = v2.id_area_centro inner join
			 rol_funcionario v3 on v1.id_funcionario = v3.id_funcionario
		where id_centro = @idcentro and id_rol = new.id_rol and v3.vigencia = 1;
    end if;
    
    if(@count = 0)then
		set @count = 0;
        else signal sqlstate "45000" set message_text = "lo siento, ya existe un funcionario con ese rol y centro de formacion";
    end if;
    
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rol_funcionario_insert` AFTER INSERT ON `rol_funcionario` FOR EACH ROW begin
  insert into rol_funcionario_log (tipo_log,id_rol_funcionario,id_rol,id_funcionario,vigencia) 
  values ('i',new.id_rol_funcionario,new.id_rol,new.id_funcionario,new.vigencia);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rol_funcionario_update` AFTER UPDATE ON `rol_funcionario` FOR EACH ROW begin
  insert into rol_funcionario_log (tipo_log,id_rol_funcionario,id_rol,id_funcionario,vigencia)
  values ('u',new.id_rol_funcionario,new.id_rol,new.id_funcionario,new.vigencia);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_funcionario_log`
--

CREATE TABLE `rol_funcionario_log` (
  `id_rol_funcionario_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_rol_funcionario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `vigencia` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol_funcionario_log`
--

INSERT INTO `rol_funcionario_log` (`id_rol_funcionario_log`, `fecha_log`, `tipo_log`, `id_rol_funcionario`, `id_rol`, `id_funcionario`, `vigencia`) VALUES
(1, '2019-05-24 14:23:49', 'i', 1, 1, 1, 1),
(2, '2019-05-24 14:23:50', 'i', 2, 2, 2, 1),
(3, '2019-05-24 14:23:50', 'i', 3, 3, 3, 1),
(4, '2019-05-24 14:23:51', 'i', 4, 4, 4, 1),
(5, '2019-05-24 14:23:51', 'i', 5, 1, 5, 1),
(6, '2019-05-24 14:50:15', 'i', 6, 1, 6, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_log`
--

CREATE TABLE `rol_log` (
  `id_rol_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `nom_rol` varchar(45) NOT NULL,
  `des_rol` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol_log`
--

INSERT INTO `rol_log` (`id_rol_log`, `fecha_log`, `tipo_log`, `id_rol`, `nom_rol`, `des_rol`) VALUES
(1, '2019-05-24 14:23:48', 'i', 1, 'instructor', 'suprincipal participacion es el envio de los oa'),
(2, '2019-05-24 14:23:48', 'i', 2, 'lider equipo tecnico', 'evaluara los oa tecnicamente'),
(3, '2019-05-24 14:23:48', 'i', 3, 'lider equipo pedagogico', 'evaluara los oa pedagogicamente'),
(4, '2019-05-24 14:23:48', 'i', 4, 'coordinador formacion profecional', 'controla la publicacion de las oas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tema`
--

CREATE TABLE `tema` (
  `id_tema` int(11) NOT NULL,
  `nom_tema` varchar(45) NOT NULL,
  `des_tema` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tema`
--

INSERT INTO `tema` (`id_tema`, `nom_tema`, `des_tema`) VALUES
(1, 'fundamentos de programación', 'descripcion tema 1'),
(2, 'programacion orientada ha objetos', 'descripcion tema 2'),
(3, 'negociacion', 'descripcion tema 3'),
(4, 'ingles', 'descripcion tema 4'),
(5, 'datos lmm', 'crear');

--
-- Disparadores `tema`
--
DELIMITER $$
CREATE TRIGGER `tema_insert` AFTER INSERT ON `tema` FOR EACH ROW begin
  insert into tema_log (tipo_log,id_tema,nom_tema,des_tema) 
  values ('i',new.id_tema,new.nom_tema,new.des_tema);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tema_update` AFTER UPDATE ON `tema` FOR EACH ROW begin
  insert into tema_log (tipo_log,id_tema,nom_tema,des_tema) 
  values ('u',new.id_tema,new.nom_tema,new.des_tema);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tema_log`
--

CREATE TABLE `tema_log` (
  `id_tema_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_tema` int(11) NOT NULL,
  `nom_tema` varchar(45) NOT NULL,
  `des_tema` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tema_log`
--

INSERT INTO `tema_log` (`id_tema_log`, `fecha_log`, `tipo_log`, `id_tema`, `nom_tema`, `des_tema`) VALUES
(1, '2019-05-24 14:23:44', 'i', 1, 'fundamentos de programación', 'descripcion tema 1'),
(2, '2019-05-24 14:23:44', 'i', 2, 'programacion orientada ha objetos', 'descripcion tema 2'),
(3, '2019-05-24 14:23:44', 'i', 3, 'negociacion', 'descripcion tema 3'),
(4, '2019-05-24 14:23:44', 'i', 4, 'ingles', 'descripcion tema 4'),
(5, '2019-07-03 20:57:28', 'i', 5, 'datos lmm', 'crear');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_documento`
--

CREATE TABLE `tipo_documento` (
  `id_tipo_documento` int(11) NOT NULL,
  `nom_tipo_documento` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_documento`
--

INSERT INTO `tipo_documento` (`id_tipo_documento`, `nom_tipo_documento`) VALUES
(1, 'cedula de ciudadania'),
(2, 'cedula extrangera'),
(3, 'registro civil');

--
-- Disparadores `tipo_documento`
--
DELIMITER $$
CREATE TRIGGER `tipo_documento_insert` AFTER INSERT ON `tipo_documento` FOR EACH ROW begin
  insert into tipo_documento_log (tipo_log,id_tipo_documento,nom_tipo_documento) 
  values ('i',new.id_tipo_documento,new.nom_tipo_documento);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tipo_documento_update` AFTER UPDATE ON `tipo_documento` FOR EACH ROW begin
  insert into tipo_documento_log (tipo_log,id_tipo_documento,nom_tipo_documento) 
  values ('u',new.id_tipo_documento,new.nom_tipo_documento);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_documento_log`
--

CREATE TABLE `tipo_documento_log` (
  `id_tipo_documento_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_tipo_documento` int(11) NOT NULL,
  `nom_tipo_documento` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_documento_log`
--

INSERT INTO `tipo_documento_log` (`id_tipo_documento_log`, `fecha_log`, `tipo_log`, `id_tipo_documento`, `nom_tipo_documento`) VALUES
(1, '2019-05-24 14:23:48', 'i', 1, 'cedula de ciudadania'),
(2, '2019-05-24 14:23:49', 'i', 2, 'cedula extrangera'),
(3, '2019-05-24 14:23:49', 'i', 3, 'registro civil');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_estado`
--

CREATE TABLE `tipo_estado` (
  `id_tipo_estado` int(11) NOT NULL,
  `nom_tipo_estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_estado`
--

INSERT INTO `tipo_estado` (`id_tipo_estado`, `nom_tipo_estado`) VALUES
(1, 'funcionario'),
(2, 'version');

--
-- Disparadores `tipo_estado`
--
DELIMITER $$
CREATE TRIGGER `tipoestado_insert` AFTER INSERT ON `tipo_estado` FOR EACH ROW begin
  insert into tipo_estado_log (tipo_log,id_tipo_estado,nom_tipo_estado) 
  values ('i',new.id_tipo_estado,new.nom_tipo_estado);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tipoestado_update` AFTER UPDATE ON `tipo_estado` FOR EACH ROW begin
  insert into tipo_estado_log (tipo_log,id_tipo_estado,nom_tipo_estado) 
  values ('u',new.id_tipo_estado,new.nom_tipo_estado);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_estado_log`
--

CREATE TABLE `tipo_estado_log` (
  `id_tipo_estado_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_tipo_estado` int(11) NOT NULL,
  `nom_tipo_estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_estado_log`
--

INSERT INTO `tipo_estado_log` (`id_tipo_estado_log`, `fecha_log`, `tipo_log`, `id_tipo_estado`, `nom_tipo_estado`) VALUES
(1, '2019-05-24 14:23:47', 'i', 1, 'funcionario'),
(2, '2019-05-24 14:23:48', 'i', 2, 'version');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_formato`
--

CREATE TABLE `tipo_formato` (
  `id_tipo_formato` int(11) NOT NULL,
  `nom_tipo_formato` varchar(60) NOT NULL,
  `urlimgtipoformato` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_formato`
--

INSERT INTO `tipo_formato` (`id_tipo_formato`, `nom_tipo_formato`, `urlimgtipoformato`) VALUES
(1, 'video', NULL),
(2, 'documento', NULL),
(3, 'imagen', NULL),
(4, 'audios', 'descarga.png');

--
-- Disparadores `tipo_formato`
--
DELIMITER $$
CREATE TRIGGER `tipo_formato_insert` AFTER INSERT ON `tipo_formato` FOR EACH ROW begin
  insert into tipo_formato_log (tipo_log,id_tipo_formato,nom_tipo_formato) 
  values ('i',new.id_tipo_formato,new.nom_tipo_formato);
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tipo_formato_update` AFTER UPDATE ON `tipo_formato` FOR EACH ROW begin
  insert into tipo_formato_log (tipo_log,id_tipo_formato,nom_tipo_formato) 
  values ('u',new.id_tipo_formato,new.nom_tipo_formato);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_formato_log`
--

CREATE TABLE `tipo_formato_log` (
  `id_tipo_formato_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_tipo_formato` int(11) NOT NULL,
  `nom_tipo_formato` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_formato_log`
--

INSERT INTO `tipo_formato_log` (`id_tipo_formato_log`, `fecha_log`, `tipo_log`, `id_tipo_formato`, `nom_tipo_formato`) VALUES
(1, '2019-05-24 14:23:45', 'i', 1, 'video'),
(2, '2019-05-24 14:23:45', 'i', 2, 'documento'),
(3, '2019-05-24 14:23:46', 'i', 3, 'imagen'),
(4, '2019-07-12 13:41:47', 'i', 4, 'audios');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_notificacion`
--

CREATE TABLE `tipo_notificacion` (
  `id_tipo_notificacion` int(11) NOT NULL,
  `nom_tipo_notif` varchar(70) NOT NULL,
  `des_tipo_notif` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_notificacion`
--

INSERT INTO `tipo_notificacion` (`id_tipo_notificacion`, `nom_tipo_notif`, `des_tipo_notif`) VALUES
(1, 'evaluativa', 'solo podran recibirlas los equipos evaluadores'),
(2, 'retroalimentativa', 'solo podran recibirlas los intructores'),
(3, 'publicativa', 'lo recibiran tanto los instructores como el coordinador');

--
-- Disparadores `tipo_notificacion`
--
DELIMITER $$
CREATE TRIGGER `tipo_notificacion_insert` AFTER INSERT ON `tipo_notificacion` FOR EACH ROW begin
  insert into tipo_notificacion_log (tipo_log,id_tipo_notificacion,nom_tipo_notif,des_tipo_notif) 
  values ('i',new.id_tipo_notificacion,new.nom_tipo_notif,new.des_tipo_notif);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tipo_notificacion_update` AFTER UPDATE ON `tipo_notificacion` FOR EACH ROW begin
  insert into tipo_notificacion_log (tipo_log,id_tipo_notificacion,nom_tipo_notif,des_tipo_notif) 
  values ('u',new.id_tipo_notificacion,new.nom_tipo_notif,new.des_tipo_notif);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_notificacion_log`
--

CREATE TABLE `tipo_notificacion_log` (
  `id_tipo_notificacion_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_tipo_notificacion` int(11) NOT NULL,
  `nom_tipo_notif` varchar(70) NOT NULL,
  `des_tipo_notif` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_notificacion_log`
--

INSERT INTO `tipo_notificacion_log` (`id_tipo_notificacion_log`, `fecha_log`, `tipo_log`, `id_tipo_notificacion`, `nom_tipo_notif`, `des_tipo_notif`) VALUES
(1, '2019-05-24 14:23:49', 'i', 1, 'evaluativa', 'solo podran recibirlas los equipos evaluadores'),
(2, '2019-05-24 14:23:49', 'i', 2, 'retroalimentativa', 'solo podran recibirlas los intructores'),
(3, '2019-05-24 14:23:49', 'i', 3, 'publicativa', 'lo recibiran tanto los instructores como el coordinador');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `toquen`
--

CREATE TABLE `toquen` (
  `numero_toquen` varchar(20) NOT NULL,
  `funcionario` int(11) NOT NULL,
  `fechavigencia` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `toquen`
--

INSERT INTO `toquen` (`numero_toquen`, `funcionario`, `fechavigencia`) VALUES
('9255610013153', 6, '2019-05-31 23:00:00'),
('cont1', 1, '2019-05-31 23:00:00'),
('cont2', 2, '2019-05-31 23:00:00'),
('cont3', 3, '2019-05-31 23:00:00'),
('cont4', 4, '2019-05-31 23:00:00'),
('cont5', 5, '2019-05-31 23:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `version`
--

CREATE TABLE `version` (
  `id_version` int(11) NOT NULL,
  `fecha_envio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_publicacion` timestamp NOT NULL DEFAULT '2016-01-01 05:00:00',
  `num_version` float DEFAULT '1',
  `fecha_vigencia` timestamp NOT NULL DEFAULT '2016-01-01 05:00:00',
  `url_version` varchar(500) DEFAULT NULL,
  `url_img` varchar(500) DEFAULT NULL,
  `inst_instalacion` varchar(800) DEFAULT NULL,
  `reqst_instalacion` varchar(500) DEFAULT NULL,
  `id_p_virtual` int(11) NOT NULL,
  `id_estado` int(11) NOT NULL DEFAULT '3'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `version`
--

INSERT INTO `version` (`id_version`, `fecha_envio`, `fecha_publicacion`, `num_version`, `fecha_vigencia`, `url_version`, `url_img`, `inst_instalacion`, `reqst_instalacion`, `id_p_virtual`, `id_estado`) VALUES
(1, '2019-07-15 14:00:53', '2016-01-01 05:00:00', 1, '2016-01-01 05:00:00', '1-001-10-001.txt', '0', 'descargar', 'ver word', 1, 3);

--
-- Disparadores `version`
--
DELIMITER $$
CREATE TRIGGER `version_insert` AFTER INSERT ON `version` FOR EACH ROW begin
  insert into version_log (tipo_log,id_version,fecha_envio,fecha_publicacion,num_version,fecha_vigencia,url_version,url_img,inst_instalacion,reqst_instalacion,id_p_virtual,id_estado) 
  values ('i',new.id_version,new.fecha_envio,new.fecha_publicacion,new.num_version,new.fecha_vigencia,new.url_version,new.url_img,new.inst_instalacion,new.reqst_instalacion,new.id_p_virtual,new.id_estado);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `version_update` AFTER UPDATE ON `version` FOR EACH ROW begin
  insert into version_log (tipo_log,id_version,fecha_envio,fecha_publicacion,num_version,fecha_vigencia,url_version,url_img,inst_instalacion,reqst_instalacion,id_p_virtual,id_estado) 
  values ('u',new.id_version,new.fecha_envio,new.fecha_publicacion,new.num_version,new.fecha_vigencia,new.url_version,new.url_img,new.inst_instalacion,new.reqst_instalacion,new.id_p_virtual,new.id_estado);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `version_log`
--

CREATE TABLE `version_log` (
  `id_version_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_version` int(11) NOT NULL,
  `fecha_envio` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fecha_publicacion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `num_version` float NOT NULL,
  `fecha_vigencia` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `url_version` varchar(500) DEFAULT NULL,
  `url_img` varchar(500) DEFAULT NULL,
  `inst_instalacion` varchar(800) DEFAULT NULL,
  `reqst_instalacion` varchar(500) DEFAULT NULL,
  `id_p_virtual` int(11) NOT NULL,
  `id_estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `version_log`
--

INSERT INTO `version_log` (`id_version_log`, `fecha_log`, `tipo_log`, `id_version`, `fecha_envio`, `fecha_publicacion`, `num_version`, `fecha_vigencia`, `url_version`, `url_img`, `inst_instalacion`, `reqst_instalacion`, `id_p_virtual`, `id_estado`) VALUES
(1, '2019-07-15 14:00:53', 'i', 1, '2019-07-15 14:00:53', '2016-01-01 05:00:00', 1, '2016-01-01 05:00:00', 'prueba 1.txt', '0', 'descargar', 'ver word', 1, 3),
(2, '2019-07-15 14:00:53', 'u', 1, '2019-07-15 14:00:53', '2016-01-01 05:00:00', 1, '2016-01-01 05:00:00', '1-001-10-001.txt', '0', 'descargar', 'ver word', 1, 3);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistapuesto`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistapuesto` (
`id_rankin` int(11)
,`val_puesto` varchar(3)
,`puesto` int(11)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `voto`
--

CREATE TABLE `voto` (
  `id_voto` int(11) NOT NULL,
  `num_voto` int(1) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `id_rankin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `voto`
--
DELIMITER $$
CREATE TRIGGER `voto_insert` AFTER INSERT ON `voto` FOR EACH ROW begin
  insert into voto_log (tipo_log,id_voto,num_voto,id_funcionario,id_rankin) 
  values ('i',new.id_voto,new.num_voto,new.id_funcionario,new.id_rankin);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `voto_update` AFTER UPDATE ON `voto` FOR EACH ROW begin
  insert into voto_log (tipo_log,id_voto,num_voto,id_funcionario,id_rankin) 
  values ('u',new.id_voto,new.num_voto,new.id_funcionario,new.id_rankin);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `voto_log`
--

CREATE TABLE `voto_log` (
  `id_voto_log` int(11) NOT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_log` char(1) NOT NULL,
  `id_voto` int(11) NOT NULL,
  `num_voto` int(1) NOT NULL,
  `id_funcionario` int(11) NOT NULL,
  `id_rankin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura para la vista `01_v_detalles_lista`
--
DROP TABLE IF EXISTS `01_v_detalles_lista`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `01_v_detalles_lista`  AS  (select `dl`.`id_lista_chequeo` AS `id_lista_chequeo`,`lc`.`nom_lista_chequeo` AS `nom_lista_chequeo`,`lc`.`des_lista_chequeo` AS `des_lista_chequeo`,`lc`.`fecha_creacion` AS `fecha_creacion`,`lc`.`id_funcionario` AS `id_funcionario`,`dl`.`id_item_lista` AS `id_item_lista`,`il`.`des_item_lista` AS `des_item_lista`,`il`.`tipo_item` AS `tipo_item`,`dl`.`id_detalles_lista` AS `id_detalles_lista` from ((`lista_chequeo` `lc` join `detalles_lista` `dl` on((`lc`.`id_lista_chequeo` = `dl`.`id_lista_chequeo`))) join `item_lista` `il` on((`dl`.`id_item_lista` = `il`.`id_item_lista`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `02_v_area_centro`
--
DROP TABLE IF EXISTS `02_v_area_centro`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `02_v_area_centro`  AS  (select `ac`.`id_area_centro` AS `id_area_centro`,`ac`.`id_centro` AS `id_centro`,`ce`.`num_centro` AS `num_centro`,`ce`.`nom_centro` AS `nom_centro`,`ce`.`direccion` AS `direccion`,`ce`.`id_ciudad` AS `id_ciudad`,`ci`.`nom_ciudad` AS `nom_ciudad`,`ac`.`id_area` AS `id_area`,`ar`.`nom_area` AS `nom_area`,`ar`.`lider_area` AS `lider_area` from (((`centro` `ce` join `area_centro` `ac` on((`ce`.`id_centro` = `ac`.`id_centro`))) join `area` `ar` on((`ac`.`id_area` = `ar`.`id_area`))) join `ciudad` `ci` on((`ce`.`id_ciudad` = `ci`.`id_ciudad`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `03_v_detalles_area`
--
DROP TABLE IF EXISTS `03_v_detalles_area`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `03_v_detalles_area`  AS  (select `da`.`id_detalles_area` AS `id_detalles_area`,`da`.`id_area` AS `id_area`,`ar`.`nom_area` AS `nom_area`,`ar`.`lider_area` AS `lider_area`,`da`.`id_programa` AS `id_programa`,`pr`.`nom_programa` AS `nom_programa`,`pr`.`nivel_formacion` AS `nivel_formacion` from ((`area` `ar` join `detalles_area` `da` on((`ar`.`id_area` = `da`.`id_area`))) join `programa` `pr` on((`da`.`id_programa` = `pr`.`id_programa`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `04_v_detalles_programa`
--
DROP TABLE IF EXISTS `04_v_detalles_programa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `04_v_detalles_programa`  AS  (select `dp`.`id_detalles_programa` AS `id_detalles_programa`,`dp`.`id_programa` AS `id_programa`,`pr`.`nom_programa` AS `nom_programa`,`pr`.`nivel_formacion` AS `nivel_formacion`,`dp`.`id_tema` AS `id_tema`,`te`.`nom_tema` AS `nom_tema`,`te`.`des_tema` AS `des_tema` from ((`programa` `pr` join `detalles_programa` `dp` on((`pr`.`id_programa` = `dp`.`id_programa`))) join `tema` `te` on((`dp`.`id_tema` = `te`.`id_tema`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `05_v_detalles_categoria`
--
DROP TABLE IF EXISTS `05_v_detalles_categoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `05_v_detalles_categoria`  AS  (select distinct `dc`.`id_categoria` AS `id_categoria`,`ca`.`nom_categoria` AS `nom_categoria`,`ca`.`des_categoria` AS `des_categoria`,`ca`.`fecha_creacion` AS `fecha_creacion`,`ca`.`id_funcionario` AS `id_funcionario`,`dc`.`id_detalles_categoria` AS `id_detalles_categoria`,`dc`.`id_tema` AS `id_tema`,`te`.`nom_tema` AS `nom_tema`,`te`.`des_tema` AS `des_tema` from ((`categoria` `ca` join `detalles_categoria` `dc` on((`ca`.`id_categoria` = `dc`.`id_categoria`))) join `tema` `te` on((`dc`.`id_tema` = `te`.`id_tema`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `06_v_detalles_tema`
--
DROP TABLE IF EXISTS `06_v_detalles_tema`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `06_v_detalles_tema`  AS  (select `dt`.`id_p_virtual` AS `id_p_virtual`,`pv`.`nom_p_virtual` AS `nom_p_virtual`,`pv`.`des_p_virtual` AS `des_p_virtual`,`pv`.`palabras_clave` AS `palabras_clave`,`pv`.`id_formato` AS `id_formato`,`fo`.`nom_formato` AS `nom_formato`,`fo`.`des_formato` AS `des_formato`,`dt`.`id_detalles_tema` AS `id_detalles_tema`,`dt`.`id_tema` AS `id_tema`,`te`.`nom_tema` AS `nom_tema`,`te`.`des_tema` AS `des_tema`,`dt`.`tipo_tema` AS `tipo_tema` from (((`formato` `fo` join `producto_virtual` `pv` on((`fo`.`id_formato` = `pv`.`id_formato`))) join `detalles_tema` `dt` on((`pv`.`id_p_virtual` = `dt`.`id_p_virtual`))) join `tema` `te` on((`dt`.`id_tema` = `te`.`id_tema`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `07_v_version`
--
DROP TABLE IF EXISTS `07_v_version`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `07_v_version`  AS  (select `v`.`id_p_virtual` AS `id_p_virtual`,`pv`.`nom_p_virtual` AS `nom_p_virtual`,`pv`.`des_p_virtual` AS `des_p_virtual`,`pv`.`palabras_clave` AS `palabras_clave`,`pv`.`id_formato` AS `id_formato`,`v`.`id_version` AS `id_version`,`v`.`fecha_envio` AS `fecha_envio`,`v`.`fecha_publicacion` AS `fecha_publicacion`,`v`.`num_version` AS `num_version`,`v`.`fecha_vigencia` AS `fecha_vigencia`,`v`.`url_version` AS `url_version`,`v`.`url_img` AS `url_img`,`v`.`inst_instalacion` AS `inst_instalacion`,`v`.`reqst_instalacion` AS `reqst_instalacion`,`v`.`id_estado` AS `id_estado`,`e`.`nom_estado` AS `nom_estado`,`e`.`id_tipo_estado` AS `id_tipo_estado` from ((`producto_virtual` `pv` join `version` `v` on((`pv`.`id_p_virtual` = `v`.`id_p_virtual`))) join `estado` `e` on((`e`.`id_estado` = `v`.`id_estado`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `08_v_funcionario`
--
DROP TABLE IF EXISTS `08_v_funcionario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `08_v_funcionario`  AS  (select `rf`.`id_rol_funcionario` AS `id_rol_funcionario`,`rf`.`id_rol` AS `id_rol`,`ro`.`nom_rol` AS `nom_rol`,`ro`.`des_rol` AS `des_rol`,`rf`.`id_funcionario` AS `id_funcionario`,`td`.`id_tipo_documento` AS `id_tipo_documento`,`td`.`nom_tipo_documento` AS `nom_tipo_documento`,`fu`.`num_documento` AS `num_documento`,`fu`.`nom_funcionario` AS `nom_funcionario`,`fu`.`apellidos` AS `apellidos`,`fu`.`correo` AS `correo`,`fu`.`cargo` AS `cargo`,`fu`.`ip_sena` AS `ip_sena`,`fu`.`contraseña` AS `contraseña`,`fu`.`id_estado` AS `id_estado`,`fu`.`id_area_centro` AS `id_area_centro`,`ac`.`id_centro` AS `id_centro` from ((((`rol` `ro` join `rol_funcionario` `rf` on((`ro`.`id_rol` = `rf`.`id_rol`))) join `funcionario` `fu` on(((`rf`.`id_funcionario` = `fu`.`id_funcionario`) and (`rf`.`vigencia` = 1)))) join `tipo_documento` `td` on((`td`.`id_tipo_documento` = `fu`.`id_tipo_documento`))) join `area_centro` `ac` on((`fu`.`id_area_centro` = `ac`.`id_area_centro`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `09_v_autor`
--
DROP TABLE IF EXISTS `09_v_autor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `09_v_autor`  AS  (select `au`.`id_autor` AS `id_autor`,`vver`.`id_p_virtual` AS `id_p_virtual`,`vver`.`nom_p_virtual` AS `nom_p_virtual`,`vver`.`des_p_virtual` AS `des_p_virtual`,`vver`.`palabras_clave` AS `palabras_clave`,`vver`.`id_formato` AS `id_formato`,`vver`.`id_version` AS `id_version`,`vver`.`fecha_envio` AS `fecha_envio`,`vver`.`fecha_publicacion` AS `fecha_publicacion`,`vver`.`num_version` AS `num_version`,`vver`.`fecha_vigencia` AS `fecha_vigencia`,`vver`.`url_version` AS `url_version`,`vver`.`url_img` AS `url_img`,`vver`.`inst_instalacion` AS `inst_instalacion`,`vver`.`reqst_instalacion` AS `reqst_instalacion`,`vver`.`id_estado` AS `id_estado`,`vver`.`nom_estado` AS `nom_estado`,`vver`.`id_tipo_estado` AS `id_tipo_estado`,`vfu`.`id_rol_funcionario` AS `id_rol_funcionario`,`vfu`.`id_rol` AS `id_rol`,`vfu`.`nom_rol` AS `nom_rol`,`vfu`.`des_rol` AS `des_rol`,`vfu`.`id_funcionario` AS `id_funcionario`,`vfu`.`id_tipo_documento` AS `id_tipo_documento`,`vfu`.`nom_tipo_documento` AS `nom_tipo_documento`,`vfu`.`num_documento` AS `num_documento`,`vfu`.`nom_funcionario` AS `nom_funcionario`,`vfu`.`apellidos` AS `apellidos`,`vfu`.`correo` AS `correo`,`vfu`.`cargo` AS `cargo`,`vfu`.`ip_sena` AS `ip_sena`,`vfu`.`contraseña` AS `contraseña`,`vfu`.`id_estado` AS `id_estadofun`,`vfu`.`id_area_centro` AS `id_area_centro` from ((`autor` `au` join `08_v_funcionario` `vfu` on((`au`.`id_funcionario` = `vfu`.`id_funcionario`))) join `07_v_version` `vver` on((`au`.`id_version` = `vver`.`id_version`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `10_habilitar_p`
--
DROP TABLE IF EXISTS `10_habilitar_p`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `10_habilitar_p`  AS  (select distinct `v2`.`id_version` AS `id_version`,`v1`.`nom_p_virtual` AS `nom_p_virtual`,`v2`.`num_version` AS `num_version`,`v2`.`fecha_vigencia` AS `fecha_vigencia`,`v5`.`id_centro` AS `id_centro` from ((((`producto_virtual` `v1` join `version` `v2` on((`v1`.`id_p_virtual` = `v2`.`id_p_virtual`))) join `autor` `v3` on((`v2`.`id_version` = `v3`.`id_version`))) join `funcionario` `v4` on((`v3`.`id_funcionario` = `v4`.`id_funcionario`))) join `area_centro` `v5` on((`v4`.`id_area_centro` = `v5`.`id_area_centro`))) where (`v2`.`id_estado` = 5)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `11_v_area`
--
DROP TABLE IF EXISTS `11_v_area`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `11_v_area`  AS  (select `v1`.`id_area` AS `id_area`,`v2`.`nom_area` AS `nom_area`,`v1`.`id_centro` AS `id_centro`,`v3`.`nom_centro` AS `nom_centro` from ((`area_centro` `v1` join `area` `v2` on((`v1`.`id_area` = `v2`.`id_area`))) join `centro` `v3` on((`v1`.`id_centro` = `v3`.`id_centro`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `12_inabilitar_funcionario`
--
DROP TABLE IF EXISTS `12_inabilitar_funcionario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `12_inabilitar_funcionario`  AS  (select `v1`.`id_funcionario` AS `id_funcionario`,concat(`v1`.`nom_funcionario`,' ',`v1`.`apellidos`) AS `nombrecompleto`,`v1`.`ip_sena` AS `ip_sena`,`v1`.`cargo` AS `cargo`,`v4`.`nom_rol` AS `nom_rol`,`v2`.`nom_estado` AS `nom_estado`,`v6`.`nom_area` AS `nom_area`,`v7`.`nom_centro` AS `nom_centro` from ((((((`funcionario` `v1` join `estado` `v2` on((`v1`.`id_estado` = `v2`.`id_estado`))) join `rol_funcionario` `v3` on(((`v1`.`id_funcionario` = `v3`.`id_funcionario`) and (`v3`.`vigencia` = 1)))) join `rol` `v4` on((`v3`.`id_rol` = `v4`.`id_rol`))) join `area_centro` `v5` on((`v1`.`id_area_centro` = `v5`.`id_area_centro`))) join `area` `v6` on((`v5`.`id_area` = `v6`.`id_area`))) join `centro` `v7` on((`v5`.`id_centro` = `v7`.`id_centro`))) where (`v1`.`id_estado` = 1)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `13_v_listas_chequeo`
--
DROP TABLE IF EXISTS `13_v_listas_chequeo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `13_v_listas_chequeo`  AS  (select `v1`.`id_lista_chequeo` AS `id_lista_chequeo`,`v1`.`nom_lista_chequeo` AS `nom_lista_chequeo`,`v1`.`des_lista_chequeo` AS `des_lista_chequeo`,`v1`.`fecha_creacion` AS `fecha_creacion`,`v2`.`id_funcionario` AS `id_funcionario`,`v3`.`id_rol` AS `id_rol` from ((`lista_chequeo` `v1` join `funcionario` `v2` on((`v1`.`id_funcionario` = `v2`.`id_funcionario`))) join `rol_funcionario` `v3` on((`v2`.`id_funcionario` = `v3`.`id_funcionario`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `14_v_titulos`
--
DROP TABLE IF EXISTS `14_v_titulos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `14_v_titulos`  AS  (select distinct `v1`.`id_p_virtual` AS `id_p_virtual`,`v1`.`nom_p_virtual` AS `nom_p_virtual` from (`producto_virtual` `v1` join `version` `v2` on((`v1`.`id_p_virtual` = `v2`.`id_p_virtual`))) where (`v2`.`id_estado` = 6)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `15_v_subir_autores`
--
DROP TABLE IF EXISTS `15_v_subir_autores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `15_v_subir_autores`  AS  (select `v1`.`id_funcionario` AS `id_funcionario`,`v1`.`nom_funcionario` AS `nom_funcionario`,`v3`.`id_centro` AS `id_centro` from ((`funcionario` `v1` join `rol_funcionario` `v2` on(((`v1`.`id_funcionario` = `v2`.`id_funcionario`) and (`v2`.`vigencia` = 1)))) join `area_centro` `v3` on((`v1`.`id_area_centro` = `v3`.`id_area_centro`))) where (`v2`.`id_rol` = 1)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `16_v_items_lista`
--
DROP TABLE IF EXISTS `16_v_items_lista`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `16_v_items_lista`  AS  (select `v3`.`id_item_lista` AS `id_item_lista`,`v3`.`des_item_lista` AS `des_item_lista`,`v3`.`tipo_item` AS `tipo_item`,`v1`.`id_lista_chequeo` AS `id_lista_chequeo`,`v1`.`id_detalles_lista` AS `id_detalles_lista` from ((`detalles_lista` `v1` join `lista_chequeo` `v2` on((`v1`.`id_lista_chequeo` = `v2`.`id_lista_chequeo`))) join `item_lista` `v3` on((`v1`.`id_item_lista` = `v3`.`id_item_lista`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `17_v_productosevaluador`
--
DROP TABLE IF EXISTS `17_v_productosevaluador`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `17_v_productosevaluador`  AS  (select `v1`.`id_p_virtual` AS `id_p_virtual`,`v1`.`nom_p_virtual` AS `nom_p_virtual`,`v2`.`id_version` AS `id_version`,`v2`.`num_version` AS `num_version`,`v2`.`fecha_vigencia` AS `fecha_vigencia`,`v3`.`id_estado` AS `id_estado`,`v3`.`nom_estado` AS `nom_estado` from ((`producto_virtual` `v1` join `version` `v2` on((`v1`.`id_p_virtual` = `v2`.`id_p_virtual`))) join `estado` `v3` on((`v2`.`id_estado` = `v3`.`id_estado`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `18_v_notificaciones`
--
DROP TABLE IF EXISTS `18_v_notificaciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `18_v_notificaciones`  AS  (select `v1`.`id_funcionario` AS `id_funcionario`,`v1`.`nom_funcionario` AS `nom_funcionario`,`v5`.`id_rol` AS `id_rol`,`v5`.`nom_rol` AS `nom_rol`,`v3`.`id_notificacion` AS `id_notificacion`,`v3`.`fecha_envio` AS `fecha_envio`,`v3`.`conte_notificacion` AS `conte_notificacion`,`v3`.`ides_proceso` AS `ides_proceso`,`v3`.`id_funcionario` AS `id_funcionarioenvio`,`v3`.`estado` AS `estado`,`v6`.`id_centro` AS `id_centro`,`v3`.`id_tipo_notificacion` AS `id_tipo_notificacion` from (((((`funcionario` `v1` join `detalles_notificacion` `v2` on((`v1`.`id_funcionario` = `v2`.`id_funcionario`))) join `notificacion` `v3` on((`v2`.`id_notificacion` = `v3`.`id_notificacion`))) join `rol_funcionario` `v4` on(((`v1`.`id_funcionario` = `v4`.`id_funcionario`) and (`v4`.`vigencia` = 1)))) join `rol` `v5` on((`v4`.`id_rol` = `v5`.`id_rol`))) join `area_centro` `v6` on((`v1`.`id_area_centro` = `v6`.`id_area_centro`))) order by `v1`.`id_funcionario`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `19_v_temasformacion`
--
DROP TABLE IF EXISTS `19_v_temasformacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `19_v_temasformacion`  AS  (select `v3`.`id_tema` AS `id_tema`,`v3`.`nom_tema` AS `nom_tema`,`v1`.`id_centro` AS `id_centro` from ((`02_v_area_centro` `v1` join `03_v_detalles_area` `v2` on((`v1`.`id_area` = `v2`.`id_area`))) join `04_v_detalles_programa` `v3` on((`v2`.`id_programa` = `v3`.`id_programa`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `20_v_login`
--
DROP TABLE IF EXISTS `20_v_login`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `20_v_login`  AS  (select `v1`.`id_rol` AS `id_rol`,`v1`.`id_funcionario` AS `id_funcionario`,`v1`.`nom_funcionario` AS `nom_funcionario`,`v2`.`id_centro` AS `id_centro`,`v1`.`num_documento` AS `num_documento`,`v1`.`contraseña` AS `contraseña` from (`08_v_funcionario` `v1` join `area_centro` `v2` on((`v1`.`id_area_centro` = `v2`.`id_area_centro`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `21_v_asignarrol`
--
DROP TABLE IF EXISTS `21_v_asignarrol`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `21_v_asignarrol`  AS  (select `v1`.`id_funcionario` AS `id_funcionario`,concat(`v1`.`nom_funcionario`,' ',`v1`.`apellidos`) AS `nombrecompleto`,`v1`.`cargo` AS `cargo`,`v2`.`id_centro` AS `id_centro`,`v3`.`nom_centro` AS `nom_centro`,`v2`.`id_area` AS `id_area`,`v4`.`nom_area` AS `nom_area`,`v3`.`id_ciudad` AS `id_ciudad`,`v5`.`nom_ciudad` AS `nom_ciudad` from (((((`funcionario` `v1` join `area_centro` `v2` on((`v1`.`id_area_centro` = `v2`.`id_area_centro`))) join `centro` `v3` on((`v2`.`id_centro` = `v3`.`id_centro`))) join `area` `v4` on((`v2`.`id_area` = `v4`.`id_area`))) join `ciudad` `v5` on((`v3`.`id_ciudad` = `v5`.`id_ciudad`))) join `estado` `v7` on((`v1`.`id_estado` = `v7`.`id_estado`))) where (`v1`.`id_estado` = 2)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `22_v_autor_simple`
--
DROP TABLE IF EXISTS `22_v_autor_simple`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `22_v_autor_simple`  AS  (select distinct `v1`.`id_funcionario` AS `id_funcionario`,concat(`v1`.`nom_funcionario`,' ',`v1`.`apellidos`) AS `nombrecompleto`,`v2`.`id_version` AS `id_version` from (`funcionario` `v1` join `autor` `v2` on((`v1`.`id_funcionario` = `v2`.`id_funcionario`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `23_v_consultar`
--
DROP TABLE IF EXISTS `23_v_consultar`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `23_v_consultar`  AS  (select `07_v_version`.`id_p_virtual` AS `id_p_virtual`,`07_v_version`.`nom_p_virtual` AS `nom_p_virtual`,`07_v_version`.`des_p_virtual` AS `des_p_virtual`,`07_v_version`.`palabras_clave` AS `palabras_clave`,`07_v_version`.`fecha_publicacion` AS `fecha_publicacion`,`07_v_version`.`fecha_vigencia` AS `fecha_vigencia`,`07_v_version`.`inst_instalacion` AS `inst_instalacion`,`07_v_version`.`reqst_instalacion` AS `reqst_instalacion`,`07_v_version`.`url_version` AS `url_version`,`07_v_version`.`id_version` AS `id_version`,`07_v_version`.`num_version` AS `num_version` from `07_v_version` where (`07_v_version`.`id_estado` = 6)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `24_v_toquen`
--
DROP TABLE IF EXISTS `24_v_toquen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `24_v_toquen`  AS  (select `toquen`.`numero_toquen` AS `numero_toquen`,`toquen`.`funcionario` AS `funcionario`,`toquen`.`fechavigencia` AS `fechavigencia` from `toquen` where (`toquen`.`fechavigencia` > now())) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `25_v_evaluarproductosv`
--
DROP TABLE IF EXISTS `25_v_evaluarproductosv`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `25_v_evaluarproductosv`  AS  (select `v1`.`id_funcionario` AS `id_funcionario`,`v1`.`nom_funcionario` AS `nom_funcionario`,`v1`.`id_rol` AS `id_rol`,`v1`.`nom_rol` AS `nom_rol`,`v1`.`id_notificacion` AS `id_notificacion`,`v1`.`fecha_envio` AS `fecha_envio`,`v1`.`conte_notificacion` AS `conte_notificacion`,`v1`.`ides_proceso` AS `ides_proceso`,`v1`.`id_funcionarioenvio` AS `id_funcionarioenvio`,`v1`.`estado` AS `estado`,`v1`.`id_centro` AS `id_centro`,`v1`.`id_tipo_notificacion` AS `id_tipo_notificacion`,`v2`.`url_version` AS `url_version`,concat(`v3`.`nom_p_virtual`,' ',`v2`.`num_version`) AS `producto` from ((`18_v_notificaciones` `v1` join `version` `v2` on((`v1`.`ides_proceso` = `v2`.`id_version`))) join `producto_virtual` `v3` on((`v2`.`id_p_virtual` = `v3`.`id_p_virtual`))) where (`v1`.`id_rol` <> 1)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `26_v_comentarios`
--
DROP TABLE IF EXISTS `26_v_comentarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `26_v_comentarios`  AS  (select `v1`.`id_comentario` AS `id_comentario`,`v1`.`comentario` AS `comentario`,`v1`.`id_funcionario` AS `id_funcionario`,concat(`v2`.`nom_funcionario`,' ',`v2`.`apellidos`) AS `nombre_completo`,`v1`.`id_version` AS `id_version` from (`comentario` `v1` join `funcionario` `v2` on((`v1`.`id_funcionario` = `v2`.`id_funcionario`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `27_v_autores`
--
DROP TABLE IF EXISTS `27_v_autores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `27_v_autores`  AS  (select distinct `v1`.`id_funcionario` AS `id_funcionario`,concat(`v1`.`nom_funcionario`,' ',`v1`.`apellidos`) AS `nombrecompleto` from (`08_v_funcionario` `v1` join `autor` `v2` on((`v1`.`id_funcionario` = `v2`.`id_funcionario`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `28_v_consultacategoria`
--
DROP TABLE IF EXISTS `28_v_consultacategoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `28_v_consultacategoria`  AS  (select distinct `v3`.`id_p_virtual` AS `id_p_virtual`,`v3`.`nom_p_virtual` AS `nom_p_virtual`,`v3`.`des_p_virtual` AS `des_p_virtual`,`v2`.`id_formato` AS `id_formato`,`v3`.`fecha_publicacion` AS `fecha_publicacion`,`v4`.`id_funcionario` AS `id_funcionario`,`v1`.`id_categoria` AS `id_categoria`,`v4`.`id_version` AS `id_version` from (((`05_v_detalles_categoria` `v1` join `06_v_detalles_tema` `v2` on((`v1`.`id_tema` = `v2`.`id_tema`))) join `23_v_consultar` `v3` on((`v2`.`id_p_virtual` = `v3`.`id_p_virtual`))) join `22_v_autor_simple` `v4` on((`v3`.`id_version` = `v4`.`id_version`))) where ((`v2`.`tipo_tema` = 1) and (`v3`.`num_version` = (select `v22`.`num_version` from (`producto_virtual` `v11` join `version` `v22` on((`v11`.`id_p_virtual` = `v22`.`id_p_virtual`))) where ((`v11`.`id_p_virtual` = `v3`.`id_p_virtual`) and (`v22`.`id_estado` in (6,7))) order by `v22`.`num_version` desc limit 1)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `29_v_consultaprograma`
--
DROP TABLE IF EXISTS `29_v_consultaprograma`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `29_v_consultaprograma`  AS  (select distinct `v3`.`id_p_virtual` AS `id_p_virtual`,`v3`.`nom_p_virtual` AS `nom_p_virtual`,`v3`.`des_p_virtual` AS `des_p_virtual`,`v2`.`id_formato` AS `id_formato`,`v3`.`fecha_publicacion` AS `fecha_publicacion`,`v4`.`id_funcionario` AS `id_funcionario`,`v1`.`id_programa` AS `id_programa`,`v4`.`id_version` AS `id_version` from (((`04_v_detalles_programa` `v1` join `06_v_detalles_tema` `v2` on((`v1`.`id_tema` = `v2`.`id_tema`))) join `23_v_consultar` `v3` on((`v2`.`id_p_virtual` = `v3`.`id_p_virtual`))) join `22_v_autor_simple` `v4` on((`v3`.`id_version` = `v4`.`id_version`))) where ((`v2`.`tipo_tema` = 0) and (`v3`.`num_version` = (select `v22`.`num_version` from (`producto_virtual` `v11` join `version` `v22` on((`v11`.`id_p_virtual` = `v22`.`id_p_virtual`))) where ((`v11`.`id_p_virtual` = `v3`.`id_p_virtual`) and (`v22`.`id_estado` in (6,7))) order by `v22`.`num_version` desc limit 1)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `30_v_consultanormal`
--
DROP TABLE IF EXISTS `30_v_consultanormal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `30_v_consultanormal`  AS  (select `v1`.`id_p_virtual` AS `id_p_virtual`,`v1`.`nom_p_virtual` AS `nom_p_virtual`,`v1`.`des_p_virtual` AS `des_p_virtual`,`v1`.`palabras_clave` AS `palabras_clave`,`v1`.`fecha_publicacion` AS `fecha_publicacion`,`v1`.`id_version` AS `id_version` from `23_v_consultar` `v1` where (`v1`.`num_version` = (select `v22`.`num_version` from (`producto_virtual` `v11` join `version` `v22` on((`v11`.`id_p_virtual` = `v22`.`id_p_virtual`))) where ((`v11`.`id_p_virtual` = `v1`.`id_p_virtual`) and (`v22`.`id_estado` in (6,7))) order by `v22`.`num_version` desc limit 1))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `31_v_estadisticatipo1`
--
DROP TABLE IF EXISTS `31_v_estadisticatipo1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `31_v_estadisticatipo1`  AS  (select distinct `v1`.`id_formato` AS `id_formato`,`v1`.`nom_formato` AS `nom_formato`,`v2`.`id_p_virtual` AS `id_p_virtual`,`v2`.`nom_p_virtual` AS `nom_p_virtual`,`v3`.`fecha_publicacion` AS `fecha_publicacion`,`v5`.`id_centro` AS `id_centro` from ((((`formato` `v1` join `producto_virtual` `v2` on((`v1`.`id_formato` = `v2`.`id_formato`))) join `version` `v3` on((`v2`.`id_p_virtual` = `v3`.`id_p_virtual`))) join `autor` `v4` on((`v3`.`id_version` = `v4`.`id_version`))) join `08_v_funcionario` `v5` on((`v4`.`id_funcionario` = `v5`.`id_funcionario`))) where (`v3`.`id_estado` = 6)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `32_v_estadisticatipo2`
--
DROP TABLE IF EXISTS `32_v_estadisticatipo2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `32_v_estadisticatipo2`  AS  (select `31_v_estadisticatipo1`.`id_formato` AS `id_formato`,`31_v_estadisticatipo1`.`nom_formato` AS `nom_formato`,count(0) AS `cantidad`,`31_v_estadisticatipo1`.`id_centro` AS `id_centro` from `31_v_estadisticatipo1` group by `31_v_estadisticatipo1`.`id_formato`,`31_v_estadisticatipo1`.`nom_formato`,`31_v_estadisticatipo1`.`id_centro`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `33_v_estadisticaarea1`
--
DROP TABLE IF EXISTS `33_v_estadisticaarea1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `33_v_estadisticaarea1`  AS  (select distinct `v7`.`id_area` AS `id_area`,`v7`.`nom_area` AS `nom_area`,`v1`.`id_p_virtual` AS `id_p_virtual`,`v1`.`nom_p_virtual` AS `nom_p_virtual`,`v9`.`fecha_publicacion` AS `fecha_publicacion`,`v8`.`id_centro` AS `id_centro` from ((((((((`producto_virtual` `v1` join `detalles_tema` `v2` on((`v1`.`id_p_virtual` = `v2`.`id_p_virtual`))) join `tema` `v3` on((`v2`.`id_tema` = `v3`.`id_tema`))) join `detalles_programa` `v4` on((`v3`.`id_tema` = `v4`.`id_tema`))) join `programa` `v5` on((`v4`.`id_programa` = `v5`.`id_programa`))) join `detalles_area` `v6` on((`v5`.`id_programa` = `v6`.`id_programa`))) join `area` `v7` on((`v6`.`id_area` = `v7`.`id_area`))) join `area_centro` `v8` on((`v7`.`id_area` = `v8`.`id_area`))) join `version` `v9` on((`v1`.`id_p_virtual` = `v9`.`id_p_virtual`))) where ((`v9`.`id_estado` = 6) and (`v2`.`tipo_tema` = 0))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `34_v_estadisticaarea2`
--
DROP TABLE IF EXISTS `34_v_estadisticaarea2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `34_v_estadisticaarea2`  AS  (select `33_v_estadisticaarea1`.`id_area` AS `id_area`,`33_v_estadisticaarea1`.`nom_area` AS `nom_area`,count(0) AS `cantidad`,`33_v_estadisticaarea1`.`id_centro` AS `id_centro` from `33_v_estadisticaarea1` group by `33_v_estadisticaarea1`.`id_area`,`33_v_estadisticaarea1`.`nom_area`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `35_v_estadisticacategoria1`
--
DROP TABLE IF EXISTS `35_v_estadisticacategoria1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `35_v_estadisticacategoria1`  AS  (select distinct `v5`.`id_categoria` AS `id_categoria`,`v5`.`nom_categoria` AS `nom_categoria`,`v1`.`id_p_virtual` AS `id_p_virtual`,`v6`.`fecha_publicacion` AS `fecha_publicacion`,`v8`.`id_centro` AS `id_centro` from (((((((`producto_virtual` `v1` join `detalles_tema` `v2` on((`v1`.`id_p_virtual` = `v2`.`id_p_virtual`))) join `tema` `v3` on((`v2`.`id_tema` = `v3`.`id_tema`))) join `detalles_categoria` `v4` on((`v3`.`id_tema` = `v4`.`id_tema`))) join `categoria` `v5` on((`v4`.`id_categoria` = `v5`.`id_categoria`))) join `version` `v6` on((`v1`.`id_p_virtual` = `v6`.`id_p_virtual`))) join `autor` `v7` on((`v6`.`id_version` = `v7`.`id_version`))) join `08_v_funcionario` `v8` on((`v7`.`id_funcionario` = `v8`.`id_funcionario`))) where (`v6`.`id_estado` in (6,7))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `36_v_estadisticacategoria2`
--
DROP TABLE IF EXISTS `36_v_estadisticacategoria2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `36_v_estadisticacategoria2`  AS  (select `35_v_estadisticacategoria1`.`id_categoria` AS `id_categoria`,`35_v_estadisticacategoria1`.`nom_categoria` AS `nom_categoria`,count(0) AS `canti`,`35_v_estadisticacategoria1`.`id_centro` AS `id_centro` from `35_v_estadisticacategoria1` group by `35_v_estadisticacategoria1`.`id_categoria`,`35_v_estadisticacategoria1`.`nom_categoria`,`35_v_estadisticacategoria1`.`id_centro`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `37_v_evaluaciongeneral`
--
DROP TABLE IF EXISTS `37_v_evaluaciongeneral`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `37_v_evaluaciongeneral`  AS  (select `v1`.`id_evaluacion_general` AS `id_evaluacion_general`,`v1`.`id_lista_chequeo` AS `id_lista_chequeo`,`v5`.`nom_lista_chequeo` AS `nom_lista_chequeo`,`v2`.`valorizacion` AS `valorizacion`,`v2`.`observacion` AS `observacion`,`v3`.`id_item_lista` AS `id_item_lista`,`v4`.`des_item_lista` AS `des_item_lista`,`v1`.`observacion` AS `observacion_general`,`v1`.`resultado` AS `resultado`,`v1`.`fecha_evaluacion` AS `fecha_evaluacion` from ((((`evaluacion_general` `v1` join `detalles_evaluacion` `v2` on((`v1`.`id_evaluacion_general` = `v2`.`id_evaluacion_general`))) join `detalles_lista` `v3` on((`v2`.`id_detalles_lista` = `v3`.`id_detalles_lista`))) join `item_lista` `v4` on((`v3`.`id_item_lista` = `v4`.`id_item_lista`))) join `lista_chequeo` `v5` on((`v1`.`id_lista_chequeo` = `v5`.`id_lista_chequeo`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `38_v_notificaciones_ar`
--
DROP TABLE IF EXISTS `38_v_notificaciones_ar`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `38_v_notificaciones_ar`  AS  (select `v1`.`id_funcionario` AS `id_funcionario`,`v1`.`nom_funcionario` AS `nom_funcionario`,`v1`.`id_rol` AS `id_rol`,`v1`.`nom_rol` AS `nom_rol`,`v1`.`id_notificacion` AS `id_notificacion`,`v1`.`fecha_envio` AS `fecha_envio`,`v1`.`conte_notificacion` AS `conte_notificacion`,`v1`.`ides_proceso` AS `ides_proceso`,`v3`.`nom_p_virtual` AS `nom_p_virtual`,`v2`.`num_version` AS `num_version`,`v1`.`id_funcionarioenvio` AS `id_funcionarioenvio`,`v1`.`estado` AS `estado`,`v1`.`id_centro` AS `id_centro`,`v1`.`id_tipo_notificacion` AS `id_tipo_notificacion` from ((`18_v_notificaciones` `v1` join `version` `v2` on((`v1`.`ides_proceso` = `v2`.`id_version`))) join `producto_virtual` `v3` on((`v3`.`id_p_virtual` = `v2`.`id_p_virtual`))) where (`v1`.`id_tipo_notificacion` in (2,3))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `39_v_listacategoria`
--
DROP TABLE IF EXISTS `39_v_listacategoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `39_v_listacategoria`  AS  (select `v1`.`id_categoria` AS `id_categoria`,`v1`.`nom_categoria` AS `nom_categoria`,`v1`.`fecha_creacion` AS `fecha_creacion`,`v2`.`id_centro` AS `id_centro` from (`categoria` `v1` join `08_v_funcionario` `v2` on((`v1`.`id_funcionario` = `v2`.`id_funcionario`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `40_v_evaluaversion`
--
DROP TABLE IF EXISTS `40_v_evaluaversion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `40_v_evaluaversion`  AS  (select `v2`.`id_evaluacion_general` AS `id_evaluacion_general`,`v1`.`nom_p_virtual` AS `nom_p_virtual`,`v1`.`num_version` AS `num_version`,`v1`.`id_version` AS `id_version`,`v1`.`url_version` AS `url_version` from (`07_v_version` `v1` join `evaluacion_general` `v2` on((`v1`.`id_version` = `v2`.`id_version`)))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `41_v_consultatodo`
--
DROP TABLE IF EXISTS `41_v_consultatodo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `41_v_consultatodo`  AS  (select distinct `v3`.`id_p_virtual` AS `id_p_virtual`,`v3`.`nom_p_virtual` AS `nom_p_virtual`,`v3`.`des_p_virtual` AS `des_p_virtual`,`v5`.`id_formato` AS `id_formato`,`v6`.`id_tipo_formato` AS `id_tipo_formato`,`v6`.`nom_tipo_formato` AS `nom_tipo_formato`,`v3`.`fecha_publicacion` AS `fecha_publicacion`,`v4`.`id_version` AS `id_version`,`v4`.`id_funcionario` AS `id_funcionario`,`v4`.`nombrecompleto` AS `nombrecompleto`,`v1`.`id_programa` AS `id_programa`,`v1_1`.`id_categoria` AS `id_categoria`,`v2`.`tipo_tema` AS `tipo_tema` from ((((((`04_v_detalles_programa` `v1` join `06_v_detalles_tema` `v2` on((`v1`.`id_tema` = `v2`.`id_tema`))) join `05_v_detalles_categoria` `v1_1` on((`v1_1`.`id_tema` = `v2`.`id_tema`))) join `23_v_consultar` `v3` on((`v2`.`id_p_virtual` = `v3`.`id_p_virtual`))) join `22_v_autor_simple` `v4` on((`v3`.`id_version` = `v4`.`id_version`))) join `formato` `v5` on((`v2`.`id_formato` = `v5`.`id_formato`))) join `tipo_formato` `v6` on((`v5`.`id_tipo_formato` = `v6`.`id_tipo_formato`))) where (`v3`.`num_version` = (select `v22`.`num_version` from (`producto_virtual` `v11` join `version` `v22` on((`v11`.`id_p_virtual` = `v22`.`id_p_virtual`))) where ((`v11`.`id_p_virtual` = `v3`.`id_p_virtual`) and (`v22`.`id_estado` in (6,7))) order by `v22`.`num_version` desc limit 1))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `42_v_productosactualizar`
--
DROP TABLE IF EXISTS `42_v_productosactualizar`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `42_v_productosactualizar`  AS  (select distinct `v1`.`id_p_virtual` AS `id_p_virtual`,`v1`.`nom_p_virtual` AS `nom_p_virtual`,`v3`.`id_funcionario` AS `id_funcionario` from ((`producto_virtual` `v1` join `version` `v2` on((`v1`.`id_p_virtual` = `v2`.`id_p_virtual`))) join `autor` `v3` on((`v2`.`id_version` = `v3`.`id_version`))) where (`v2`.`id_estado` in (6,7))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `43_v_consultatodonotificacion`
--
DROP TABLE IF EXISTS `43_v_consultatodonotificacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `43_v_consultatodonotificacion`  AS  (select `v1`.`id_notificacion` AS `id_notificacion`,`v1`.`fecha_envio` AS `fecha_envio`,`v1`.`conte_notificacion` AS `conte_notificacion`,`v1`.`ides_proceso` AS `ides_proceso`,(case when (`v1`.`id_tipo_notificacion` in (1,3)) then 1 else 2 end) AS `tipoides`,`v1`.`id_tipo_notificacion` AS `id_tipo_notificacion`,`v1`.`id_funcionario` AS `idfuncionarioenvia`,`v3`.`nom_funcionario` AS `nomfuncionarioenvia`,`v3`.`id_area_centro` AS `idareacentroenvia`,`v5`.`id_centro` AS `idcentroenvia`,`v7`.`id_rol` AS `idrolenvia`,`v1`.`estado` AS `estadonotificacion`,`v2`.`id_detalles_notificacion` AS `id_detalles_notificacion`,`v2`.`id_funcionario` AS `idfuncionariorecibe`,`v4`.`nom_funcionario` AS `idnomfuncionariorecibe`,`v4`.`id_area_centro` AS `idareacentrorecibe`,`v6`.`id_centro` AS `idcentrorecibe`,`v8`.`id_rol` AS `idrolrecibe` from (((((((`notificacion` `v1` join `detalles_notificacion` `v2` on((`v1`.`id_notificacion` = `v2`.`id_notificacion`))) join `funcionario` `v3` on((`v1`.`id_funcionario` = `v3`.`id_funcionario`))) join `funcionario` `v4` on((`v2`.`id_funcionario` = `v4`.`id_funcionario`))) join `area_centro` `v5` on((`v3`.`id_area_centro` = `v5`.`id_area_centro`))) join `area_centro` `v6` on((`v4`.`id_area_centro` = `v6`.`id_area_centro`))) join `rol_funcionario` `v7` on(((`v3`.`id_funcionario` = `v7`.`id_funcionario`) and (`v7`.`vigencia` = 1)))) join `rol_funcionario` `v8` on(((`v3`.`id_funcionario` = `v8`.`id_funcionario`) and (`v8`.`vigencia` = 1))))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `45_consultapuestos`
--
DROP TABLE IF EXISTS `45_consultapuestos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `45_consultapuestos`  AS  (select `v1`.`puesto` AS `puesto`,`v3`.`nom_p_virtual` AS `producto`,`v2`.`num_version` AS `version`,`v7`.`nom_centro` AS `centro` from ((((((`rankin` `v1` join `version` `v2` on((`v1`.`id_version` = `v2`.`id_version`))) join `producto_virtual` `v3` on((`v2`.`id_p_virtual` = `v3`.`id_p_virtual`))) join `autor` `v4` on((`v2`.`id_version` = `v4`.`id_version`))) join `funcionario` `v5` on((`v4`.`id_funcionario` = `v5`.`id_funcionario`))) join `area_centro` `v6` on((`v5`.`id_area_centro` = `v6`.`id_area_centro`))) join `centro` `v7` on((`v6`.`id_centro` = `v7`.`id_centro`))) where (`v4`.`principal` = 1) order by `v1`.`puesto`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vistapuesto`
--
DROP TABLE IF EXISTS `vistapuesto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistapuesto`  AS  (select `v1`.`id_rankin` AS `id_rankin`,lpad(((((sum(`v2`.`num_voto`) / `v1`.`cant_votos`) * 0.7) + (`v1`.`cant_descargas` * 0.2)) + (`v1`.`cant_visitas` * 0.1)),3,'0') AS `val_puesto`,`v1`.`puesto` AS `puesto` from (`rankin` `v1` join `voto` `v2` on((`v1`.`id_rankin` = `v2`.`id_rankin`))) group by `v1`.`id_rankin`) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `admin`
--
ALTER TABLE `admin`
  ADD UNIQUE KEY `un_admin` (`usuario`,`clave`);

--
-- Indices de la tabla `area`
--
ALTER TABLE `area`
  ADD PRIMARY KEY (`id_area`),
  ADD UNIQUE KEY `un_area` (`nom_area`);

--
-- Indices de la tabla `area_centro`
--
ALTER TABLE `area_centro`
  ADD PRIMARY KEY (`id_area_centro`),
  ADD UNIQUE KEY `un_area_centro` (`id_area`,`id_centro`),
  ADD KEY `fk_centro` (`id_centro`);

--
-- Indices de la tabla `area_centro_log`
--
ALTER TABLE `area_centro_log`
  ADD PRIMARY KEY (`id_area_centro_log`);

--
-- Indices de la tabla `area_log`
--
ALTER TABLE `area_log`
  ADD PRIMARY KEY (`id_area_log`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`id_autor`),
  ADD UNIQUE KEY `un_autor` (`id_version`,`id_funcionario`),
  ADD KEY `fk_funcionario_02` (`id_funcionario`);

--
-- Indices de la tabla `autor_log`
--
ALTER TABLE `autor_log`
  ADD PRIMARY KEY (`id_autor_log`);

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `un_categoria_01` (`nom_categoria`),
  ADD UNIQUE KEY `un_categoria_02` (`des_categoria`),
  ADD KEY `fk_funcionario_08` (`id_funcionario`);

--
-- Indices de la tabla `categoria_log`
--
ALTER TABLE `categoria_log`
  ADD PRIMARY KEY (`id_categoria_log`);

--
-- Indices de la tabla `centro`
--
ALTER TABLE `centro`
  ADD PRIMARY KEY (`id_centro`),
  ADD UNIQUE KEY `un_centro_01` (`num_centro`),
  ADD UNIQUE KEY `un_centro_02` (`nom_centro`),
  ADD UNIQUE KEY `un_centro_03` (`direccion`),
  ADD KEY `fk_ciudad` (`id_ciudad`);

--
-- Indices de la tabla `centro_log`
--
ALTER TABLE `centro_log`
  ADD PRIMARY KEY (`id_centro_log`);

--
-- Indices de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  ADD PRIMARY KEY (`id_ciudad`),
  ADD UNIQUE KEY `un_ciudad` (`nom_ciudad`);

--
-- Indices de la tabla `ciudad_log`
--
ALTER TABLE `ciudad_log`
  ADD PRIMARY KEY (`id_ciudad_log`);

--
-- Indices de la tabla `comentario`
--
ALTER TABLE `comentario`
  ADD PRIMARY KEY (`id_comentario`),
  ADD UNIQUE KEY `un_comentario` (`comentario`),
  ADD KEY `fk_funcionario_03` (`id_funcionario`),
  ADD KEY `fk_version_02` (`id_version`);

--
-- Indices de la tabla `comentario_log`
--
ALTER TABLE `comentario_log`
  ADD PRIMARY KEY (`id_comentario_log`);

--
-- Indices de la tabla `detalles_area`
--
ALTER TABLE `detalles_area`
  ADD PRIMARY KEY (`id_detalles_area`),
  ADD UNIQUE KEY `un_detalles_area` (`id_area`,`id_programa`),
  ADD KEY `fk_programa_02` (`id_programa`);

--
-- Indices de la tabla `detalles_area_log`
--
ALTER TABLE `detalles_area_log`
  ADD PRIMARY KEY (`id_detalles_area_log`);

--
-- Indices de la tabla `detalles_categoria`
--
ALTER TABLE `detalles_categoria`
  ADD PRIMARY KEY (`id_detalles_categoria`),
  ADD UNIQUE KEY `un_detalles_categoria` (`id_categoria`,`id_tema`),
  ADD KEY `fk_tema_03` (`id_tema`);

--
-- Indices de la tabla `detalles_categoria_log`
--
ALTER TABLE `detalles_categoria_log`
  ADD PRIMARY KEY (`id_detalles_categoria_log`);

--
-- Indices de la tabla `detalles_evaluacion`
--
ALTER TABLE `detalles_evaluacion`
  ADD PRIMARY KEY (`id_detalles_evaluacion`),
  ADD KEY `fk_detalles_lista` (`id_detalles_lista`),
  ADD KEY `fk_evaluacion_general` (`id_evaluacion_general`);

--
-- Indices de la tabla `detalles_evaluacion_log`
--
ALTER TABLE `detalles_evaluacion_log`
  ADD PRIMARY KEY (`id_detalles_evaluacion_log`);

--
-- Indices de la tabla `detalles_lista`
--
ALTER TABLE `detalles_lista`
  ADD PRIMARY KEY (`id_detalles_lista`),
  ADD UNIQUE KEY `un_detalles_lista` (`id_lista_chequeo`,`id_item_lista`),
  ADD KEY `fk_item_lista` (`id_item_lista`);

--
-- Indices de la tabla `detalles_lista_log`
--
ALTER TABLE `detalles_lista_log`
  ADD PRIMARY KEY (`id_detalles_lista_log`);

--
-- Indices de la tabla `detalles_notificacion`
--
ALTER TABLE `detalles_notificacion`
  ADD PRIMARY KEY (`id_detalles_notificacion`),
  ADD UNIQUE KEY `un_detalles_notificacion` (`id_notificacion`,`id_funcionario`),
  ADD KEY `fk_funcionario_07` (`id_funcionario`);

--
-- Indices de la tabla `detalles_notificacion_log`
--
ALTER TABLE `detalles_notificacion_log`
  ADD PRIMARY KEY (`id_detalles_notificacion_log`);

--
-- Indices de la tabla `detalles_programa`
--
ALTER TABLE `detalles_programa`
  ADD PRIMARY KEY (`id_detalles_programa`),
  ADD UNIQUE KEY `un_detalles_programa` (`id_tema`,`id_programa`),
  ADD KEY `fk_programa_01` (`id_programa`);

--
-- Indices de la tabla `detalles_programa_log`
--
ALTER TABLE `detalles_programa_log`
  ADD PRIMARY KEY (`id_detalles_programa_log`);

--
-- Indices de la tabla `detalles_tema`
--
ALTER TABLE `detalles_tema`
  ADD PRIMARY KEY (`id_detalles_tema`),
  ADD UNIQUE KEY `un_detalles_tema` (`id_tema`,`id_p_virtual`,`tipo_tema`),
  ADD KEY `fk_p_virtual_02` (`id_p_virtual`);

--
-- Indices de la tabla `detalles_tema_log`
--
ALTER TABLE `detalles_tema_log`
  ADD PRIMARY KEY (`id_detalles_tema_log`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`id_estado`),
  ADD UNIQUE KEY `un_estado` (`nom_estado`),
  ADD KEY `fk_tipo_estado` (`id_tipo_estado`);

--
-- Indices de la tabla `estado_log`
--
ALTER TABLE `estado_log`
  ADD PRIMARY KEY (`id_estado_log`);

--
-- Indices de la tabla `evaluacion_general`
--
ALTER TABLE `evaluacion_general`
  ADD PRIMARY KEY (`id_evaluacion_general`),
  ADD KEY `fk_version_03` (`id_version`),
  ADD KEY `fk_lista_chequeo_02` (`id_lista_chequeo`),
  ADD KEY `fk_funcionario_05` (`id_funcionario`);

--
-- Indices de la tabla `evaluacion_general_log`
--
ALTER TABLE `evaluacion_general_log`
  ADD PRIMARY KEY (`id_evaluacion_general_log`);

--
-- Indices de la tabla `formato`
--
ALTER TABLE `formato`
  ADD PRIMARY KEY (`id_formato`),
  ADD UNIQUE KEY `un_formtato_01` (`nom_formato`),
  ADD KEY `fk_tipoformato` (`id_tipo_formato`);

--
-- Indices de la tabla `formato_log`
--
ALTER TABLE `formato_log`
  ADD PRIMARY KEY (`id_formato_log`);

--
-- Indices de la tabla `funcionario`
--
ALTER TABLE `funcionario`
  ADD PRIMARY KEY (`id_funcionario`),
  ADD UNIQUE KEY `un_funcionario_01` (`num_documento`),
  ADD UNIQUE KEY `un_funcionario_02` (`correo`),
  ADD UNIQUE KEY `un_funcionario_03` (`ip_sena`),
  ADD KEY `fk_tipo_documento` (`id_tipo_documento`),
  ADD KEY `fk_estado_02` (`id_estado`),
  ADD KEY `fk_area_centro` (`id_area_centro`);

--
-- Indices de la tabla `funcionario_log`
--
ALTER TABLE `funcionario_log`
  ADD PRIMARY KEY (`id_funcionario_log`);

--
-- Indices de la tabla `item_lista`
--
ALTER TABLE `item_lista`
  ADD PRIMARY KEY (`id_item_lista`),
  ADD UNIQUE KEY `un_item_lista` (`des_item_lista`);

--
-- Indices de la tabla `item_lista_log`
--
ALTER TABLE `item_lista_log`
  ADD PRIMARY KEY (`id_item_lista_log`);

--
-- Indices de la tabla `lista_chequeo`
--
ALTER TABLE `lista_chequeo`
  ADD PRIMARY KEY (`id_lista_chequeo`),
  ADD UNIQUE KEY `un_lista_chequeo_01` (`nom_lista_chequeo`),
  ADD UNIQUE KEY `un_lista_chequeo_02` (`des_lista_chequeo`),
  ADD KEY `fk_funcionario_04` (`id_funcionario`);

--
-- Indices de la tabla `lista_chequeo_log`
--
ALTER TABLE `lista_chequeo_log`
  ADD PRIMARY KEY (`id_lista_chequeo_log`);

--
-- Indices de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `fk_tipo_notificacion` (`id_tipo_notificacion`),
  ADD KEY `fk_funcionario_06` (`id_funcionario`);

--
-- Indices de la tabla `notificacion_log`
--
ALTER TABLE `notificacion_log`
  ADD PRIMARY KEY (`id_notificacion_log`);

--
-- Indices de la tabla `producto_virtual`
--
ALTER TABLE `producto_virtual`
  ADD PRIMARY KEY (`id_p_virtual`),
  ADD UNIQUE KEY `un_p_virtual_01` (`nom_p_virtual`),
  ADD UNIQUE KEY `un_p_virtual_02` (`des_p_virtual`),
  ADD KEY `fk_formato` (`id_formato`);

--
-- Indices de la tabla `producto_virtual_log`
--
ALTER TABLE `producto_virtual_log`
  ADD PRIMARY KEY (`id_p_virtual_log`);

--
-- Indices de la tabla `programa`
--
ALTER TABLE `programa`
  ADD PRIMARY KEY (`id_programa`),
  ADD UNIQUE KEY `un_programa` (`nom_programa`),
  ADD KEY `id_programa_red` (`id_programa_red`);

--
-- Indices de la tabla `programa_log`
--
ALTER TABLE `programa_log`
  ADD PRIMARY KEY (`id_programa_log`);

--
-- Indices de la tabla `rankin`
--
ALTER TABLE `rankin`
  ADD PRIMARY KEY (`id_rankin`),
  ADD UNIQUE KEY `un_rankin` (`id_version`);

--
-- Indices de la tabla `rankin_log`
--
ALTER TABLE `rankin_log`
  ADD PRIMARY KEY (`id_rankin_log`);

--
-- Indices de la tabla `red_deconocimiento`
--
ALTER TABLE `red_deconocimiento`
  ADD PRIMARY KEY (`id_red`),
  ADD KEY `id_red` (`id_red`);

--
-- Indices de la tabla `red_programa`
--
ALTER TABLE `red_programa`
  ADD PRIMARY KEY (`id_programa`),
  ADD UNIQUE KEY `un_programa` (`nom_programa`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `un_rol_01` (`nom_rol`),
  ADD UNIQUE KEY `un_rol_02` (`des_rol`);

--
-- Indices de la tabla `rol_funcionario`
--
ALTER TABLE `rol_funcionario`
  ADD PRIMARY KEY (`id_rol_funcionario`),
  ADD UNIQUE KEY `un_rol_funcionario` (`id_rol`,`id_funcionario`),
  ADD KEY `fk_funcionario_01` (`id_funcionario`);

--
-- Indices de la tabla `rol_funcionario_log`
--
ALTER TABLE `rol_funcionario_log`
  ADD PRIMARY KEY (`id_rol_funcionario_log`);

--
-- Indices de la tabla `rol_log`
--
ALTER TABLE `rol_log`
  ADD PRIMARY KEY (`id_rol_log`);

--
-- Indices de la tabla `tema`
--
ALTER TABLE `tema`
  ADD PRIMARY KEY (`id_tema`),
  ADD UNIQUE KEY `un_tema_01` (`nom_tema`),
  ADD UNIQUE KEY `un_tema_02` (`des_tema`);

--
-- Indices de la tabla `tema_log`
--
ALTER TABLE `tema_log`
  ADD PRIMARY KEY (`id_tema_log`);

--
-- Indices de la tabla `tipo_documento`
--
ALTER TABLE `tipo_documento`
  ADD PRIMARY KEY (`id_tipo_documento`),
  ADD UNIQUE KEY `un_tipo_documento` (`nom_tipo_documento`);

--
-- Indices de la tabla `tipo_documento_log`
--
ALTER TABLE `tipo_documento_log`
  ADD PRIMARY KEY (`id_tipo_documento_log`);

--
-- Indices de la tabla `tipo_estado`
--
ALTER TABLE `tipo_estado`
  ADD PRIMARY KEY (`id_tipo_estado`),
  ADD UNIQUE KEY `un_tipo_estado` (`nom_tipo_estado`);

--
-- Indices de la tabla `tipo_estado_log`
--
ALTER TABLE `tipo_estado_log`
  ADD PRIMARY KEY (`id_tipo_estado_log`);

--
-- Indices de la tabla `tipo_formato`
--
ALTER TABLE `tipo_formato`
  ADD PRIMARY KEY (`id_tipo_formato`),
  ADD UNIQUE KEY `un_tipoformato` (`nom_tipo_formato`);

--
-- Indices de la tabla `tipo_formato_log`
--
ALTER TABLE `tipo_formato_log`
  ADD PRIMARY KEY (`id_tipo_formato_log`);

--
-- Indices de la tabla `tipo_notificacion`
--
ALTER TABLE `tipo_notificacion`
  ADD PRIMARY KEY (`id_tipo_notificacion`),
  ADD UNIQUE KEY `un_tipo_notificacion_01` (`nom_tipo_notif`),
  ADD UNIQUE KEY `un_tipo_notificacion_02` (`des_tipo_notif`);

--
-- Indices de la tabla `tipo_notificacion_log`
--
ALTER TABLE `tipo_notificacion_log`
  ADD PRIMARY KEY (`id_tipo_notificacion_log`);

--
-- Indices de la tabla `toquen`
--
ALTER TABLE `toquen`
  ADD PRIMARY KEY (`numero_toquen`),
  ADD UNIQUE KEY `un_toquen` (`funcionario`);

--
-- Indices de la tabla `version`
--
ALTER TABLE `version`
  ADD PRIMARY KEY (`id_version`),
  ADD KEY `fk_p_virtual_01` (`id_p_virtual`),
  ADD KEY `fk_estado_01` (`id_estado`);

--
-- Indices de la tabla `version_log`
--
ALTER TABLE `version_log`
  ADD PRIMARY KEY (`id_version_log`);

--
-- Indices de la tabla `voto`
--
ALTER TABLE `voto`
  ADD PRIMARY KEY (`id_voto`),
  ADD UNIQUE KEY `un_voto` (`num_voto`,`id_funcionario`,`id_rankin`),
  ADD KEY `fk_funcionario_voto` (`id_funcionario`),
  ADD KEY `fk_rankin` (`id_rankin`);

--
-- Indices de la tabla `voto_log`
--
ALTER TABLE `voto_log`
  ADD PRIMARY KEY (`id_voto_log`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `area`
--
ALTER TABLE `area`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `area_centro`
--
ALTER TABLE `area_centro`
  MODIFY `id_area_centro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `area_centro_log`
--
ALTER TABLE `area_centro_log`
  MODIFY `id_area_centro_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `area_log`
--
ALTER TABLE `area_log`
  MODIFY `id_area_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `autor`
--
ALTER TABLE `autor`
  MODIFY `id_autor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `autor_log`
--
ALTER TABLE `autor_log`
  MODIFY `id_autor_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `categoria_log`
--
ALTER TABLE `categoria_log`
  MODIFY `id_categoria_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `centro`
--
ALTER TABLE `centro`
  MODIFY `id_centro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `centro_log`
--
ALTER TABLE `centro_log`
  MODIFY `id_centro_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  MODIFY `id_ciudad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ciudad_log`
--
ALTER TABLE `ciudad_log`
  MODIFY `id_ciudad_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `comentario`
--
ALTER TABLE `comentario`
  MODIFY `id_comentario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comentario_log`
--
ALTER TABLE `comentario_log`
  MODIFY `id_comentario_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalles_area`
--
ALTER TABLE `detalles_area`
  MODIFY `id_detalles_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalles_area_log`
--
ALTER TABLE `detalles_area_log`
  MODIFY `id_detalles_area_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalles_categoria`
--
ALTER TABLE `detalles_categoria`
  MODIFY `id_detalles_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalles_categoria_log`
--
ALTER TABLE `detalles_categoria_log`
  MODIFY `id_detalles_categoria_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalles_evaluacion`
--
ALTER TABLE `detalles_evaluacion`
  MODIFY `id_detalles_evaluacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalles_evaluacion_log`
--
ALTER TABLE `detalles_evaluacion_log`
  MODIFY `id_detalles_evaluacion_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalles_lista`
--
ALTER TABLE `detalles_lista`
  MODIFY `id_detalles_lista` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `detalles_lista_log`
--
ALTER TABLE `detalles_lista_log`
  MODIFY `id_detalles_lista_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `detalles_notificacion`
--
ALTER TABLE `detalles_notificacion`
  MODIFY `id_detalles_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `detalles_notificacion_log`
--
ALTER TABLE `detalles_notificacion_log`
  MODIFY `id_detalles_notificacion_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `detalles_programa`
--
ALTER TABLE `detalles_programa`
  MODIFY `id_detalles_programa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `detalles_programa_log`
--
ALTER TABLE `detalles_programa_log`
  MODIFY `id_detalles_programa_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `detalles_tema`
--
ALTER TABLE `detalles_tema`
  MODIFY `id_detalles_tema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `detalles_tema_log`
--
ALTER TABLE `detalles_tema_log`
  MODIFY `id_detalles_tema_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `estado`
--
ALTER TABLE `estado`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `estado_log`
--
ALTER TABLE `estado_log`
  MODIFY `id_estado_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `evaluacion_general`
--
ALTER TABLE `evaluacion_general`
  MODIFY `id_evaluacion_general` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `evaluacion_general_log`
--
ALTER TABLE `evaluacion_general_log`
  MODIFY `id_evaluacion_general_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `formato`
--
ALTER TABLE `formato`
  MODIFY `id_formato` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `formato_log`
--
ALTER TABLE `formato_log`
  MODIFY `id_formato_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `funcionario`
--
ALTER TABLE `funcionario`
  MODIFY `id_funcionario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `funcionario_log`
--
ALTER TABLE `funcionario_log`
  MODIFY `id_funcionario_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `item_lista`
--
ALTER TABLE `item_lista`
  MODIFY `id_item_lista` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `item_lista_log`
--
ALTER TABLE `item_lista_log`
  MODIFY `id_item_lista_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `lista_chequeo`
--
ALTER TABLE `lista_chequeo`
  MODIFY `id_lista_chequeo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `lista_chequeo_log`
--
ALTER TABLE `lista_chequeo_log`
  MODIFY `id_lista_chequeo_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `notificacion_log`
--
ALTER TABLE `notificacion_log`
  MODIFY `id_notificacion_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `producto_virtual`
--
ALTER TABLE `producto_virtual`
  MODIFY `id_p_virtual` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `producto_virtual_log`
--
ALTER TABLE `producto_virtual_log`
  MODIFY `id_p_virtual_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `programa`
--
ALTER TABLE `programa`
  MODIFY `id_programa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `programa_log`
--
ALTER TABLE `programa_log`
  MODIFY `id_programa_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `rankin`
--
ALTER TABLE `rankin`
  MODIFY `id_rankin` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rankin_log`
--
ALTER TABLE `rankin_log`
  MODIFY `id_rankin_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `red_deconocimiento`
--
ALTER TABLE `red_deconocimiento`
  MODIFY `id_red` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `red_programa`
--
ALTER TABLE `red_programa`
  MODIFY `id_programa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `rol_funcionario`
--
ALTER TABLE `rol_funcionario`
  MODIFY `id_rol_funcionario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `rol_funcionario_log`
--
ALTER TABLE `rol_funcionario_log`
  MODIFY `id_rol_funcionario_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `rol_log`
--
ALTER TABLE `rol_log`
  MODIFY `id_rol_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tema`
--
ALTER TABLE `tema`
  MODIFY `id_tema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tema_log`
--
ALTER TABLE `tema_log`
  MODIFY `id_tema_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tipo_documento`
--
ALTER TABLE `tipo_documento`
  MODIFY `id_tipo_documento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_documento_log`
--
ALTER TABLE `tipo_documento_log`
  MODIFY `id_tipo_documento_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_estado`
--
ALTER TABLE `tipo_estado`
  MODIFY `id_tipo_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_estado_log`
--
ALTER TABLE `tipo_estado_log`
  MODIFY `id_tipo_estado_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_formato`
--
ALTER TABLE `tipo_formato`
  MODIFY `id_tipo_formato` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tipo_formato_log`
--
ALTER TABLE `tipo_formato_log`
  MODIFY `id_tipo_formato_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tipo_notificacion`
--
ALTER TABLE `tipo_notificacion`
  MODIFY `id_tipo_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_notificacion_log`
--
ALTER TABLE `tipo_notificacion_log`
  MODIFY `id_tipo_notificacion_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `version`
--
ALTER TABLE `version`
  MODIFY `id_version` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `version_log`
--
ALTER TABLE `version_log`
  MODIFY `id_version_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `voto`
--
ALTER TABLE `voto`
  MODIFY `id_voto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `voto_log`
--
ALTER TABLE `voto_log`
  MODIFY `id_voto_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `area_centro`
--
ALTER TABLE `area_centro`
  ADD CONSTRAINT `fk_area_02` FOREIGN KEY (`id_area`) REFERENCES `area` (`id_area`),
  ADD CONSTRAINT `fk_centro` FOREIGN KEY (`id_centro`) REFERENCES `centro` (`id_centro`);

--
-- Filtros para la tabla `autor`
--
ALTER TABLE `autor`
  ADD CONSTRAINT `fk_funcionario_02` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_version_01` FOREIGN KEY (`id_version`) REFERENCES `version` (`id_version`);

--
-- Filtros para la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD CONSTRAINT `fk_funcionario_08` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`);

--
-- Filtros para la tabla `centro`
--
ALTER TABLE `centro`
  ADD CONSTRAINT `fk_ciudad` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`);

--
-- Filtros para la tabla `comentario`
--
ALTER TABLE `comentario`
  ADD CONSTRAINT `fk_funcionario_03` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_version_02` FOREIGN KEY (`id_version`) REFERENCES `version` (`id_version`);

--
-- Filtros para la tabla `detalles_area`
--
ALTER TABLE `detalles_area`
  ADD CONSTRAINT `fk_area_01` FOREIGN KEY (`id_area`) REFERENCES `area` (`id_area`),
  ADD CONSTRAINT `fk_programa_02` FOREIGN KEY (`id_programa`) REFERENCES `programa` (`id_programa`);

--
-- Filtros para la tabla `detalles_categoria`
--
ALTER TABLE `detalles_categoria`
  ADD CONSTRAINT `fk_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`),
  ADD CONSTRAINT `fk_tema_03` FOREIGN KEY (`id_tema`) REFERENCES `tema` (`id_tema`);

--
-- Filtros para la tabla `detalles_evaluacion`
--
ALTER TABLE `detalles_evaluacion`
  ADD CONSTRAINT `fk_detalles_lista` FOREIGN KEY (`id_detalles_lista`) REFERENCES `detalles_lista` (`id_detalles_lista`),
  ADD CONSTRAINT `fk_evaluacion_general` FOREIGN KEY (`id_evaluacion_general`) REFERENCES `evaluacion_general` (`id_evaluacion_general`);

--
-- Filtros para la tabla `detalles_lista`
--
ALTER TABLE `detalles_lista`
  ADD CONSTRAINT `fk_item_lista` FOREIGN KEY (`id_item_lista`) REFERENCES `item_lista` (`id_item_lista`),
  ADD CONSTRAINT `fk_lista_chequeo_01` FOREIGN KEY (`id_lista_chequeo`) REFERENCES `lista_chequeo` (`id_lista_chequeo`);

--
-- Filtros para la tabla `detalles_notificacion`
--
ALTER TABLE `detalles_notificacion`
  ADD CONSTRAINT `fk_funcionario_07` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_notificacion` FOREIGN KEY (`id_notificacion`) REFERENCES `notificacion` (`id_notificacion`);

--
-- Filtros para la tabla `detalles_programa`
--
ALTER TABLE `detalles_programa`
  ADD CONSTRAINT `fk_programa_01` FOREIGN KEY (`id_programa`) REFERENCES `programa` (`id_programa`),
  ADD CONSTRAINT `fk_tema_02` FOREIGN KEY (`id_tema`) REFERENCES `tema` (`id_tema`);

--
-- Filtros para la tabla `detalles_tema`
--
ALTER TABLE `detalles_tema`
  ADD CONSTRAINT `fk_p_virtual_02` FOREIGN KEY (`id_p_virtual`) REFERENCES `producto_virtual` (`id_p_virtual`),
  ADD CONSTRAINT `fk_tema_01` FOREIGN KEY (`id_tema`) REFERENCES `tema` (`id_tema`);

--
-- Filtros para la tabla `estado`
--
ALTER TABLE `estado`
  ADD CONSTRAINT `fk_tipo_estado` FOREIGN KEY (`id_tipo_estado`) REFERENCES `tipo_estado` (`id_tipo_estado`);

--
-- Filtros para la tabla `evaluacion_general`
--
ALTER TABLE `evaluacion_general`
  ADD CONSTRAINT `fk_funcionario_05` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_lista_chequeo_02` FOREIGN KEY (`id_lista_chequeo`) REFERENCES `lista_chequeo` (`id_lista_chequeo`),
  ADD CONSTRAINT `fk_version_03` FOREIGN KEY (`id_version`) REFERENCES `version` (`id_version`);

--
-- Filtros para la tabla `formato`
--
ALTER TABLE `formato`
  ADD CONSTRAINT `fk_tipoformato` FOREIGN KEY (`id_tipo_formato`) REFERENCES `tipo_formato` (`id_tipo_formato`);

--
-- Filtros para la tabla `funcionario`
--
ALTER TABLE `funcionario`
  ADD CONSTRAINT `fk_area_centro` FOREIGN KEY (`id_area_centro`) REFERENCES `area_centro` (`id_area_centro`),
  ADD CONSTRAINT `fk_estado_02` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`),
  ADD CONSTRAINT `fk_tipo_documento` FOREIGN KEY (`id_tipo_documento`) REFERENCES `tipo_documento` (`id_tipo_documento`);

--
-- Filtros para la tabla `lista_chequeo`
--
ALTER TABLE `lista_chequeo`
  ADD CONSTRAINT `fk_funcionario_04` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`);

--
-- Filtros para la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD CONSTRAINT `fk_funcionario_06` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_tipo_notificacion` FOREIGN KEY (`id_tipo_notificacion`) REFERENCES `tipo_notificacion` (`id_tipo_notificacion`);

--
-- Filtros para la tabla `producto_virtual`
--
ALTER TABLE `producto_virtual`
  ADD CONSTRAINT `fk_formato` FOREIGN KEY (`id_formato`) REFERENCES `formato` (`id_formato`);

--
-- Filtros para la tabla `rankin`
--
ALTER TABLE `rankin`
  ADD CONSTRAINT `fk_version` FOREIGN KEY (`id_version`) REFERENCES `version` (`id_version`);

--
-- Filtros para la tabla `red_programa`
--
ALTER TABLE `red_programa`
  ADD CONSTRAINT `red_programa_ibfk_1` FOREIGN KEY (`id_programa`) REFERENCES `red_deconocimiento` (`id_red`);

--
-- Filtros para la tabla `rol_funcionario`
--
ALTER TABLE `rol_funcionario`
  ADD CONSTRAINT `fk_funcionario_01` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_rol_01` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`);

--
-- Filtros para la tabla `version`
--
ALTER TABLE `version`
  ADD CONSTRAINT `fk_estado_01` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`),
  ADD CONSTRAINT `fk_p_virtual_01` FOREIGN KEY (`id_p_virtual`) REFERENCES `producto_virtual` (`id_p_virtual`);

--
-- Filtros para la tabla `voto`
--
ALTER TABLE `voto`
  ADD CONSTRAINT `fk_funcionario_voto` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`),
  ADD CONSTRAINT `fk_rankin` FOREIGN KEY (`id_rankin`) REFERENCES `rankin` (`id_rankin`);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `event_actualizarpuesto` ON SCHEDULE EVERY 5 MINUTE STARTS '2017-05-24 18:00:00' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'actualizarpuesto' DO begin 
	call actualizarpuestorankin();
end$$

CREATE DEFINER=`root`@`localhost` EVENT `event_notificaciones` ON SCHEDULE EVERY 1 DAY STARTS '2017-03-09 18:00:00' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'notificaciones' DO begin 
	call time_limit ();
end$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
