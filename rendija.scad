$fa = 1;
$fs = 0.4;

//import("viejo/rendija-fija.stl");
  
module base() {
  difference() {
    cylinder(r=45, h=4.8);
    // hueco     
    translate([0,-25,-5])
      cube([10,50,10]);
    // tornillos
    for(a=[-30,30,120,240])
      rotate(a+0)
        translate([36,0,0])
          cylinder(d=3.6,h=10,center=true);
    // guía cubo
    difference(){
      translate([29.5,-6.5,4.8])
        guia_cubo(-tolj,16,4.84,-0.02);  
      cylinder(r=45, h=0.9);
    }
  }
}

module pared_fija(largo,ancho1,ancho2,alto) {  
  rotate([90,0,0])
  linear_extrude(largo,center=true)
    polygon([[0,0],[-ancho1,0],
             [-ancho2,alto],[0,alto]]);
}

module guia(alto,largo,ancho,alfa){
  translate([0,0,4.8])
  rotate([90,0,90])
  let(ancho2=ancho+2*alto/tan(alfa))
    linear_extrude(largo)
      polygon([[0,0],[0,alto],
               [ancho2/2,alto],[ancho/2,0]]);
}

module rendija_fija () {
  base();
  pared_fija(76,11,3,21);
  translate([0,-38,0])
    guia(4.8,18,10,alfa);  
  translate([0,38,0])  
  mirror([0,1,0])
    guia(4.8,18,10,alfa);
}

module rendija_movil() {    
  let(largo=76-10,
      delta=2*4.8/tan(alfa),
      l1=largo/2-tolh,
      l2=(largo-delta)/2-tolh)
  difference () {
    union(){
      // pared
      translate([0,-largo/2+delta/2+tolh,0]) 
        cube([5,largo-delta-2*tolh,16.2]);
      // base
      rotate([0,90,0])
        linear_extrude(15.5)
          polygon([[0,-l1],[-4.8,-l2],[-4.8,l2],[0,l1]]);
      // pared tornillo
      translate([0,-25,0])                 
        cube([14,50,16.2]);        
      // tabiques      
      translate([1,22,0])
        cube([11,3,16.2]);
      translate([1,-25,0])
        cube([11,3,16.2]);
    }
  // agujero interno
  translate([5,-7,3])
    cube([5,14,20]);
  // agujero tornillo
  translate([9,0,10])
    rotate([0,90,0])
      cylinder(h=6,d=5);
  translate([9,-2.5,10])
    cube([6,5,20]);
  // agujero elástico
  translate([12.5,-25.5,4.8+.6])
      cube([2,17,15]);
  translate([12.5,25.5-17,4.8+.6])
      cube([2,17,15]);
    
  }
}

alfa=55;
tolh=0.4; // holgado
tolj=0.3;  // justo

module cubo () {  
  difference() {    
    union(){
      cube([14,13,16.2]);
      guia_cubo(0,14,4.8,0);  
    }
    translate([4.5,-3,5])
      cube([5,20,9.9]);
    translate([-3,13/2,10])
      rotate([0,90,0])
        cylinder(h=20,d=5);
    translate([5,5,-15-4.8+1.2])
      cube([30,30,30],center=true);
  }   
}

module guia_cubo(tol,ancho,alto,z){
  let(largo=13,
      delta=2*alto/tan(alfa),
      l1=largo/2-tol,
      l2=(largo+delta)/2-tol)
  translate([ancho,6.5,-z])
  rotate([0,-90,0])
  linear_extrude(ancho)
    polygon([[0,-l1],[-alto,-l2],[-alto,l2],[0,l1]]);
}

module todo(){
  rendija_fija();
  translate([0,0,4.8])  color("cyan") rendija_movil();
  translate([30,-6.5,4.8]) color("cyan") cubo();
  translate([20.1,0,10.5]) color("blue") elastico(2);
}

module elastico(ancho) {
  module cintas() {
    linear_extrude(10.5)
      polygon(concat(
          [for (t=[0:.1:1]) 
            bezier2([8+ancho,-6.5],[8.5,-25],[0,-39],t)],
          [[0,-35+ancho]],
          [for (t=[1:-.1:0]) 
            bezier2([8,-6.5],[8.5,-18],[0,-39+ancho*1.5],t)]
          ));
    linear_extrude(10.5)
      polygon(concat(
          [for (t=[0:.1:1]) 
            bezier2([-7.5,-25],[-6,-33],[0,-39],t)],
          [[0,-39+ancho*1.5]],
          [for (t=[1:-.1:0]) 
            bezier2([-7.5+ancho,-25],[-5,-32],[0,-39+ancho*1.5],t)]
          ));        
      }  
  difference () {
    union(){
      translate([8,-6.5,0])
        cube([ancho,13,10.5]);
      translate([-7.5,-25,0])
        cube([ancho,15,10.5]);
      translate([-7.5,25-15,0])
        cube([ancho,15,10.5]);
      cintas();
      mirror([0,1,0])
          cintas();
    }
    translate([-3,0,4.3])
      rotate([0,90,0])
        cylinder(h=20,d=6.5); 
  }
}

//translate([20.1,0,9]) color("blue") elastico(1.5);
//rendija_fija();
//rendija_movil();
//translate([30,-6.5,4.8]) color("cyan") cubo();
cubo();
//todo();
//elastico(2);

function bezier2(p0,p1,p2,t) =
  (1-t)^2*p0 + 2*t*(1-t)*p1 + t^2*p2;

function bezier3(p0,p1,p2,p3,t) =
  (1-t)^3*p0 + 3*t*(1-t)^2*p1 + 3*t*t*(1-t)*p2 + t^3*p3;
