function [urange,u_to_rlu] = rundata_find_urange(dummy_sqw,run_files,emode,u,v)
%function used to calculate the momentum and energy spawn, achieved in 
%set of experiments, described by the list of the run files
% Inputs:
% sqw class  -- not used present to get access to private sqw function calc_projections
% run_files  -- cell array of initiated by different experiment instances of rundata class
% emode      -- analysis mode
%   u        --   First vector (1x3) defining scattering plane (r.l.u.)
%   v        --    Second vector (1x3) defining scattering plane (r.l.u.)
% Outputs:
%  urange      2x4 array, describing min-max values in momentum/energy
%              transfer space
%  u_to_rlu    Matrix (3x3) of crystal Cartesian axes in reciprocal lattice units
%              i.e. u_to_rlu(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in the
%              crystal Cartesian axes to r.l.u.: v_rlu = u_to_rlu * v_crystal_Cart
%              (Same as inv(B) in Busing and Levy convention)
%

nfiles = numel(run_files);

disp('--------------------------------------------------------------------------------')
disp(['Calculating limits of data from ',num2str(nfiles),' spe files...'])
% Get the maximum limits along the projection axes across all spe files
data.filename='';
data.filepath='';
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
for i=1:nfiles
    [efix,en,ndet,alatt,angdeg,psi,omega,dpsi,gl,gs,det]=get_rundata(run_files{i},...
        'efix','en','n_detectors','alatt','angldeg','psi','omega','dpsi','gl','gs','det_par',...
        '-hor','-rad');
    eps=(en(2:end)+en(1:end-1))/2;
    if length(eps)>1
        data.S=zeros(2,ndet);
        data.E=zeros(2,ndet);
        data.en=[eps(1);eps(end)];
    else
        data.S=zeros(1,ndet);
        data.E=zeros(1,ndet);
        data.en=eps;
    end
    [u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, ...
        omega, dpsi, gl, gs, data, det);
    urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
end
