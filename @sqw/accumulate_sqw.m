function [tmp_file,grid_size,urange] = accumulate_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                u, v, psi, psi_planned, omega, dpsi, gl, gs, grid_size_in, urange_in)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
% Normal use:
%   >> accumulate_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, psi_planned, omega, dpsi, gl, gs, grid_size_in, urange_in)
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input: (in the following, nfile = no. spe files)
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   spe_file        Full file name of spe file - character string or cell array of
%                  character strings for more than one file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   psi_planned     As psi, but is a vector specifying the full range of planned measurements
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. Default is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range that would be available if psi_planned were used.
%
% Output:
% --------
%   tmp_file        List of temporary files
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid

% T.G.Perring  14 August 2007

% Modified 23/10/2010 by R.A. Ewings from gen_sqw


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method 
    error('Check type of input arguments')
end

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin>=16 && nargin<=18)
    error('Check number of input arguments')
end

% check if urange is given
urange_given=false;
if exist('urange_in','var')
   if ~(isnumeric(urange_in) && length(size(urange_in))==2 && all(size(urange_in)==[2,4]) && all(urange_in(2,:)-urange_in(1,:)>=0))
            error('urange must be 2x4 array, first row lower limits, second row upper limits, with lower<=upper')
   end
   urange = urange_in;
   urange_given=true;
end

% Set default grid size if none given
if ~exist('grid_size_in','var')
    disp('--------------------------------------------------------------------------------')
    disp('Using default grid size of 50x50x50x50 for output sqw file')
    grid_size_in=[50,50,50,50];
elseif ~(isnumeric(grid_size_in)&&(isscalar(grid_size_in)||(isvector(grid_size_in)&&all(size(grid_size_in)==[1,4]))))
   error ('Grid size must be scalar or row vector length 4')
end     

% Check other input arguments and convert angular values to radians
% ------------------------
[efix,psi,omega,dpsi,gl,gs]=gensqw_check_input_arg( dummy,spe_file, par_file, sqw_file, efix,...
                                                     psi, omega, dpsi, gl, gs);

% generate the list of input data classess  
spe_data = gensqw_build_input_datafiles(spe_file,par_file,alatt,angdeg,efix,psi,omega,dpsi,gl,gs);
nfiles = numel(spe_data);

% If no input data range provided, calculate it from the files
if ~urange_given
    urange = gensqw_find_urange(spe_data,par_file,...
                 efix,emode,alatt, angdeg,u,v, psi,omega, dpsi, gl, gs);    

    disp('Calculating data limits for planned psi');
    eps_lo = zeros(nfiles,1);
    eps_hi = zeros(nfiles,1);
    for i=1:nfiles
        eps_lo(i) = min(spe_data{i}.en);
        eps_hi(i) = max(spe_data{i}.en);        
    end
%    eps=spe_data{1}.en;
%    eps_lo=min(eps); eps_hi=max(eps);


    if isa(spe_data{1},'rundata')
    % by default, rundata returs its values in degrees
        omega_d = omega;
        dpsi_d  = dpsi;
        gl_d = gl;
        gs_d = gs;           
        % get unmasked detector parameters in Horace format
        det =get_rundata(spe_data{1},'det_par','-hor');
    else
   % Convert input angles to radians (except lattice parameters)        
        rad2deg=180/pi;  
        omega_d = omega.*rad2deg;
        dpsi_d  = dpsi.*rad2deg;
        gl_d = gl.*rad2deg;
        gs_d = gs.*rad2deg;
        % get detector parameters 
        [data,det_masked,keep,det]=get_data(spe_data{1}, par_file);        
    end
    if numel(psi_planned) ~= numel(efix)
        efixI = efix(1);
        eps_loI = eps_lo(1);        
        eps_hiI = eps_hi(1);
        omega_dI = omega_d(1);
        dpsi_dI  = dpsi_d(1);
        gl_dI = gl_d(1);
        gs_dI = gs_d(1);                
    else
        efixI = efix;        
        eps_loI = eps_lo;
        eps_hiI = eps_hi;
        omega_dI = omega_d;
        dpsi_dI  = dpsi_d;
        gl_dI = gl_d;
        gs_dI = gs_d;                        
    end
    
    urange_full=calc_sqw_urange(efixI, emode, eps_loI, eps_hiI, det, alatt, angdeg, u, v,psi_planned , ...
        omega_dI, dpsi_dI, gl_dI, gs_dI);
    %
    %
    if ~(all(urange_full(1,:)<=urange(1,:)) && all(urange_full(2,:)>=urange(2,:)))
        error('Data range calculated from psi_planned is smaller than that required by all the data');
    end
    urange=urange_full;
end

%==========
%Now check if any tmp files that correspond to the required spe files
%already exist. If so, check that their data ranges are correct.
tmp_sqw_path = fileparts(sqw_file);
[tmp_file,testit]=gensqw_check_tmp_files(spe_file,tmp_sqw_path,urange);

testit=testit>=0;
% Write temporary sqw output file(s) (these can be deleted if all has gone well once gen_sqw has been run)
% --------------------------------------------------------------------------------------------------------
% *** should check that the temporary file names do not coincide with spe file names

if nfiles==1
    tmp_file='';    % temporary file not created, so to avoid misleading return argument, set to empty string
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    grid_size = write_spe_to_sqw (spe_data{1}, par_file, sqw_file, efix(1), emode, alatt, angdeg,...
                                  u, v, psi(1), omega(1), dpsi(1), gl(1), gs(1), grid_size_in, urange);
else
 % write tmp file and combine them into single sqw file;
   grid_size = gensqw_write_all_tmp(spe_data(testit),par_file,tmp_file(testit),efix(testit),emode,alatt,angdeg,...
                                 u, v, psi(testit), omega(testit), dpsi(testit), gl(testit), gs(testit),...
                                 grid_size_in, urange);
    
  

    % Create single sqw file combining all intermediate sqw files
    % ------------------------------------------------------------
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    write_nsqw_to_sqw (tmp_file, sqw_file);

    disp('--------------------------------------------------------------------------------')
end  % =============================> spe/par file processing

%========
%Unlike gen_sqw, tmp files are NOT deleted

% % delete temporary files as user will presumably use hdf and tmp files
% % production will be cheap;
% if get(hor_config,'delete_tmp')
%     tmp_path=fileparts(tmp_file{1});
%     delete([tmp_path,filesep,'*.tmp']);
% end
% %

%=========

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
