% SpinW model of Heisenberg + dipolar + aniso on pyrochlore lattice
% Includes, J1, J2, and both types of J3 interation (J3a along J1)
% Model is powder averaged and integrated over a given Qrange.
% Then - a flat background is added and a attenuation coefficient applied.
%
% ============
% 
% Ross Stewart - 13/07/2022
%
%%
function yout=spinw_gpo_1dfit(E,pars,Qrange,Ei,dE,dQ,s)

boltzmann = 0.08617;
spin = 7/2;
scalefac = pars(1);
J1  = pars(2) * boltzmann / spin / (spin + 1);
J2  = pars(3) * boltzmann / spin / (spin + 1);
J3a = pars(4) * boltzmann / spin / (spin + 1);
J3b = pars(5) * boltzmann / spin / (spin + 1);
D   = pars(6) * boltzmann / spin / spin;
muR = pars(7);
bg  = pars(8);
rlimit = 20;    % range in Å over which dipolar interactions are calculated
powder_Q_points = 200;  % number of Q points for powder average

QQ = linspace(Qrange(1),Qrange(2),10);

fprintf('\n Heisenberg interactions:')
fprintf('\n J1  = %0.5f meV (%0.5f K); J1*S(S+1)  = %0.5f K', J1, J1/boltzmann, J1*spin*(spin+1)/boltzmann)
fprintf('\n J2  = %0.5f meV (%0.5f K); J2*S(S+1)  = %0.5f K', J2, J2/boltzmann, J2*spin*(spin+1)/boltzmann)
fprintf('\n J3a = %0.5f meV (%0.5f K); J3b*S(S+1) = %0.5f K', J3a, J3a/boltzmann, J3a*spin*(spin+1)/boltzmann)
fprintf('\n J3b = %0.5f meV (%0.5f K); J3b*S(S+1) = %0.5f K \n', J3b, J3b/boltzmann, J3b*spin*(spin+1)/boltzmann)

% Setup SpinW model
gpo = spinw;
symStr = ['-z,y+3/4,x+3/4; z+3/4,-y,x+3/4; z+3/4,y+3/4,-x; ''y+3/4,x+3/4,-z; x+3/4,-z,y+3/4; -z,x+3/4,y+3/4'];
gpo.genlattice('lat_const', [10.225 10.225 10.225], 'angled', [90 90 90],'spgr',symStr,'label','F d -3 m Z');
gpo.addatom('r', [1/2 1/2 1/2], 'S', spin, 'label', 'Gd3+')
gpo.gencoupling('maxDistance', rlimit)
spins=bf1;
gpo.genmagstr('k',[0 0 0],'S',spins);
gpo.addmatrix('label', 'J1',  'value', J1);
gpo.addmatrix('label', 'J2',  'value', J2);
gpo.addmatrix('label', 'J3a', 'value', J3a);
gpo.addmatrix('label', 'J3b', 'value', J3b);
gpo.addcoupling('mat', 'J1',  'bond', 1)
gpo.addcoupling('mat', 'J2',  'bond', 2)
gpo.addcoupling('mat', 'J3a', 'bond', 3)
gpo.addcoupling('mat', 'J3b', 'bond', 4)
gpo.addmatrix('value',D*[1 1 1 ; 1 1 1 ; 1 1 1]/sqrt(3),'label','D1');
gpo.addaniso('D1');
gpo.coupling.rdip = rlimit;

% Powder average spin waves:
% note that you can change the number of random Q points
% A smaller number gives a noisier output, but faster evaluation.
gpopowspec=gpo.powspec_ran(QQ','Evect',unique(E),'binType','cbin','nRand',...
    powder_Q_points,'hermit',true,'formfact',true,'s_rng',s);

%Give a file containing Nx2 matrix giving Etrans and dE. From Pychop for Ei=11meV 240/120Hz
gpopowspec = sw_instrument(gpopowspec,'dE',dE,'Ei',Ei,'dQ',dQ);
yout=abs(scalefac).*gpopowspec.swConv';
    
% do the integration over Q to create the calculated cut
yout = sum(yout,1);
yout = yout + bg;
    
% multiply by attenuation coefficient
energy = Ei - E;
wavelength = sqrt(81.81 ./ energy);
T = exp(-muR * wavelength/1.8);
yout = yout .* T/max(T);
    
%Can be odd cases when small number of additional points come from sim
%as NaN. In this case replace them with bg:
f=isnan(yout);
yout(f)=bg;
    
end

function spins = bf1()
    global spinstr
    spinstr = 'palmer_chalker basis 1';
    
    S1 = [1 -1 0];      % (1/2 1/2 1/2) GD_1
    S2 = [-1 -1 0];     % (1/2 1/4 1/4) GD_4
    S3 = [1 1 0];       % (3/4 0   1/4) GD_3
    S4 = [-1 1 0];      % (3/4 3/4 1/2) GD_2
    S5 = [1 1 0];       % (1/4 1/2 1/4) GD_3
    S6 = [-1 -1 0];     % (0   3/4 1/4) GD_4
    S7 = [1 -1 0];      % (0   0   1/2) GD_1
    S8 = [-1 1 0];      % (1/4 1/4 1/2) GD_2
    S9 = [1 -1 0];      % (0   1/2 0  ) GD_1
    S10= [-1 -1 0];     % (0   1/4 3/4) GD_4
    S11= [1 1 0];       % (1/4 0   3/4) GD_3
    S12= [-1 1 0];      % (1/4 3/4 0  ) GD_2
    S13= [1 1 0];       % (3/4 1/2 3/4) GD_3
    S14= [-1 -1 0];     % (1/2 3/4 3/4) GD_4
    S15= [1 -1 0];      % (1/2 0   0  ) GD_1
    S16= [-1 1 0];      % (3/4 1/4 0  ) GD_2
    
    spins = cat(3,S1',S2',S3',S4',S5',S6',S7',S8',S9',S10',S11',S12',S13',S14',S15',S16');
    spins = permute(spins,[1 3 2]);

end
