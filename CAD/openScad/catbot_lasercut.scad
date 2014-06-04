/*
 * Catbot scad file for cnc cutting
 */


use <MCAD/involute_gears.scad>

/*
 * Variables 
 */ 

// GLOBALS
matTh                   = 3;            // material thickness, int


brktW                   = 40;           // top bracket width, int 
brktH                   = 20;           // top bracket height

srvHldTW                = 50;           // servo holder top width, int 
srvHldTH                = 20;           // servo holder top width, int 

// servo spec
servoHoleDiam           = 1;            // servo mounting hole diameter
servoPlankTh            = 2.25;         // thickness of the servo mounting extruded part, int 

// box 
boxTopSize                 = [110,110,matTh];


// box servo
boxServoOffset          = [-6.3,-6.3,-28];

//lasers
lzrHoleRadius           = 10.4;         // diameter of the laser, need tweaks, int 

// utils 
toothGap                = 0.1;          // reduced with of hole to be glue less assembled set to 0 to glue / solder , int 
circleFn                = 80;           // number of ark for a circle refine at will


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
 * innerRadius  : gear diameter (usually a bit smaller than the servo geared axis)
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
 * place circles in the corners with the given radius at chosen corners  
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
 * SERVO CONNECTOR GEAR  
 *
 * extruded shaft to make the servo axis hole 
 *
 * PARAMS  :
 * innerRadius    : inherited, int
 *
 */ 

module servoConnectorGear(innerRadius,height) {
    
    innerteeth=12;
    innerpitch = innerRadius/innerteeth*360;
    gear (
            number_of_teeth=innerteeth,
            pressure_angle=45,
            circular_pitch=innerpitch,
            gear_thickness = height+1,
            rim_thickness = height+1,
            hub_thickness = height+1,
            bore_diameter = 0);
    
}

/*
 * CONNECTOR TOOTH 
 *
 * extruded bewelled cube to connect two parts layed in top view. 
 *
 * PARAMS :
 * size         : tooth size, array
 * bewelSize    : used if you cast it in mdf allow 2 part to be assembled glueless
 * orientation  : 0 N,1 E,2 S,3 W
 * 
 */ 

 module cToothMod(size,bewelSize,orientation) {

    /*translate([0,(matTh/2)]) */rotate (orientation* -90) linear_extrude(height = size[2]) polygon(points=[[0,0],[size[0],0],[(size[0]+bewelSize),size[1]],[(0-bewelSize),size[1]]], paths=[[0,1,2,3]]);
 }

/*
 * SERVO EXTUDER
 *
 * shaped like a servo to have a simple extrusion 
 *
 * PARAMS :
 * size         : tooth size, array
 * 
 */ 

 module servoExtuder(noServo) {

    translate(boxServoOffset) 
    color([0, 0, 200, .9]) union(){
        // bottom 
        if(!noServo){
            cube(size=[23.5,12.6,16.4], center=false);
            translate([-4.65,0,16.3]) cube(size=[32.8,12.6,4], center=false);
        }
        translate([-38.35,0,19.3]) cube(size=[90,12.6,50], center=false);
    }
 }


/*
 * PARTS 
 * constructed parts laid on top view
 */ 


module _topBracketUp(gearHole) {
    // left part (servo side)
    translate([0,0,-matTh/2])difference(){
        // main plate
        translate([5 ,0,0])
            borderRadiusbox([brktW,brktH,matTh], 5,[1,1,0,0]);    
            //translate([26,0,2]) cube(size=[matTh*2-0.1,matTh*-0.1,matTh+4], center=true);
        // hole for _servoCircHorn

        if(gearHole){
            translate([0,0,-matTh/2])
                servoConnectorGear(2.5);
        }
        // hole for _LazerHolder
        translate([27,0,0])cube(size=[matTh-0.1,(matTh*2)-0.1,10], center=true);
        
    }
}

// hold the laser, front panel 
module _topBracketMiddle(){
        difference(){
            cube(size=[brktW,brktH,matTh], center=false);
            translate([(brktW/2),brktW/4,0]) cylinder(h=50, r=10.5/2, center=true, $fn=circleFn);

        }
        translate([brktW,brktH/2+(matTh),0]){cToothMod([2*matTh,matTh,matTh],0.1,1);};
        translate([0,brktH/2-(matTh),0]){cToothMod([2*matTh,matTh,matTh],0.1,3);};
}


// circle to hold the laser in place need rework when the new laser arrives
module _laserHolderClip(innerDiam,circleDiam) {
    difference(){
        cylinder(h=matTh, r=innerDiam/2+circleDiam, center=false, $fn=circleFn);
        translate([0,0,-1]) cylinder(h=matTh+10, r=lzrHoleRadius/2, center=false, $fn=circleFn);
    }
}


