function [urange,u_to_rlu] = gensqw_find_urange(dummy,spe_data,par_file,...
                             efix,emode,alatt, angdeg,u,v, omega, dpsi, gl, gs)

% Get limits of data for grid on which to store sqw data
% ---------------------------------------------------------
% Use the fact that the lowest and highest energy transfer bin centres define the maximum extent in
% momentum and energy. We calculate using the full detector table i.e. do not account for masked detectors
% but this is reasonable so long as not many detecotrs are masked. 
% (*** In more systematic cases e.g. spe file is for MARI, and impose a mask file that leaves only the
%  low angle detectors, then the calculation will be off. Will bw able to rectify this once use
%  libisis run file structure, when can enquire of masked detectors from the IXTrunfile object)

nfiles = numel(spe_data);

disp('--------------------------------------------------------------------------------')
disp(['Calculating limits of data from ',num2str(nfiles),' spe files...'])
    % Read in the detector parameters if they are present in spe_data
if ~get(hor_config,'use_par_from_nxspe') % have to use par file;
    det =get_par(par_file);      % should throw if par file is not found
else                                     % get detectors from par file
    det =getPar(spe_data{1});                 
    if isempty(det)                  % try to find and analyse par file
      det =get_par(par_file);        % should throw if par file is not found            
    end
end
% Get the maximum limits along the projection axes across all spe files
data.filename='';
data.filepath='';
ndet=length(det.group);
data.S=zeros(2,ndet);
data.E=zeros(2,ndet);
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
for i=1:nfiles
    % if trying to use par from nxspe, each nxspe may have its own
    % detectors par, so -- reading in a loop; This would allow
    % combinining different instruments?
    if get(hor_config,'use_par_from_nxspe')
        det = getPar(spe_data{i});
        if isempty(det)  % try to use ascii par file as back-up option
            det =get_par(par_file);               
        end
    end
    eps=(spe_data{i}.en(2:end)+spe_data{i}.en(1:end-1))/2;
    if length(eps)>1
        data.en=[eps(1);eps(end)];
    else
        data.en=eps;
    end
    [u_to_rlu, ucoords] = calc_projections (efix(i), emode, alatt, angdeg, u, v, psi(i), ...
        omega(i), dpsi(i), gl(i), gs(i), data, det);
    urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
end
clear data det ucoords % Tidy memory


