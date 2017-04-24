function [grid_size, urange] = rundata_write_to_sqw_(run_files, sqw_file, ...
    grid_size_in, urange_in, write_banner)
% Read a single rundata object, and create a single sqw file.
%
%   >> [grid_size, urange] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample)
%
% Input:
% ------
%   run_file        Cell array of initiated rundata objects
%   sqw_file        Cell array of full file names of output sqw files
%   grid_size_in    Scalar or row vector of grid dimensions.
%   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%   instrument      Array of structures or objects containing instrument information
%   sample          Array of structures or objects containing sample geometry information
%   write_banner    =true then write banner; =false then done (no banner will be
%                   written anyway if the output logging level is not low enough)
%
% Output:
% -------
%   grid_size       Actual grid size used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


nfiles = numel(run_files);

[hor_log_level,use_mex]=get(hor_config,'log_level','use_mex');
%
if use_mex % buffer or not the detector's information
    cash_det = {};
else
    cash_det = {'-cash_detectors'};
end


mpi_obj= MPI_State.instance();
running_mpi = mpi_obj.is_deployed;
%
cut_range = arrayfun(@(x,y,z)get_cut_range(x,y,z),...
    urange_in(1,:),urange_in(2,:),grid_size_in,'UniformOutput',false);

for i=1:nfiles
    if hor_log_level>-1 && write_banner
        disp('--------------------------------------------------------------------------------')
        disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
        disp(' ')
    end
    %
    [w,grid_size_tmp,urange_tmp] = run_files{i}.calc_sqw(grid_size_in, urange_in,cash_det{:});
    if ~isempty(run_files{i}.transform_sqw) && ~isempty(urange_in)
        w = cut(w,cut_range{:});
        urange_tmp = urange_in;
        grid_size_tmp = size(w.data.s);
    end
    if i==1
        
        grid_size = grid_size_tmp;
        urange = urange_tmp;
    else
        if isempty(run_files{i}.transform_sqw) &&(~all(grid_size==grid_size_tmp) || ~all(urange(:)==urange_tmp(:)))
            error('Logic error in calc_sqw - probably sort_pixels auto-changing grid. Contact T.G.Perring')
        end
    end 
    
    
    % Write sqw object
    % ----------------
    bigtic
    save(w,sqw_file{i});
    
    if running_mpi
        mpi_obj.do_logging(i,nfiles,[],[]);
    end
    
    if hor_log_level>-1
        bigtoc('Time to save sqw data to file:',hor_log_level)
    end
    
end
function range = get_cut_range(r_min,r_max,n_bins)
% calculate input range 
n_bins = n_bins-1;
if n_bins == 0
    range = [r_min,r_max];
else
    range = [r_min,(r_max-r_min)/n_bins,r_max];
end