// hold the Y axis servo
module _servoHolder(withServoCableHole){
    difference(){
        translate([-14.2,0,0]) cube([50,20,matTh], center=true);
        translate([-17.2,-6.3,-3]) cube([23.5,12.6,10.4]);
        translate ([-19.2,0,0])cylinder(h=100, r=servoHoleDiam, center=true, $fn=circleFn);
        if(withServoCableHole){
            translate ([6,0,0])cylinder(h=100, r=3, center=true, $fn=circleFn);
        } else {
            translate ([8.3,0,0])cylinder(h=100, r=servoHoleDiam, center=true, $fn=circleFn);
        }
        translate ([-30,11-matTh/2,0]) cube(size=[matTh,matTh+2,20], center=true);
        translate ([-30,-1*(11-matTh/2),0]) cube(size=[matTh,matTh+2,20], center=true);
        
    }

    translate([-39.2,(-matTh/2)+4,-(matTh/2)]){cToothMod([matTh,matTh,matTh],0.1,3);};     
    translate([-39.2,(-matTh/2)-4,-(matTh/2)]){cToothMod([matTh,matTh,matTh],0.1,3);};     
    
}

// clips the sevo holders
module _servoHolderClip() {
    fullw=servoPlankTh+matTh*4;
    fullh=9;
    gap=0.2;
    linear_extrude(height=matTh){

    polygon(points=[[0,0],[fullw,0],
                    [fullw,fullh],[fullw-matTh,fullh],
                    [fullw-matTh-gap,matTh],[fullw-matTh*2+gap,matTh],
                    [fullw-matTh*2,fullh],[fullw-matTh*2,fullh],
                    [fullw-matTh*2-servoPlankTh,fullh],[fullw-matTh*2-servoPlankTh,fullh],
                    [fullw-matTh*2-servoPlankTh-gap,matTh],[fullw-matTh*3-servoPlankTh+gap,matTh],
                    [fullw-matTh*3-servoPlankTh,fullw-matTh],[0,fullw-matTh]

                    ], paths=[[0,1,2,3,4,5,6,7,8,9,10,11,12,13]]);
    }
    
}


// x axis servo mount + Y axis holder
module _bottomBracketTop(withServo){
    holeDiam = matTh-0.1;
    difference(){
        
        cylinder(h=matTh, r=39, center=true, $fn=circleFn);     // base cylinder
        translate([0,0,-matTh/2]) servoConnectorGear(2.5);      // servo hole
        translate([12.3,0,0]) union(){

        translate([0,4,0]) cube(size=[holeDiam , holeDiam , 40], center=true);
        translate([0,-4,0]) cube(size=[holeDiam , holeDiam , 40], center=true);
        translate([0-matTh-servoPlankTh,4,0]) cube(size=[holeDiam , holeDiam , 40], center=true);
        translate([0-matTh-servoPlankTh,-4,0]) cube(size=[holeDiam , holeDiam , 40], center=true);
        }
    }
    if(withServo){
        translate([-6.3,-6.3,-29]) rotate([0,0,0]) servo();
    }

}

module _fakeTopBox() {
    difference(){

         difference(){
            cube(size=boxTopSize, center=true);
            cylinder(h=matTh*2, r=40, center=true, $fn=circleFn);
            translate([(boxTopSize[0]/2-matTh*3),-(matTh-toothGap)/2,-10]) cube([matTh*2-toothGap,matTh-toothGap,20]);
            translate([(boxTopSize[0]/2-matTh*3),-((matTh-toothGap)/2+8),-10]) cube([matTh*2-toothGap,matTh-toothGap,20]);
            translate([(boxTopSize[0]/2-matTh*3),-((matTh-toothGap)/2-8),-10]) cube([matTh*2-toothGap,matTh-toothGap,20]);
            mirror([1]) translate([(boxTopSize[0]/2-matTh*3),-(matTh-toothGap)/2,-10]) cube([matTh*2-toothGap,matTh-toothGap,20]);
            mirror([1]) translate([(boxTopSize[0]/2-matTh*3),-((matTh-toothGap)/2+8),-10]) cube([matTh*2-toothGap,matTh-toothGap,20]);
            mirror([1]) translate([(boxTopSize[0]/2-matTh*3),-((matTh-toothGap)/2-8),-10]) cube([matTh*2-toothGap,matTh-toothGap,20]);
                
             
        }   
    }
}

// servo dummys 
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


/* bottom servo holder
 * 
 *
 * fix the bottom servo to the box 
 *
 * PARAMS :
 * height       : height of the vbox, int
 * depth        : depth of the holder bit, int
 * noServo      : with extruded servo, bool 
 * 
 */ 

