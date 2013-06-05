function [alatt,angdeg,ok,mess] = lattice_parameters(win)
% Return the lattice parameters for an array of sqw objects. Error if not the same in all objects.
%
%   >> [ok,mess,alatt,angdeg] = lattice_parameters(win)
%
% Input:
% ------
%   win     Array of sqw objects of sqw type
% 
% Output:
% -------
%   alatt   Lattice parameters [a,b,c] (row vector, Ang)
%   angdeg  Lattice angles [alf,bet,gam] (row vector, degrees)
%   ok      Logical flag: =true if all ok, otherwise =false;
%   mess    Error message; empty if OK, non-empty otherwise
%
%
% It is assumed that the lattice parameters are all the same within one sqw object

h_ave=header_average(win(1).header);

alatt=h_ave.alatt;
angdeg=h_ave.angdeg;
ok=true;
mess='';

small=2e-7;
for i=2:numel(win)
    h_ave=header_average(win(i).header);
    if any(abs(h_ave.alatt-alatt)>small) || any(abs(h_ave.angdeg-angdeg)>small)
        alatt=[0,0,0];
        angdeg=[0,0,0];
        ok=false;
        mess='Lattice parmaeters are not all the same in the array of objects';
        if nargout<3, error(mess), else return, end
    end
end
