$fn=100;

//name of stl file you want to import
//to stack
headband_file="Prusa_RC3_PETG_5mm.stl";
number_of_headbands = 2;
headband_height_in_mm = 5;
layer_height_between_headbands=0.40;

//Adjustments x,y,z to nudge the file 
//to center
adjust_headband_loc_x = 7.8;
adjust_headband_loc_y = 0;
adjust_headband_loc_z = 0;

//Support variables
collumn_thickness=1.2;
circle_support_size=0.6;
column_support_bridge=1.5;
column_brim_height=0.6;
column_brim_thickness=6.0;
column_front_brim_offset=[-29.54,67.55];
column_side_brim_offset=[-93,13.9];
support_locations=[
                    [86.25,-68,0],//inner edge
                    [90.95,7.2,23], //outer edge
                    [0,27.2,90], //center inner band
                    [84.5,-28.5,100],//inner Y
                    [66.25,.25,223], //inner 2 from Y
                    [69.7,35.6,134], //outer Y
                    [67.2,35,40],//outer Y, inside
                    [71,38,45],//outer Y, outside
                    [41,56.7,64],//outer 2 from y
                    [43,58,65],//outer 2 from y
                    [86.25,-49,2],//second from inner edge
 
                    [36,20.5,68],//second from inner center
                    [83,5,16],//middle split middle pin
                    [10.8,66.8,-97],// first from outer center
                    [18,25.5,80],//first from inner center
                    [52,12.3,55],//third from inner center
                    [76,-13.5,31],//first from inner Y (inner band)
 
                    [86,-11,5],//first from inner Y (middle band)
                    [77,20,25],//first from outer Y (middle band)
                    [82,23.5,33],//first from edge outer band
                    [0,67.55,90],//center outer band
                    [58,49,52],//first outer from outer Y 
                    [55.75,46.75,52],// first inner from outer y
                    [26,63,74],//second from center outer band
                    [27.5,64.2,74],//second from center outer band
                  ];
//                   [0,67.55,90], //[X,Y,Angle]
//                   [90.95,7.1,23],
//                   [0,27.2,90],
//                   [84.3,-28.5,90],
//                   [86.25,-68,0],
//                   [69.7,35.6,0],
//                  ];


//Helper variables
headband_support_extension=0; //Should be 0 but 
                               // adjust to 10
                               // to see locations

//Make the stack!
rotate(180){
  stacked_headbands(
            number_of_headbands, 
            headband_height_in_mm,
            layer_height_between_headbands
            );
}



module stacked_headbands(
         number_of_headbands, 
         headband_height_in_mm,
         layer_height_between_headbands
         ){

  //Headbands
  for(x=[0:number_of_headbands-1]){
    translate([
       0,
       0,
       x*(headband_height_in_mm +    
        layer_height_between_headbands)]){ 
          
      color("OrangeRed"){
        translate([adjust_headband_loc_x,
                   adjust_headband_loc_y,
                   adjust_headband_loc_z]){
          import(headband_file, convexity=3);
        }    
      }
    }
  }
  
  //Internal Supports for headbands
  stack_height=number_of_headbands*(            
                   headband_height_in_mm
                ) +
               (number_of_headbands)*// - 1)*
                layer_height_between_headbands
               + headband_support_extension;
  internal_headband_supports(stack_height);
  
  
  //Faceshield knub support
  mirror_copy(){
    faceshield_knub_support(number_of_headbands,   layer_height_between_headbands,    
       headband_height_in_mm);
  }
}

module internal_headband_supports(stack_height){
  
    mirror_copy(){
      color("#FFAA00"){
        for(y = [0:len(support_locations)-1]){
            translate([support_locations[y][0],
                       support_locations[y][1]]){
              linear_extrude(stack_height){
                rotate(support_locations[y][2]){
                  //square([1.3,2.3], center=true);
                  circle(circle_support_size);
                }
              }
            }
        }
      }
    }
}


