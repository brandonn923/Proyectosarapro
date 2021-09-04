/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package VO;

/**
 *
 * @author FAMILIA NOVOA
 */
public class Reporte_AreaVO {
    String nom_area;
    String nom_centro;

    public Reporte_AreaVO() {
    }

    public Reporte_AreaVO(String nom_area, String nom_centro) {
        this.nom_area = nom_area;
        this.nom_centro = nom_centro;
    }

    public String getNom_area() {
        return nom_area;
    }

    public void setNom_area(String nom_area) {
        this.nom_area = nom_area;
    }

    public String getNom_centro() {
        return nom_centro;
    }

    public void setNom_centro(String nom_centro) {
        this.nom_centro = nom_centro;
    }
    
    
}
