function wout=fix_magnetic_ff(self,win)
% Correct a dataset for the magnetic scattering form the magnetic ion
% provided
%
% List of magnetic ions with defined form factors can be retrived from
% MagneticIons class.
%
%
%Usage:
% mi= MagneticIons('Fe0')
%>>sqw_corrected = mi.fix_magnetic_ff(sqw_data)
%where:
% 'Fe0'    -- the name of ion, which scattering is corrected.
% sqw_data -- dnd or sqw dataset to correct
%
% Returns:
% sqw_corrected  -- input dataset divided by magnetic form factor of
%                   selected ion.
%
%Notes:
%
% * AT THE MOMENT IS IMPLEMENTED FOR ORTHOGONAL LATTICE ONLY!
%
% * Repetetive applications of the corrections to the same dataset works and
%   causes wrong corrections. 
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%



%
% conversion factor to change from rlu to wave-vector in A^(-1)
%
if isa(win,'sqw')
    rlu2u = win.data.ulen(1:3);   
    rlu2u_sq = rlu2u.*rlu2u;
    self.rlu2uSq_ = rlu2u_sq;
    
    %We can cheat here by making a dummy sqw function that returns the bose
    %factor for all of the points:
    
    sqw_magFF=sqw_eval(win,@fe_form_factor_J2,self);
else
    rlu2u = win.ulen(1:3);    
    rlu2u_sq = rlu2u.*rlu2u;
    self.rlu2uSq_ = rlu2u_sq;
    
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
    wout = struct(func_eval(wout,@fe_form_factor_J2,self));
    wout.data.p = wp;
    wout.data.iax = iax;
    wout.data.iint = iint;
    wout.data.dax = dax;
    wout.data.pax = pax;
    wout.data.s = reshape(wout.data.s,old_size);
    wout.data.e = reshape(wout.data.e,old_size);
    wout.data.npix = reshape(wout.data.npix,old_size);
    wout=sqw('$dnd',wout.data);
    sqw_magFF = dnd(wout);
end

wout=mrdivide(win,sqw_magFF);

%==============================

function FF = fe_form_factor_J2(h,k,l,en,self)
% function calculates magnetic form-factor using exponential representation
%
rlu2u_sq = self.rlu2uSq_;

q2 = ((h.*h)*rlu2u_sq(1)+(k.*k)*rlu2u_sq(2)+(l.*l)*rlu2u_sq(3))/(16*pi*pi);
FF=self.J0_ff_(q2).^2+self.J2_ff_(q2).^2+self.J4_ff_(q2).^2+self.J6_ff_(q2).^2;

