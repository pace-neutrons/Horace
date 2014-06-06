function urange = rundata_find_urange(run_files)
% Find range of data in crystal Cartesian coordinates
%
%   >> urange = rundata_find_urange(run_files)
%
% Input:
% ------
%   run_files 	Cell array of initiated rundata objects
%
% Output:
% -------
%   urange    	2x4 array, describing min-max values in momentum/energy
%              transfer, in crystal Cartesian coordinates and meV. Uses bin centres.


nfiles = numel(run_files);

% Get the maximum limits along the projection axes across all spe files
data.filename='';
data.filepath='';
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
det_buff=[];    % buffer of detector information
for i=1:nfiles
    [efix,en,emode,ndet,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=get_rundata(run_files{i},...
        'efix','en','emode','n_detectors','alatt','angdeg','u','v','psi','omega','dpsi','gl','gs','det_par',...
        '-rad');
    if isempty(det_buff) || ~isequal(det,det_buff)
        detdcn=calc_detdcn(det);
        det_buff=det;
    end
    
    eps=(en(2:end)+en(1:end-1))/2;
    if length(eps)>1
        data.S=zeros(2,ndet);
        data.ERR=zeros(2,ndet);
        data.en=[eps(1);eps(end)];
    else
        data.S=zeros(1,ndet);
        data.ERR=zeros(1,ndet);
        data.en=eps;
    end
    
    [u_to_rlu, urange1] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det, detdcn);
    urange = [min(urange(1,:),urange1(1,:)); max(urange(2,:),urange1(2,:))];
end
