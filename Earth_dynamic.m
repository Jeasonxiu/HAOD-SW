function [dxdt]=Earth_dynamic(t,X,JD0,order,EGM,EOP,DAT,C_r)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Dynamics equation considering the EGM2008 model until the 70th degree.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
% t: time
% X: dynamic state
% JD0: start Julian Date
% order: Harmonics degrees considered
% Coeff: Matrix of IERS Coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Earth Orientation Parameters & Constants.................................

global  GM R_E w_E c

EOP_vector=find_EOP(t/86400+JD0,EOP,DAT);
xp=EOP_vector(1);
yp=EOP_vector(2);
dut1=EOP_vector(3);
lod=EOP_vector(4);
dX=EOP_vector(5);
dY=EOP_vector(6);
dat=EOP_vector(7);
timezone=0;
[year, mon, day, hr, minute,sec]=invjday(t/86400+JD0);
[~, ~, jdut1, ~, ~, ~, ttt]= convtime ( year, mon, day, hr, minute,...
    sec, timezone, dut1, dat);   % Time conversion
%..........................................................................

r=X(1:3);
v=X(4:6);

r_ECEF=gcrs2itrs(r,zeros(3,1),zeros(3,1),ttt,jdut1,lod,xp,yp,dX,dY);

% Sun third body effect....................................................

GM_sun=1.32712442099*10^11;                     % Sun Gravity constant [km3/s2]

Sun=(Planet_Ephemeris(t/86400+JD0,'SUN','EARTH',dut1,dat))';
Sun=Sun(1:3);

Sun_sat=Sun-r;                                  % Position of satellite from Sun [Km]

delta_g_sun=GM_sun*(Sun_sat/((norm(Sun_sat)^3))-Sun/(norm(Sun)^3));

% Moon third body effect...................................................

GM_moon=(GM/1E9)*0.0123000371;                  % Moon Gravity constant [Km3/s2]
Moon=(Planet_Ephemeris(t/86400+JD0,'MOON','EARTH',dut1,dat))';
Moon=Moon(1:3);
Moon_sat=Moon-r;                                % Position of satellite from Moon [Km]
delta_g_moon=GM_moon*(Moon_sat/((norm(Moon_sat)^3))-Moon/(norm(Moon)^3));

% Earth Geopotential Field.................................................

Sun_ECEF=gcrs2itrs(Sun(1:3),zeros(3,1),zeros(3,1),ttt,jdut1,lod,xp,yp,dX,dY); 
    
Moon_ECEF=gcrs2itrs(Moon(1:3),zeros(3,1),zeros(3,1),ttt,jdut1,lod,xp,yp,dX,dY);

g_ECEF=harmonics_model(r_ECEF*1E3,order,EGM,Sun_ECEF*1E3,...
    Moon_ECEF*1E3,GM_sun*1E9,GM_moon*1E9,jdut1,xp,yp,ttt,jdut1);        % gravity field in ECEF due to Earth' gravity field [m/s2]

[~,~,g_eci]=itrs2gcrs(zeros(3,1),zeros(3,1),g_ECEF/1E3,ttt,jdut1,lod,xp,yp,dX,dY);

% Solar & Earth Radiation Pressure.........................................

A_m=0.001;
delta_g_SRP=SRP_effect(r,Sun,(t/86400+JD0),A_m,C_r);

Nring=2;
delta_g_ERP=ERP_effect(r,v,Sun,(t/86400+JD0),Nring,A_m,C_r,ttt,jdut1,lod,xp,yp,dX,dY);

% Earth Radiation Pressure.................................................



% Relativistic Schwarzschild effect........................................


%delta_g_rel_Sc=((GM/1E9)/((c/1E3)^2*norm(r)^3))*((4*(GM/1E9)/norm(r)-dot(v,v))*r+4*dot(r,v)*v);

% Relativistic Lense-Thirring effect.......................................

% J=2/5*R_E^2*w_E*[0;0;1]/1E6;
%delta_g_rel_LT=2*((GM/1E9)/((c/1E3)^2*norm(r)^3))*(3/norm(r)^2*cross(r,v)*dot(r,J)+cross(v,J));

% Relativistic de Sitter effect............................................
% 
% Earth_from_Sun=(Planet_Ephemeris(t/86400+JD0,'EARTH','SUN'))';
% Earth_vel=Earth_from_Sun(4:6);
% Earth_pos=Earth_from_Sun(1:3);

%delta_g_rel_dS=cross(3*cross(Earth_vel,-(GM_sun/((c/1E3)^2*norm(Earth_pos)^3))*Earth_pos),v);

% Total acceleration on satellite..........................................

% tot_g=g_eci+delta_g_sun+delta_g_moon+delta_g_rel_Sc+delta_g_SRP+delta_g_ERP;
tot_g=g_eci+delta_g_sun+delta_g_moon+delta_g_SRP+delta_g_ERP;

dxdt=[v;tot_g];

end

