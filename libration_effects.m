function [Deltax,Deltay,DeltaUT1,DeltaLOD]=libration_effects(ttt,jdut1)
% Coefficients of sin(argument) and cos(argument) in (?x,?y)libration 
% due to tidal gravitation (of degree n) for a nonrigid Earth

coeff_xy=[4 0 0 0 0 0 -1 055.565 6798.3837 0.0 0.6 -0.1 -0.1;
    3 0 -1 0 1 0 2 055.645 6159.1355 1.5 0.0 -0.2 0.1;
    3 0 -1 0 1 0 1 055.655 3231.4956 -28.5 -0.2 3.4 -3.9;
    3 0 -1 0 1 0 0 055.665 2190.3501 -4.7 -0.1 0.6 -0.9;
    3 0 1 1 -1 0 0 056.444 438.35990 -0.7 0.2 -0.2 -0.7;
    3 0 1 1 -1 0 -1 056.454 411.80661 1.0 0.3 -0.3 1.0;
    3 0 0 0 1 -1 1 056.555 365.24219 1.2 0.2 -0.2 1.4;
    3 0 1 0 1 -2 1 057.455 193.55971 1.3 0.4 -0.2 2.9;
    3 0 0 0 1 0 2 065.545 27.431826 -0.1 -0.2 0.0 -1.7;
    3 0 0 0 1 0 1 065.555 27.321582 0.9 4.0 -0.1 32.4;
    3 0 0 0 1 0 0 065.565 27.212221 0.1 0.6 0.0 5.1;
    3 0 -1 0 1 2 1 073.655 14.698136 0.0 0.1 0.0 0.6;
    3 0 1 0 1 0 1 075.455 13.718786 -0.1 0.3 0.0 2.7;
    3 0 0 0 3 0 3 085.555 9.1071941 -0.1 0.1 0.0 0.9;
    3 0 0 0 3 0 2 085.565 9.0950103 -0.1 0.1 0.0 0.6;
    2 1 -1 0 -2 0 -1 135.645 1.1196992 -0.4 0.3 -0.3 -0.4;
    2 1 -1 0 -2 0 -2 135.655 1.1195149 -2.3 1.3 -1.3 -2.3;
    2 1 1 0 -2 -2 -2 137.455 1.1134606 -0.4 0.3 -0.3 -0.4;
    2 1 0 0 -2 0 -1 145.545 1.0759762 -2.1 1.2 -1.2 -2.1;
    2 1 0 0 -2 0 -2 145.555 1.0758059 -11.4 6.5 -6.5 -11.4;
    2 1 -1 0 0 0 0 155.655 1.0347187 0.8 -0.5 0.5 0.8;
    2 1 0 0 -2 2 -2 163.555 1.0027454 -4.8 2.7 -2.7 -4.8;
    2 1 0 0 0 0 0 165.555 0.9972696 14.3 -8.2 8.2 14.3;
    2 1 0 0 0 0 -1 165.565 0.9971233 1.9 -1.1 1.1 1.9;
    2 1 1 0 0 0 0 175.455 0.9624365 0.8 -0.4 0.4 0.8];

% Coefficients of of semi-diurnal variations in UT1 and LOD due 
% to libration for a non-rigid Earth

coeff=[ 2 -2 0 -2 0 -2 235.755 0.5377239 0.05 -0.03 -0.3 -0.6;
        2 0 0 -2 -2 -2 237.555 0.5363232 0.06 -0.03 -0.4 -0.7;
        2 -1 0 -2 0 -2 245.655 0.5274312 0.35 -0.20 -2.4 -4.2;
        2 1 0 -2 -2 -2 247.455 0.5260835 0.07 -0.04 -0.5 -0.8; 
        2 0 0 -2 0 -1 255.545 0.5175645 -0.07 0.04 0.5 0.8;
        2 0 0 -2 0 -2 255.555 0.5175251 1.75 -1.01 -12.2 -21.3;
        2 1 0 -2 0 -2 265.455 0.5079842 -0.05 0.03 0.3 0.6;
        2 0 -1 -2 2 -2 272.556 0.5006854 0.05 -0.03 -0.3 -0.6;
        2 0 0 -2 2 -2 273.555 0.5000000 0.76 -0.44 -5.5 -9.5;
        2 0 0 0 0 0 275.555 0.4986348 0.21 -0.12 -1.5 -2.6;
        2 0 0 0 0 -1 275.565 0.4985982 0.06 -0.04 -0.4 -0.8];
    
    
F_v=Delaunay_variables(ttt);
[GMST]=Greenswich_MST(ttt,jdut1);
Del_coeff=coeff(:,2:6);
n=coeff(:,1);
csi=Del_coeff*F_v'-n*(GMST+pi);
S_ut1=coeff(:,9)/1E6;
C_ut1=coeff(:,10)/1E6;
S_lod=coeff(:,11)/1E6;
C_lod=coeff(:,12)/1E6;

Del_coeff_xy=coeff_xy(:,3:7);
n_xy=coeff_xy(:,2);
csi_xy=Del_coeff_xy*F_v'-n_xy*(GMST+pi);
S_x=deg2rad(coeff_xy(:,10)/1E6/3600);
C_x=deg2rad(coeff_xy(:,11)/1E6/3600);
S_y=deg2rad(coeff_xy(:,12)/1E6/3600);
C_y=deg2rad(coeff_xy(:,13)/1E6/3600);

DeltaUT1=sum(S_ut1.*sin(csi)+C_ut1.*cos(csi));
DeltaLOD=sum(S_lod.*sin(csi)+C_lod.*cos(csi));
Deltax=sum(S_x.*sin(csi_xy)+C_x.*cos(csi_xy));
Deltay=sum(S_y.*sin(csi_xy)+C_y.*cos(csi_xy));

end