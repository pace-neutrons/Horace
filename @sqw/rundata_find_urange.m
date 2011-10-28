function [urange,u_to_rlu] = rundata_find_urange(dummy_sqw,run_files,emode,u,v)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

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
               
           
    data.S=zeros(2,ndet);
    data.E=zeros(2,ndet);
              
    eps=(en(2:end)+en(1:end-1))/2;
    if length(eps)>1
            data.en=[eps(1);eps(end)];
    else
            data.en=eps;
    end
    [u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, ...
            omega, dpsi, gl, gs, data, det);
     urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
end


