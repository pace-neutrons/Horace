function [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
% Normal use:
%   >> gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input: (in the following, nfile = no. spe files)
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   spe_file        Full file name of spe file - character string or cell array of
%                       character strings for more than one file
%   par_file          Full file name of detector parameter file (Tobyfit format)
%   sqw_file         Full file name of output sqw file
%   efix                Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt              Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u                  First vector (1x3) defining scattering plane (r.l.u.)
%   v                  Second vector (1x3) defining scattering plane (r.l.u.)
%   psi                Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi              Correction to psi (deg)            [scalar or vector length nfile]
%   gl                  Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs                Small goniometer arc angle (deg)   [scalar or vector length nfile]
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. Default is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                                       that encloses the whole data range.

%
% Output:
% --------
%   tmp_file        List of temporary files
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid

% T.G.Perring  14 August 2007


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method 
    error('Check type of input arguments')
end

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin>=15 && nargin<=17)
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


%-------------------------------------------->
if get(hor_config,'use_herbert')
    % this is function -- adapter as everything below runs from runfiles;
    run_files = gen_runfiles(spe_file, par_file,alatt,angdeg,efix,psi,omega,dpsi,gl,gs);
    % If no input data range provided, calculate it from the files
    if ~urange_given
        urange = rundata_find_urange(dummy,run_files,emode,u,v);        
    end    
    
    nfiles         = numel(run_files);
    tmp_file = cell(1,nfiles);
    if nfiles ==1
        tmp_file='';    % temporary file not created, so to avoid misleading return argument, set to empty string
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
        [grid_size,urange,tmp_file{1}] = rundata_write_to_sqw (dummy,run_files{1},emode,u,v, grid_size_in, urange);
    else
        nt=bigtic();
        for i=1:nfiles
            disp('--------------------------------------------------------------------------------')
            disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
            [grid_size_tmp,urange,tmp_file{i}] = rundata_write_to_sqw(dummy,run_files{i},emode,u,v,grid_size_in, urange);
            if i==1
                grid_size = grid_size_tmp;
            else
                if ~all(grid_size==grid_size_tmp)
                    error('Logic error in code calling write_spe_to_sqw')
                end
            end
        end        
        bigtoc(nt);
    end
    % Create single sqw file combining all intermediate sqw files
    % ------------------------------------------------------------
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    write_nsqw_to_sqw (tmp_file, sqw_file);

    disp('--------------------------------------------------------------------------------')

    return;
end

% Check input arguments
% ------------------------
[efix,psi,omega,dpsi,gl,gs]=gensqw_check_input_arg( dummy,spe_file, par_file, sqw_file, efix,...
                                                            psi, omega, dpsi, gl, gs);

% generate the list of input data classess  
[spe_data,tmp_file] = gensqw_build_input_datafiles(dummy,spe_file,sqw_file);


% If no input data range provided, calculate it from the files
if ~urange_given
    urange = gensqw_find_urange(dummy,spe_data,par_file,...
             efix,emode,alatt, angdeg,u,v, omega, dpsi, gl, gs);    
end    

nfiles = numel(spe_data);
if nfiles==1
    tmp_file='';    % temporary file not created, so to avoid misleading return argument, set to empty string
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    grid_size = write_spe_to_sqw (spe_data{1}, par_file, sqw_file, efix(1), emode, alatt, angdeg,...
                                  u, v, psi(1), omega(1), dpsi(1), gl(1), gs(1), grid_size_in, urange);
else
 % write tmp file and combine them into single sqw file;
   grid_size = gensqw_write_all_tmp(spe_data,par_file,tmp_file,efix,emode,alatt,angdeg,...
                                 u, v, psi, omega, dpsi, gl, gs,...
                                 grid_size_in, urange);
    

    % Create single sqw file combining all intermediate sqw files
    % ------------------------------------------------------------
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    if get(hdf_config,'use_hdf')
        sqwh = sqw_hdf(sqw_file,tmp_file);
        delete(sqwh);
    else    
        write_nsqw_to_sqw (tmp_file, sqw_file);
    end
    disp('--------------------------------------------------------------------------------')
end

% Delete temporary files as user will presumably use hdf and tmp files
if get(hor_config,'delete_tmp')
    if ~isempty(tmp_file)   % will be empty if only one spe file
        tmp_path=fileparts(tmp_file{1});
        delete([tmp_path,filesep,'*.tmp']);
    end
end


% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
