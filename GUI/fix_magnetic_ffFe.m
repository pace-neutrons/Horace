function wout=fix_magnetic_ffFe(win)
%
% Correct a dataset for the magnetic scattering form factor for Fe (0)
% calculated in dipole approximation
%
%
% conversion factor to change from rlu to wave-vector in A^(-1)
rlu2u = win.data.ulen(1:3);

rlu2u_sq = rlu2u.*rlu2u;
%We can cheat here by making a dummy sqw function that returns the bose
%factor for all of the points:
sqw_magFF=sqw_eval(win,@fe_form_factor_J2,rlu2u_sq);

wout=mrdivide(win,sqw_magFF);

%==============================

function FF = fe_form_factor_J2(h,k,l,en,rlu2u_sq)
%
% Magnetic form factor, dipole approximation
% it is factorized over (q^2 in A^-2) so we need to convert from rlu to q in A
%
% data copied from https://www.ill.eu/sites/ccsl/ffacts/ffachtml.html
%ion	A        a       B      b       C       c        D           e
%Fe0 	0.0706 	35.008 	0.3589 	15.358 	0.5819 	5.561 	-0.0114 	0.1398
A=0.0706; a=35.008; B=0.3589; b=15.358; C=0.5819;c=5.561; D=-0.0114;
J0_ff = @(x2)((A*exp(-a*x2)+B*exp(-b*x2)+C*exp(-c*x2)+D));
%J2
%        A 	     a     	    B 	     b      	C   	c 	      D         e
%Fe0 	1.9405 	18.473 	    1.9566     6.323 	0.5166 	 2.161  	0.0036  0.0394
% Mantid
%1.9405,18.473,1.9566,6.323,0.5166,2.161,0.0036,0.0394
A2=1.9405;   a2 = 18.4733; B2 = 1.9566;b2 = 6.323;C2 = 0.5166;c2 = 2.1607; D2 = 0.0036;
J2_ff = @(x2)(((A2*exp(-a2*x2)+B2*exp(-b2*x2)+C2*exp(-c2*x2)+D2).*x2));



q2 = ((h.*h)*rlu2u_sq(1)+(k.*k)*rlu2u_sq(2)+(l.*l)*rlu2u_sq(3))/(16*pi*pi);
FF=J0_ff(q2).^2+J2_ff(q2).^2;
