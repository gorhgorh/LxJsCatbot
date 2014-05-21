/*
 * Catbot scad file for cnc cutting
 */


use <MCAD/involute_gears.scad>

/*
 * Variables 
 */ 

matTh = 3; 				// material thickness
gearInitSize = 2.5; 	// TO DO : CLEANUP 
gearDist = 21; 			// TO DO : CLEANUP




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
 * PARAMS  		:
 * diam       	: outer gear Diameter 
 * innerRadius 	: gear diameter (usuasly a bit smaller than the servo geared axis)
 */	

module servoCircHorn(diam,innerRadius,gearHeight) {
	rotate([0,0,-4]) difference() {
		cylinder(h=matTh, r=diam, center=true, $fn=40);
		translate([0,0,-1*matTh +1])
			servoConnectorGear(innerRadius,matTh);
	}
}


/*
 * BORDER  RADIUS BOX MODULE  
 *
 * place circles in the corners, with the given radius, to have or not 
 * rounded corners and array is used for 0 no corner 1 for corners 
 * css style (top right, bottom right, bottom left, top left )
 *
 * PARAMS  :
 * size    : array [X,Y,Z]
 * radius  : the round corner radius
 * corners : 0 no corner 1 for corners 
 * css style (top right, bottom right, bottom left, top left )
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
		circle(r=radius);
	} else {
		translate([(-x/2), (y/2), 0])
		square(radius,true);
	}

	// top right
	if (corners[0] == 1 ){
		translate([(x/2)-(radius/2), (y/2)-(radius/2), 0])
		circle(r=radius);	
	} else {
		translate([(x/2), (y/2), 0])
		square(radius,true);
	}
	

	// bottom right
	if(corners[1] == 1) {
		translate([(x/2)-(radius/2), (-y/2)+(radius/2), 0])
		circle(r=radius);
	} else {
		translate([(x/2), (-y/2), 0])
		square(radius,true);
	}
	// bottom left 
	if(corners[2] == 1) {

		translate([(-x/2)+(radius/2), (-y/2)+(radius/2), 0])
		circle(r=radius);
	} else {
		translate([(-x/2), (-y/2), 0])
 		square(radius,true);
	}
	}
}



borderRadiusbox([40,20,matTh], 5,[1,1,0,0]);
/*
// array of gears for testing
for ( i = [0 : 10] )
{
    translate([gearDist*i,0,0]){

		projection(cut = true) servoCircHorn(10,gearInitSize - 0.1*i);
    }
	

}
*/

//projection(cut = true)
servoCircHorn(10,2.5);




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

//cylinder(h=matTh, r=10, center=true, $fn=20);

//cube(size=[10,10,matTh], center=true);



module footBar(length,width,height) {
	difference(){
		union(){
			translate([-length/2,-width/2,0]) cube([length,width,height]);
			translate([-length/2,0,0]) cylinder(r=width/2,h=height,$fn=45);
			translate([length/2,0,0]) cylinder(r=width/2,h=height,$fn=45);
		}
		translate([-length/2,0,0])cylinder(r=1, h=10, center=true,$fn=45);
		translate([length/2,0,0])cylinder(r=1, h=10, center=true,$fn=45);
		translate([-length/4,0,0])cylinder(r=1, h=10, center=true,$fn=45);
		translate([length/4,0,0])cylinder(r=1, h=10, center=true,$fn=45);
	}
}

module foot(withServo) {
	footBar(100,10,3);
	rotate([0,0,90]) footBar(100,10,3);
	translate([-5.5,0,2]) cageUp(withServo);
	translate([-18,-8,0]) cube([25,16,3]);
}


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

module overview() {
	foot(true);
	translate([0,0,38]) swing(true);
	translate([0,0,43]) arm(true, true);
	translate([49.5,0,43]) arm(true, false);
	translate([99,0,43]) {
		armFront(true);

	}
}




//servoConnectorGear(2.6);

// shows the complete thing

//overview();