function fake_data(indir,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi_min,psi_max,...
                   omega,dpsi,gl,gs)
% Function to make a fake sqw data file so that you can see what range of
% reciprocal space will be covered for a particular incident energy and
% range of angles.
%
% ********************************************************************************
%    DEPRECATED FUNCTION:
%       Please replace this call to fake_data with one to fake_sqw which is
%       much more flexible. Note that the argument list is a bit different.
% ********************************************************************************
%
%   >> fake_data(indir,par_file,sqw_file,ei,emode,alatt,angdeg,u,v,psi_min,psi_max,...
%                omega,dpsi,gl,gs);
%
% Input:
% ------
%   indir       Directory in which the fake sqw file will be created
%   par_file    Detector parameter file for the instrument used
%   sqw_file    File name (without path) of fake sqw file
%   efix        Fixed incident or final energy in meV
%   emode       Direct geometry=1, indirect geometry=2
%   alatt       Lattice parameters in form [a,b,c]
%   angdeg      Lattice angles in form [alpha,beta,gamma] (degrees)
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi         Angle of u w.r.t. incident beam (deg) 
%   psi_min     Minimum value of psi (angle of u w.r.t. incident beam (deg))
%   psi_max     Maximum value of psi
% Crystal orientation refinement angles:
%   omega       Angle of axis of small goniometer arc w.r.t. notional u (deg)
%   dpsi        Correction to psi (deg)
%   gl          Large goniometer arc angle (deg)
%   gs          Small goniometer arc angle (deg)
%
% This function will create an sqw file from 20 fake spe files corresponding
% to 20 steps between psi_min and psi_max. The energy binning will be such
% that there are:
%   10 steps from -0.1*ei/10 to +0.9*ei (direct geometry).
%   19 steps from -0.9*ef/10 to +0.9*ef (indirect geometry).
% This is done to ensure faster execution of the, and not to fill up your
% hard disk with fake data.

disp(' *** DEPRECATED FUNCTION: Please replace this call to fake_data with one to fake_sqw')

% Check input arguments
if ~isempty(indir)
    sqw_file=fullfile(indir,sqw_file);
end

if emode==1
    en=(-1:9)*(efix/10);
elseif emode==2
    en=(-9:9)*(efix/10);
else
    error('emode must =1 (direct geometry) or =2 (indirect geometry)')
end

if psi_min<psi_max && psi_max-psi_min<360
    psi=linspace(psi_min,psi_max,20);
else
    error('Must have psi_min < psi_max and range of psi must be less than 360 degrees')
end

% Make call to fake_sqw
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
