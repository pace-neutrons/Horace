function [grid_size, urange] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample)
% Read a single rundata object, and create a single sqw file.
%
%   >> [grid_size, urange] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample)
%
% Input:
% ------
%   run_file        Fully initiated by rundata information instance of @rundata class
%   sqw_file        Full file name of output sqw file
%   grid_size_in    Scalar or row vector of grid dimensions.
%   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%   instrument      Structure or object containing instrument information
%   sample          Structure or object containing sample geometry information
%
% Output:
% -------
%   grid_size       Actual grid size used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


bigtic
% detector's information into memory
if isa(run_file,'rundata')
    run_file = get_rundata(run_file,'det_par','-this');
end

% Read spe file and detector parameters
% -------------------------------------
% Masked detectors (i.e. containing NaN signal) are removed from data and detectors



data = struct();
[data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=...
    get_rundata(run_file,'S','ERR','en','efix','emode','alatt','angldeg','u','v',...
                         'psi','omega','dpsi','gl','gs','det_par','-hor','-rad','-nonan');

[data.filepath,data.filename]=get_source_fname(run_file);

% Note: algorithm updates only if not already read from disk
% Get the list of all detectors, including the detectors corresponding to masked detectors
det0 = get_rundata(run_file,'det_par','-hor');


horace_info_level=get(hor_config,'horace_info_level');

% Create sqw object
% -----------------
[w, grid_size, urange]=calc_sqw(efix, emode, alatt, angdeg, u, v, psi,...
    omega, dpsi, gl, gs, data, det, det0, grid_size_in, urange_in, instrument, sample);
	
if horace_info_level>-1
	bigtoc('Time to convert from spe to sqw data:')
	disp(' ')
end


% Write sqw object
% ----------------
bigtic
save(w,sqw_file);
if horace_info_level>-1
	bigtoc('Time to save data to file:')
end
