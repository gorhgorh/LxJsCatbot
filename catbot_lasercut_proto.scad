/*
 * Catbot scad file for cnc cutting
 */


use <MCAD/involute_gears.scad>

/*
 * Variables 
 */ 

// GLOBALS
matTh                   = 3;            // material thickness, int
circlarHornDiam         = 20;
circleFn                = 80;

gearInitSize            = 2.5;          // TO DO : CLEANUP 
gearDist                = 21;           // TO DO : CLEANUP

/*
 * ELEMENTS 
 */

/*
 * CIRCULAR SERVO HORN MODULE  
 *
 * place circles in the corners, with the given radius, to have or not 
 * rounded corners and array is used for 0 no corner 1 for corners 
 * css style (top right, bottom right, bottom left, top left )
 *
 * PARAMS       :
 * diam         : outer gear Diameter 
 * innerRadius  : gear diameter (usuasly a bit smaller than the servo geared axis)
 */ 

module servoCircHorn(diam,innerRadius,gearHeight) {
    rotate([0,0,-4]) difference() {
        cylinder(h=matTh, r=diam, center=true, $fn=circleFn);
        translate([0,0,-1*matTh +1])
            servoConnectorGear(innerRadius,matTh);
    }
}


/*
 * BORDER  RADIUS BOX MODULE  
 *
 * place circles in the corners with the given radius at choosen corners  
 *
 * PARAMS  :
 * size    : module size [X,Y,Z],  array
 * radius  : the round corner radius, int
 * corners : 0 no corner 1 for corners (top right, bottom right, bottom left, top left ) , array
 * css style 
 *
 */ 

module borderRadiusbox(size, radius,corners)
{
    x = size[0];
    y = size[1];
    z = size[2];

    linear_extrude(height=z)
    hull(){
        
        // top left
        if(corners[3] == 1) {
            translate([(-x/2)+(radius/2), (y/2)-(radius/2), 0])
            circle(r=radius, $fn=circleFn);
        } else {
            translate([(-x/2), (y/2), 0])
            square(radius,true);
        }

        // top right
        if (corners[0] == 1 ){
            translate([(x/2)-(radius/2), (y/2)-(radius/2), 0])
            circle(r=radius, $fn=circleFn);   
        } else {
            translate([(x/2), (y/2), 0])
            square(radius,true);
        }
        

        // bottom right
        if(corners[1] == 1) {
            translate([(x/2)-(radius/2), (-y/2)+(radius/2), 0])
            circle(r=radius, $fn=circleFn);
        } else {
            translate([(x/2), (-y/2), 0])
            square(radius,true);
        }
        // bottom left 
        if(corners[2] == 1) {

            translate([(-x/2)+(radius/2), (-y/2)+(radius/2), 0])
            circle(r=radius, $fn=circleFn);
        } else {
            translate([(-x/2), (-y/2), 0])
            square(radius,true);
        }
    }
}

/*
 * BORDER  servoConnectorGear  
 *
 * extruded shapt to make the servo axis hole 
 *
 * PARAMS  :
 * innerRadius    : inherited, int
 *
 */ 

module servoConnectorGear(innerRadius) {
    
    innerteeth=12;
    innerpitch = innerRadius/innerteeth*360;

        
            gear (number_of_teeth=innerteeth,
                pressure_angle=45,
                circular_pitch=innerpitch,
           gear_thickness = matTh+1,
            rim_thickness = matTh+1,
            hub_thickness = matTh+1,
                bore_diameter = 0);
    
}

/*
 * PARTS 
 * constructed parts layed on top view
 */ 

module _topBracketUp() {
    // left part (servo side)
    translate([0,0,-matTh/2])difference(){
        // main plate
        translate([20-circlarHornDiam/2 ,0,0])
            borderRadiusbox([40,20,matTh], 5,[1,1,0,0]);    
        // hole for _servoCircHorn
        translate([0,0,-matTh/2])
            cylinder(h=matTh+4, r=circlarHornDiam/2+.2, center=false, $fn=circleFn);
        // hole for _LazerHolder
        translate([20,0,2])
            cube(size=[matTh,matTh,matTh+4], center=true);
        
    }
}

// servo dummy 
module servo() {
    color("LightBlue", 0.5) {
        cube([23.5,12.6,16.4]);
        translate([-4.65,0,16.3]) difference() {
            cube([32.8,12.6,2]);
            translate([2.65,6.3,-0.1]) cylinder(r=1,h=3,$fn=45);
            translate([32.8-2.65,6.3,-0.1]) cylinder(r=1,h=3,$fn=45);
        }
        translate([0,0,18.2]) cube([23.5,12.6,4.4]);
        translate([6.3,6.3,22.5]) cylinder(r=6.3,h=4.1,$fn=45);
        translate([6.3,6.3,26.5]) cylinder(r=2.25,h=2.8,$fn=45);
    }
}

/*
 * MODEL 
 * constructed parts placed to test the model
 */

// offset and center the servo dummy
//translate([11.5,6.3,1]) rotate([0,0,180]) servo();


_topBracketUp();

servoCircHorn(circlarHornDiam/2,2.5);

/*
 * PROJECTIONS 
 * use them if you have time, the final render ... may kill your computer :(
 */ 

//projection(cut = true)
//servoCircHorn(circlarHornDiam/2,2.5);


/*
// array of gears for testing
for ( i = [0 : 10] )
{
    translate([gearDist*i,0,0]){

        projection(cut = true) servoCircHorn(10,gearInitSize - 0.1*i);
    }
    

}
*/