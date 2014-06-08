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
boxTopSize              = [110,110,matTh];

// bottom bracket
bottomBrktHoldDist      = -16.5;

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
 * innerRadius      : gear radius usualy a bit smaller than the servo's ones, int
 * height           : height of the extruded part
 *
 */

module servoConnectorGear(innerRadius,height) {

    innerteeth=12;
    innerpitch = innerRadius/innerteeth*360;
    gear (  number_of_teeth=innerteeth,
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
    rotate (orientation* -90)
        linear_extrude(height = size[2])
            polygon(points=[
                [0,0],[size[0],0],
                [(size[0]+bewelSize),size[1]],[(0-bewelSize),size[1]]],
                paths=[[0,1,2,3]]
            );
 }

 /*
 * TOOTH 2.0
 * back from the future, in 3d (now 2 cubes hulled to avoid mixing 2D/ 3d in unions)
 *
 * PARAMS :
 * s            : tooth size, array
 * bs           : used if you cast it in mdf allow 2 part to be assembled glueless
 * o            : 0 N,1 E,2 S,3 W
 *
 */

module tooth2(s,bs,o) {
    rotate (orientation* -90) difference(){
        cube(size=[s], center=false);
        //cube(size=[], center=false);
    }
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

 module servoExtuder(noServo=false) {
    translate(boxServoOffset) color([0, 0, 200, .9]) union(){
        // bottom
        translate([-38.35,0,19.3]) cube(size=[90,12.7,50], center=false);
        if(!noServo){
            cube(size=[23.5,12.6,16.4], center=false);
            translate([-4.65,0,16.3]) cube(size=[32.8,12.6,4], center=false);
            translate([0,0,3]) rotate([0,90,90]) cylinder(h=12.6, r=3, center=false, $fn=circleFn);
        }
    }
 }

/*
 * PARTS
 * constructed parts laid on top view
 */

module _topBracketUp(gearHole=true) {
    // left part (servo side)
    translate([0,0,-matTh/2])difference(){
        // main plate
        translate([5 ,0,0])
            borderRadiusbox([brktW,brktH,matTh], 5,[1,1,1,1]);

        if(gearHole){
            translate([0,0,-matTh/2])
                servoConnectorGear(2.5);
        }

        // hole for _LazerHolder
        translate([27,0,0])
            cube(size=[matTh-0.1,(matTh*2)-0.1,10], center=true);
    }
}

/**
 * top bracket v2
 * gearHole = with or without gearhole, boolean
 */

module _topBracketUp2(gearHole=true) {
    // left part (servo side)
    translate([0,0,-matTh/2])difference(){
        // main plate
        translate([5 ,0,0])
            borderRadiusbox([brktW,brktH,matTh], 5,[1,1,1,1]);
        // 2 holes for laser holeder
        translate([7,0,0]) union(){
            cube(size=[matTh-toothGap,2*matTh-toothGap,10], center=true);
            translate([6,0,0])cube(size=[matTh-toothGap,2*matTh-toothGap,10], center=true);
        }
        // hole gor the servo gear
        if(gearHole){
            translate([0,0,-matTh/2])
                servoConnectorGear(2.5);
        }
    }
}




module _LazerHolder2(w=10.6,h=6,rO=7,rI=5.1) {
    translate([0,-w/2,0]){
        difference(){
            union(){
                cube(size=[matTh,w,h], center=false);
                rotate([0,90,0]) translate([-6,w/2,0]) cylinder(h=matTh, r=rO, center=false, $fn=20);
            }
            rotate([0,90,0])
                translate([-6,w/2,0-4])
                    cylinder(h=10, r=rI, center=false, $fn=20);
        }

        // 2d part out of the union / difference
        translate([matTh,w/2-3,-matTh])
            rotate([0,0,0])
                cToothMod([2*matTh,matTh,matTh],0.1,3);
    }

}

// TODO : make it higher, put a gap to hold the servo
// hold the Y axis servo
module _servoHolder(withServoCableHole){
    difference(){
        translate([-14.2,0,0])
            cube([50,20,matTh], center=true);
        translate([-17.2,-6.3,-3])
            cube([23.5,12.6,10.4]);
        //translate ([-19.2,0,0])cylinder(h=100, r=servoHoleDiam, center=true, $fn=circleFn);
        if(withServoCableHole){
            translate ([6,0,0])cylinder(h=100, r=3, center=true, $fn=circleFn);
        }
        //else { translate ([8.3,0,0])cylinder(h=100, r=servoHoleDiam, center=true, $fn=circleFn);}
        // lower gap holes
        translate ([-30,11-matTh/2,0])
            cube(size=[matTh,matTh+2,20], center=true);
        translate ([-30,-1*(11-matTh/2),0])
            cube(size=[matTh,matTh+2,20], center=true);
    }

    //  connectors for assembly
    translate([-39.2,(-matTh/2)+4,-(matTh/2)])
        cToothMod([matTh,matTh,matTh],0.1,3);
    translate([-39.2,(-matTh/2)-4,-(matTh/2)])
        cToothMod([matTh,matTh,matTh],0.1,3);
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
        translate([bottomBrktHoldDist,0,0])                     // < offset for the
            union(){                                            // top bracket holes
                translate([0,4,0])
                    cube(size=[holeDiam , holeDiam , 40], center=true);
                translate([0,-4,0])
                    cube(size=[holeDiam , holeDiam , 40], center=true);
                translate([0-matTh-servoPlankTh,4,0])
                    cube(size=[holeDiam , holeDiam , 40], center=true);
                translate([0-matTh-servoPlankTh,-4,0])
                    cube(size=[holeDiam , holeDiam , 40], center=true);
            }
    }
    if(withServo){
        translate([-6.3,-6.3,-29]) rotate([0,0,0])
            servo();
    }
}

/*
 * BOTTOM BRACKET
 */
module bottomBracket(withServo) {
    translate([0,0,21.5-bottomBrktHoldDist]) union(){
        // upper servo holder
        translate([0,0,0]) _servoHolder();
        // lower servo holder
        translate([0,0,servoPlankTh+matTh]) _servoHolder(true);
    }

