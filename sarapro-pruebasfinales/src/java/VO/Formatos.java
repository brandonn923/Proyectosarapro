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
public class Formatos {
 
    int id_tipo_formato;
    String nom_tipo_formato;

    public Formatos() {
    }

    public Formatos(int id_tipo_formato, String nom_tipo_formato) {
        this.id_tipo_formato = id_tipo_formato;
        this.nom_tipo_formato = nom_tipo_formato;
    }

    public int getId_tipo_formato() {
        return id_tipo_formato;
    }

    public void setId_tipo_formato(int id_tipo_formato) {
        this.id_tipo_formato = id_tipo_formato;
    }

    public String getNom_tipo_formato() {
        return nom_tipo_formato;
    }

    public void setNom_tipo_formato(String nom_tipo_formato) {
        this.nom_tipo_formato = nom_tipo_formato;
    }
}
