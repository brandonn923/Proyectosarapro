/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package VO;

/**
 *
 * @author Isaac
 */
public class FuncionarioVO {
 
    String nombre;
    String apellido;
    int tipoUsuario;
    String tipoIdenti;
    String numeroIdentificacion;
    String email;
    String centroFormacion;
    String reddeconocimiento;
    String ipSena;
    String cargo;
    String clave;

    public FuncionarioVO() {
    }

    public FuncionarioVO(String nombre, String apellido, int tipoUsuario, String tipoIdenti, String numeroIdentificacion, String email, String centroFormacion, String reddeconocimiento, String ipSena, String cargo, String clave) {
        this.nombre = nombre;
        this.apellido = apellido;
        this.tipoUsuario = tipoUsuario;
        this.tipoIdenti = tipoIdenti;
        this.numeroIdentificacion = numeroIdentificacion;
        this.email = email;
        this.centroFormacion = centroFormacion;
        this.reddeconocimiento = reddeconocimiento;
        this.ipSena = ipSena;
        this.cargo = cargo;
        this.clave = clave;
    }
    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public int getTipoUsuario() {
        return tipoUsuario;
    }

    public void setTipoUsuario(int tipoUsuario) {
        this.tipoUsuario = tipoUsuario;
    }

   

    public String getTipoIdenti() {
        return tipoIdenti;
    }

    public void setTipoIdenti(String tipoIdenti) {
        this.tipoIdenti = tipoIdenti;
    }

    public String getNumeroIdentificacion() {
        return numeroIdentificacion;
    }

    public void setNumeroIdentificacion(String numeroIdentificacion) {
        this.numeroIdentificacion = numeroIdentificacion;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCentroFormacion() {
        return centroFormacion;
    }

    public void setCentroFormacion(String centroFormacion) {
        this.centroFormacion = centroFormacion;
    }

    public String getReddeconocimiento() {
        return reddeconocimiento;
    }

    public void setReddeconocimiento(String reddeconocimiento) {
        this.reddeconocimiento = reddeconocimiento;
    }

    public String getIpSena() {
        return ipSena;
    }

    public void setIpSena(String ipSena) {
        this.ipSena = ipSena;
    }

    public String getCargo() {
        return cargo;
    }

    public void setCargo(String cargo) {
        this.cargo = cargo;
    }

    public String getClave() {
        return clave;
    }

    public void setClave(String clave) {
        this.clave = clave;
    }
    
    
    
    
}
