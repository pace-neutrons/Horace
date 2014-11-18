function wout=Fe_magnetic_ff(win)
%
% Correct a dataset for the magnetic scattering form factor 
% 
%
%
rul2u = win.data.ulen(1:3);
rlu2u_sq = rul2u.* rul2u;
%We can cheat here by making a dummy sqw function that returns the bose
%factor for all of the points:
sqw_magFF=sqw_eval(win,@fe_form_factor_J2,rlu2u_sq);

wout=mrdivide(win,sqw_magFF);

%==============================

function y = fe_form_factor_J2(h,k,l,en,rlu2u_sq)
%
% Magnetic form factor, dipole approximation
% it is factorized over (q in A)^2 so we need to convert from rlu to q in A
%
% data copied from https://www.ill.eu/sites/ccsl/ffacts/ffachtml.html
%J2
%        A 	     a     	    B 	     b      	C   	c 	      D         e
%Fe0 	1.9405 	18.473 	    1.9566     6.323 	0.5166 	 2.161  	0.0036  0.0394
% Mantid
%1.9405,18.473,1.9566,6.323,0.5166,2.161,0.0036,0.0394
A2=1.9405;   a2 = 18.4733; B2 = 1.9566;b2 = 6.323;C2 = 0.5166;c2 = 2.1607; D2 = 0.0036;

J2_ff = @(x2)(((A2*exp(-a2*x2)+B2*exp(-b2*x2)+C2*exp(-c2*x2)+D2).*x2));

q2 = ((h.*h)*rlu2u_sq(1)+(k.*k)*rlu2u_sq(2)+(l.*l)*rlu2u_sq(3))/(4*pi*pi);
y=J2_ff(q2);