// bottom servo holder

module _bottomServoHolder(height,depth,noServo) {
    difference(){
        translate([-height/2+matTh,-matTh/2,-depth- matTh/2]) cube(size=[height-(matTh*2),matTh,depth], center=false);
        translate([-44,0,-(depth/2)-depth+14]) cube(size=[60,20,40], center=true);
        translate([54,0,-(depth/2)-depth+14]) cube(size=[60,20,40], center=true);
        translate([0,0,-depth+33])servoExtuder(noServo);
        translate([36,0,-(depth/2)-depth+16]) cube(size=[matTh-0.1,20,40], center=true);
        translate([-33,0,-(depth/2)-depth+16]) cube(size=[matTh-0.1,20,40], center=true);
    }
        translate([(height/2)-6,0,0]) translate([-3,-(matTh/2)+matTh,-matTh/2]) rotate([0,270,90])cToothMod([2*matTh,matTh,matTh],0.1,1);
        mirror([1,0,0]) translate([(height/2)-6,0,0]) translate([-3,-(matTh/2)+matTh,-matTh/2]) rotate([0,270,90])cToothMod([2*matTh,matTh,matTh],0.1,1);
        //translate([0,0,0])servoExtuder(noServo);

}

/*
 * MODEL 
 * constructed parts placed to test the model
 */

/*
 * TOP BRACKET 
 */
module topBracket() {

    // top left 
    _topBracketUp(true); // left part with hole for the Y servo

    // top right
    translate([0,0,40+matTh]) _topBracketUp();

    // top middle
    translate ([31-6.5,-brktH/2,40+(matTh/2)]) rotate([0,90,0]) _topBracketMiddle();
}

/*
 * BOTTOM BRACKET 
 */
module bottomBracket(withServo) {
    // lower servo holder
    translate([0,0,9.2]) _servoHolder(true);

    // upper servo holder
    translate([0,0,9.2+servoPlankTh+matTh]) _servoHolder();

    // servo clips
    translate([-31.5,-10,19.2]) rotate([0,90,0]) _servoHolderClip();

    // bottomBracket
    if(withServo){   
        translate([-40,0,(brktW+matTh)/2]) rotate([0,90,0]) _bottomBracketTop();
    }else{
        translate([-40,0,(brktW+matTh)/2]) rotate([0,90,0]) _bottomBracketTop(true);
        
    }
}



/* 
 * arduinoboxTop
 */

module arduinoboxTop(withServo) {
    if (withServo){
        translate(boxServoOffset) rotate([0,0,0]) servo();
    }
    // fake top box
     _fakeTopBox();

    _bottomServoHolder(110,33);
    translate([0,8,0]) _bottomServoHolder(110,33,true);
    translate([0,-8,0]) _bottomServoHolder(110,33,true);
    
}
arduinoboxTop(true);
// overview of the module for display and tests
module overview(withServo) {

    // offset and center the servo  dummy Y
    if(withServo){
        translate([6.3,-6.3,29]) rotate([0,180,0]) servo();
    }

    rotate([0,0,80])topBracket();
    if (withServo){
        bottomBracket(true);
    } else {
        bottomBracket();
    }
    
}

translate([21.5,0,41]) rotate([0,-90]) overview(true);

/*
 * PROJECTIONS 
 * use them if you have time, the final render ... may kill your computer :(
 */ 
/*


projection(cut = true) _topBracketUp(false ,true);
projection(cut = true) translate([-46,0,0]) _topBracketUp();
projection(cut = true) translate ([-12.6,-2*brktH+6,0]) _topBracketMiddle();
projection(cut = true) translate ([-25.6,-2*brktH+16,0]) _laserHolderClip(lzrHoleRadius,2);  
projection(cut = true) translate ([-40.6,-2*brktH+16,0]) _laserHolderClip(lzrHoleRadius,2);
projection(cut = true) translate ([-12.6,-3*brktH+12,0]) _servoHolder(true);
projection(cut = true) translate ([-12.6,-4*brktH+10,0]) _servoHolder();
projection(cut = true) translate([-75.5,-2,0]) _servoHolderClip(true);
projection(cut = true) translate([-75.5,-15,0]) _servoHolderClip();
projection(cut = true) translate ([15.6,-4*brktH+12,0])  rotate(90) _bottomBracketTop();

*/

/*
 * Junk 
 * alway nice to have some junk part around 
 */


/*
// array of gears for testing
for ( i = [0 : 10] )
{
    translate([gearDist*i,0,0]){

        projection(cut = true) servoCircHorn(10,gearInitSize - 0.1*i);
    }
    

}
*/