module faceshield_knub_support( 
                   number_of_headbands, 
                   layer_height_between_headbands,
                   headband_height_in_mm){
  
                     
   //Support for two front knubs
   color("#00FF00"){
     faceshield_knub_front_support(  
                   number_of_headbands, 
                   layer_height_between_headbands, 
                   headband_height_in_mm);
   }
                     
   //support for two side knubs
   color("#00FFFF"){
     faceshield_knub_side_support(  
                   number_of_headbands, 
                   layer_height_between_headbands,
                   headband_height_in_mm);
   }
}


//two front knubs
module faceshield_knub_front_support(  
                   number_of_headbands, 
                   layer_height_between_headbands,
                   headband_height_in_mm){
                     
  //Support column
  inner_circle=2.9;
  support_height = (number_of_headbands-1)*(headband_height_in_mm + layer_height_between_headbands) - layer_height_between_headbands;                   
  front_shell(inner_circle,
              support_height,
              collumn_thickness);
  front_shell(inner_circle,
              column_brim_height,
              column_brim_thickness);
                     
  //bridges
  for(x=[1:number_of_headbands-1]){ 
    translate([0,0,
         x*(headband_height_in_mm + layer_height_between_headbands)
         - column_support_bridge
         - layer_height_between_headbands
         ]){
      linear_extrude(column_support_bridge){
        translate(column_front_brim_offset){ 
          difference(){    
            front_knub_bridge(inner_circle);
            front_knub_cutoff();
          }
        }
      }
    }
  }
                     
}

module front_shell(inner_circle,height, thickness){
  linear_extrude(height){   
    translate(column_front_brim_offset){
      difference(){
        union(){
          circle(inner_circle + thickness);
          translate([0,
                 -inner_circle - thickness,
                   0]){
            square(
                 2*(inner_circle+thickness),
                      center=true);
          }
        }
    
        front_knub_bridge(inner_circle);
        front_knub_cutoff();     
      }
    }  
  } 
}

module front_knub_bridge(inner_circle){
  union(){
    circle(inner_circle);
      translate([0,-inner_circle
                   -2*collumn_thickness,0]){
        square([2*inner_circle,
                2*inner_circle 
                + 4*collumn_thickness], 
                center=true);
      }
    }
}

module front_knub_cutoff(){
  translate([0,-23.8]){
    rotate(17){
      square(40, center=true);
    }
  }     
}

//Two side knubs
module faceshield_knub_side_support(  
                   number_of_headbands, 
                   layer_height_between_headbands,
                   headband_height_in_mm){
    
  //Support column
  inner_circle=2.9;
  support_height = (number_of_headbands-1)*(headband_height_in_mm + layer_height_between_headbands) - layer_height_between_headbands;                   
  side_shell(inner_circle,
              support_height,
              collumn_thickness);
  side_shell(inner_circle,
              column_brim_height,
              column_brim_thickness);
       
       
                     
  //bridges
  for(x=[1:number_of_headbands-1]){ 
    translate([0,0,
         x*(headband_height_in_mm +  
          layer_height_between_headbands)
         - column_support_bridge
         - layer_height_between_headbands
         ]){
      linear_extrude(column_support_bridge){
        translate(column_side_brim_offset){
          rotate(3){ 
            difference(){    
              side_knub_bridge(inner_circle);
              side_knub_cutoff();
            }
          }
        }
      }
    }
  }
                     
}

module side_shell(inner_circle,height, thickness){
  linear_extrude(height){   
    translate(column_side_brim_offset){
      rotate(3){
        difference(){
          union(){
            circle(inner_circle + thickness);
            translate([inner_circle + thickness,
                       0,
                     0]){
              square(
                   2*(inner_circle+thickness),
                        center=true);
            }
          }
      
          side_knub_bridge(inner_circle);
          side_knub_cutoff();              
        }
      }
    }  
  } 
}

module side_knub_bridge(inner_circle){
  union(){
    circle(inner_circle);
      translate([inner_circle + 2*
                 collumn_thickness,0,0]){
        square([2*inner_circle 
                + 4*collumn_thickness,
                2*inner_circle], 
                center=true);
      }
    }
}

module side_knub_cutoff(){
  translate([20.5,-10]){
    rotate(59){
      square(40, center=true);
    }
  }     
}

//See https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Create_a_mirrored_object_while_retaining_the_original
module mirror_copy(v = [1, 0, 0]) {
    children();
    mirror(v) children();
}