    // servo clips
    translate([-31.5,-10,-bottomBrktHoldDist+31])  rotate([0,90,0]) _servoHolderClip();

    // bottomBracket
    if(withServo){
        translate([-40,0,(brktW+matTh)/2]) rotate([0,90,0]) _bottomBracketTop();
    }else{
        translate([-40,0,(brktW+matTh)/2]) rotate([0,90,0]) _bottomBracketTop(true);

    }
}

// provide holes for the svg box
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
        translate([-4.65,0,16.3])
        difference() {
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

module _bottomServoHolder(h,d,noServo) {
    difference(){
        // base cube
        translate([-h/2+matTh,-matTh/2,-d- matTh/2])
            cube(size=[h-(matTh*2),matTh,d], center=false);
        // back extrution
        translate([-44,0,-(d/2)-d+14]) cube(size=[60,20,40], center=true);
        // top extruder
        translate([0,0,-d+33]) servoExtuder(noServo);
        // front gap hole
        translate([36,0,-(d/2)-d+50]) cube(size=[matTh-0.1,20,40], center=true);
        // back gap hole
        translate([-33,0,-(d/2)-d+18]) cube(size=[matTh-0.1,20,40], center=true);
    }
        translate([(h/2)-6,0,0]) translate([-3,-(matTh/2)+matTh,-matTh/2]) rotate([0,270,90])cToothMod([2*matTh,matTh,matTh],0.1,1);
        mirror([1,0,0]) translate([(h/2)-6,0,0]) translate([-3,-(matTh/2)+matTh,-matTh/2]) rotate([0,270,90])cToothMod([2*matTh,matTh,matTh],0.1,1);


}

/*
 * bottomServoHolderClip
 * hold the 3 box servo holder, gap are centered
 *
 * PARAMS :
 * w            : width of the holder, int
 * h            : height, int
 * gC           : Gap Count, number of gaps, int
 * gW           : gap width, int
 * gS           : gap Spacing distance between gap CENTERS, int
 * gH           : gap height, distance between the begining of the
 *                gap to the outer edge,int
 *
 */

module bottomServoHolderClip(w=20,gC=3,gW=2.9,gS=7.9,gH=6) {
    //w=gC*gS+matTh*2;

    h= (gC*gS)+matTh;
    difference(){
        cube(size=[w,h,matTh], center=false);
        for ( i = [0 : gC-1] )
        {
            translate([w/2+gH,gS*(i)+1.8*matTh,matTh/2]) cube(size=[w,gW,2*matTh], center=true);

        }
    }
}

/*
 * MODEL
 * constructed parts placed to test the model
 */

/*
 * TOP BRACKET
 */

module topBracketV2() {

    // top left
    _topBracketUp2(true); // left part with hole for the Y servo
        translate([7-matTh/2,0,matTh/2+4])
     translate([0,0,-7.0]) mirror([0,0,1]) union(){
        translate([0,0,0]) rotate([0,0,0])_LazerHolder2(10,6,7,5);
        //_LazerHolder2(10,6,4);
        //translate([6,0,0]) _LazerHolder2(10,6,4);
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


// overview of the module for display and tests
module overview(withServo=true) {

    // offset and center the servo  dummy Y
    translate([0,00,12.4+-bottomBrktHoldDist]) union(){


        if(withServo){
            translate([6.3,-6.3,29]) rotate([0,180,0]) servo();
        }
        rotate([0,0,180])topBracketV2();
    }
        bottomBracket(withServo);
}

module arduinoboxTop(withServo=true) {
    if (withServo){
        translate(boxServoOffset) rotate([0,0,0]) servo();
    }
    // fake top box
     _fakeTopBox();

    _bottomServoHolder(110,33);
    translate([0,8,0]) _bottomServoHolder(110,33,true);
    translate([0,-8,0]) _bottomServoHolder(110,33,true);

}

translate([0,0,-18]) arduinoboxTop();
translate([21.5,0,41]) rotate([0,-90]) overview();

/*
 * PROJECTIONS
 * use them if you have time, the final render ... may kill your computer :(
 */

module proj() {

translate([-47,50,0]) _topBracketUp2(true);
translate ([-25.6,-2*brktH+16,1]) rotate([0,90,0]) _LazerHolder2();
translate ([-6.6,-2*brktH+16,1]) rotate([0,90,0]) _LazerHolder2();
translate ([-12.6,-3*brktH+12,0]) _servoHolder(true);
translate ([-12.6,-4*brktH+10,0]) _servoHolder();
translate([-75.5,-2,0]) _servoHolderClip(true);
translate([-75.5,-15,0]) _servoHolderClip();
translate ([60.6,-4*brktH+12,0])  rotate(90) _bottomBracketTop();

translate ([160.6,-4*brktH+12,0]) _fakeTopBox();

translate ([160.6,20,0]) rotate([90,0,0]) _bottomServoHolder(110,33);
translate ([160.6,70,0]) rotate([90,0,0]) _bottomServoHolder(110,33,true);
translate ([160.6,120,0]) rotate([90,0,0]) _bottomServoHolder(110,33,true);

translate ([25.6,60,0])bottomServoHolderClip();
translate ([50.6,60,0])bottomServoHolderClip();
}

//projection(cut=false)
//proj();









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
