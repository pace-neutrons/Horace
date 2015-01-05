function wout=fix_magnetic_ffFe(win)
% Correct a dataset for the magnetic scattering form factor for Fe (0)
% calculated in dipole approximation
%
%
% conversion factor to change from rlu to wave-vector in A^(-1)
if isa(win,'sqw')
    rlu2u = win.data.ulen(1:3);
    
    rlu2u_sq = rlu2u.*rlu2u;
    %We can cheat here by making a dummy sqw function that returns the bose
    %factor for all of the points:
    
    sqw_magFF=sqw_eval(win,@fe_form_factor_J2,rlu2u_sq);
else
    rlu2u = win.ulen(1:3);
    
    rlu2u_sq = rlu2u.*rlu2u;
    % unpack integration and projection axis to 4D structure
    wis = struct(win);
    sizes = cell(4,1);
    old_size = size(wis.s);
    wp       = wis.p;
    iax = wis.iax;    
    iint = wis.iint;
    dax  = wis.dax;
    pax = wis.pax;
    if numel(wis.iax)>0
        p = cell(1,4);

        ciax = 1;
        cpax = 1;
        for i=1:4
            if i==iax(ciax)
                p{i} = iint(:,ciax);
                ciax=ciax+1;
                sizes{i}=1;
            else
                p{i} = wp{cpax};
                cpax=cpax+1;
                sizes{i}=numel(p{i})-1;
            end
        end
        wis.p=p;
        wis.iax=[];
        wis.iint=[];
        wis.dax=1:4;
        wis.pax=1:4;
        wis.s =reshape(wis.s,sizes{:});
        wis.e =reshape(wis.e,sizes{:});
        wis.npix =reshape(wis.npix,sizes{:});
    end
    
    wout=sqw('$dnd',wis );
    wout = struct(func_eval(wout,@fe_form_factor_J2,rlu2u_sq));
    wout.data.p = wp;
    wout.data.iax = iax;
    wout.data.iint = iint;
    wout.data.dax = dax;
    wout.data.pax = pax;
    wout.data.s = reshape(wis.s,old_size);
    wout.data.e = reshape(wis.e,old_size);    
    wout.data.npix = reshape(wis.npix,old_size);
    wout=sqw('$dnd',wout.data);
    sqw_magFF = dnd(wout);
end

wout=mrdivide(win,sqw_magFF);

%==============================

function FF = fe_form_factor_J2(h,k,l,en,rlu2u_sq)
%
% Magnetic form factor, dipole approximation
% it is factorized over (q^2 in A^-2) so we need to convert from rlu to q in A
%
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

