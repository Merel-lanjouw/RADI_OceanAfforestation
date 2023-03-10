%Station W2
%Adapted to include seaweed parameters
%Hammon et al 1996 Deep-Sea Research


Station= "Hammond1996 - W2";

%% Definition of the spatial domain
z_max=20e-2;     %[m] bottom sediment depth, should be a multiple of z_res
z_res=0.05e-2;     %[m] depth resolution
ndepths = 1 + z_max/z_res;     %[no unit] number of depth layers
depths = linspace(0, z_max, ndepths); %[m] depth
z_res = ones(size(depths))*z_res; %[m] depth resolution

%% Definition of the temporal domain
stoptime = 10;       %[a] total timespan of the problem
interval=1/300000;          %[a] time resolution (1/60000 is nine minutes, 1/8760 is one hour; 1/365.2 is a day)
t_length=stoptime/interval;      %[no unit] number of time layers

%% Bottom-water environmental conditions
T=1.4;      %[C] temperature
S=34.69;   %[psu] salinity
P=4380;    %[bar] pressure
rho_sw = gsw_rho(S,T,P);    %[kg/m^3] in situ seawater density computed from GSW toolbox

%% Bottom-water values of dissolved species
dO2w=(159.7)*1e-6*rho_sw; %[mol/m3] dissolved oxygen from GLODAP at station location, bottom waters
dtalkw=(2426)*1e-6*rho_sw; %[mol/m3] dissolved oxygen from GLODAP at station location, bottom waters
dtCO2w=(2324)*1e-6*rho_sw; %[mol/m3] DIC from GLODAP at sation location, bottom waters
dtNO3w=(36.93)*1e-6*rho_sw; %[mol/m3] nitrate from GLODAP at sation location, bottom waters
dtSO4w=(29264.2*S/35)*1e-6*rho_sw; %[mol/m3] computer from salinity (Millero, 2013)
dtPO4w=(2.39)*1e-6*rho_sw; %[mol/m3] phosphate from GLODAP at sation location, bottom waters
dtNH4w=1e-6*rho_sw; %[mol/m3] assumed
dtH2Sw=0*1e-6*rho_sw; %[mol/m3] assumed
dFew=0.5*1e-9*rho_sw; %[mol/m3] typical for deep sea oxic bottom waters (Abadie et al., 2019)
dMnw=0.5*1e-9*rho_sw; %[mol/m3] typical for deep sea oxic bottom waters (Morton et al., 2019)
dtSiw=120*1e-6*rho_sw;  %[mol/m3] dissolved inorganic silica
dCaw=0.02128./40.087.*(S./1.80655)*rho_sw;  %[mol/m3] Ca, computed from salinity using Riley CG(1967)

%% depth-dependent porosity
phiBeta = 33;   %porosity attenuation coefficient
phiInf = 0.74;   %porosity at infinite depth
phi0 = 0.85;    %porosity at interface
phi = (phi0 - phiInf)*exp(-phiBeta*depths) + phiInf;   %porosity profile 
phiS=1-phi;   %solid volume fraction
tort=(1-2*log(phi)).^0.5;   %tortuosity from Boudreau (1996, GCA)
tort2=tort.^2;   %tortuosity squared

%% Redfield ratios
RC=106;     %Redfield ratio for C
RN=16;     %Redfield ratio for N
RP=1;    %Redfield ratio for P 
M_CH2O=30.031; %[g per mol] molar mass of CH2O
M_NH3=17.031; %[g per mol] molar mass of NH3
M_H3PO4=97.994; %[g per mol] molar mass of H3PO4
M_OM=M_CH2O+(RN/RC)*M_NH3+(RP/RC)*M_H3PO4; %[g of OM per mol of OC] Organic Matter molar mass

%% Ratios for seaweed
if not(Seaweed=="Natural")
    M_CH2Os=30.031; %[g per mol]
    M_NH3s=17.031; %[g per mol]
    M_H3PO4s=97.994; %[g per mol]
    M_OMs=M_CH2Os+(RNs/RCs)*M_NH3s+(RPs/RCs)*M_H3PO4s; %[g of OM per mol of OC] Organic Matter molar mass
else
    M_OMs=0;
end

%% solid fluxes and solid initial conditions
Foc=0.1957; %[mol/m2/a] flux of total organic carbon to the bottom 
Froc=Foc*0.03; %[mol/m2/a] flux of refractory organic carbon to the bottom 
Fsoc=Foc*0.27; %[mol/m2/a] flux of slow decay organic carbon to the bottom 
Ffoc=Foc*0.7; %[mol/m2/a] flux of fast decay organic carbon to the bottom 

FMnO2=0.0005; %typical for deep sea oxic bottom waters (Archer et al., 2002; Boudreau, 1996)
FFeOH3=0.0005; %typical for deep sea oxic bottom waters (Archer et al., 2002; Boudreau, 1996)
Fcalcite=0.22; %[mol/m2/a] flux of calcite to the seafloor 
Faragonite=0; %[mol/m2/a] flux of aragonite to the seafloor
Fclay=2/360.31; %[mol/m2/a] flux of clay to the bottom: 360.31 is the molar mass of montmorillonite, typical deep sea clay

Ftot=Focs*M_OMs+Foc*M_OM+FMnO2*86.9368+FFeOH3*106.867+Fcalcite*100.0869+Faragonite*100.0869+Fclay*360.31; %[g/m2/a] total sediment flux 
v0=(Ftot)/(2.65e6*phiS(1));                                             %[m/a] bulk burial velocity at sediment-water interface
vinf=v0*phiS(1)/phiS(1,ndepths);                                    %[m/a]bulk burial velocity at the infinite depth
for j=1:ndepths
    u_s(1,j)=vinf*phi(1,ndepths)/phi(1,j);                               %[m/a] porewater burial velocity
    w_s(1,j)=vinf*phiS(1,ndepths)/phiS(1,j);                         %[m/a] solid burial velocity
end

Ftot=Foc*M_OM+FMnO2*86.9368+FFeOH3*106.867+Fcalcite*100.0869+Faragonite*100.0869+Fclay*360.31;
v0=(Ftot)/(2.65e6*phiS(1));                                             %[m/a] bulk burial velocity at sediment-water interface
vinf=v0*phiS(1)/phiS(1,ndepths);                                    %[m/a]bulk burial velocity at the infinite depth
for j=1:ndepths
    u_nat(1,j)=vinf*phi(1,ndepths)/phi(1,j);                               %[m/a] porewater burial velocity
    w_nat(1,j)=vinf*phiS(1,ndepths)/phiS(1,j);                         %[m/a] solid burial velocity
end

%% diffusive boundary layer
dbl=1e-3;            %[m] thickness at location taken from Sulpis et al 2018 PNAS

rerun = 0;
time_saved_resolution=1/1000; %[a] 1/1000