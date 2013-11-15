function sf=fake_cross_sec(h,k,l,en,pars)
%
% Cross-section that is uniform, with a dispersion that is proportional to
% |Q_inplane| and periodic.
%

stiffness=pars(1); gam=pars(2); amp=pars(3);
temp=1; delta=5;

h1=abs(h-round(h)); k1=abs(k-round(k));

Qmag=sqrt(h1.^2 + k1.^2);


omega0 = delta + stiffness.*Qmag;

Bose= en./ (1-exp(-11.602.*en./temp));%Bose factor from Tobyfit. 

%Use damped SHO model to give intensity:
sf = amp.* (Bose .* (4.*gam.*omega0)./(pi.*((en-omega0).^2 + 4.*(gam.*en).^2)));
%sf = amp.* (Bose .* (4.*gam.*omega0)./(pi.*((en-omega0).^2 + 4.*(gam).^2)));
