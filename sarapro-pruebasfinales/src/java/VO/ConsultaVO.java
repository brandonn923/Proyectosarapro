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
public class ConsultaVO {
    
     String titulo;
     String autor;
     String ciudad;
     String centro;
     String area;
     String palabraclave;
     String categoria;

    public ConsultaVO() {
    }

    public ConsultaVO(String titulo, String autor) {
        this.titulo = titulo;
        this.autor = autor;
    }
    
    public ConsultaVO(String titulo, String autor, String ciudad, String centro, String area, String palabraclave, String categoria) {
        this.titulo = titulo;
        this.autor = autor;
        this.ciudad = ciudad;
        this.centro = centro;
        this.area = area;
        this.palabraclave = palabraclave;
        this.categoria = categoria;
    }
    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        this.autor = autor;
    }

    public String getCiudad() {
        return ciudad;
    }

    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }

    public String getCentro() {
        return centro;
    }

    public void setCentro(String centro) {
        this.centro = centro;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getPalabraclave() {
        return palabraclave;
    }

    public void setPalabraclave(String palabraclave) {
        this.palabraclave = palabraclave;
    }

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }
                   
    
    
    
}
