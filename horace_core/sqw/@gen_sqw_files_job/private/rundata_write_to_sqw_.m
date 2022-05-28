function [grid_size, pix_range,update_runlabels] = rundata_write_to_sqw_(run_files, sqw_file, ...
    grid_size_in, pix_db_range, write_banner)
% Read a single rundata object, and create a single sqw file.
%
%   >> [grid_size, pix_range] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, pix_range_in, instrument, sample)
%
% Input:
% ------
%   run_file        Cell array of initiated rundata objects
%   sqw_file        Cell array of full file names of output sqw files
%   grid_size_in    Scalar or row vector of grid dimensions.
%   pix_db_range   Range of data grid to rebin on. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%   instrument      Array of structures or objects containing instrument information
%   sample          Array of structures or objects containing sample geometry information
%   write_banner    =true then write banner; =false then done (no banner will be
%                   written anyway if the output logging level is not high enough)
%
% Output:
% -------
% grid_size       -  Actual grid size used (size is unity along dimensions
%                    where there is zero range of the data points)
% pix_range       -  Actual range of grid, should be different from
%                    pix_range_in only if pix_range_in is not provided
% update_runlabels-  if true, each run-id for every runfile has to be
%                    modified as some runfiles have the same run-id(s).
%                    This possible e.g. in "replicate" mode.


% Original author: T.G.Perring

nfiles = numel(run_files);
if nfiles == 0
    grid_size = grid_size_in;
    pix_range = pix_db_range;
    update_runlabels = false;
    return
end

hor_log_level=get(hor_config,'log_level');
%

mpi_obj= MPI_State.instance();
running_mpi = mpi_obj.is_deployed;

%
% bin_range = arrayfun(@(x,y,z)get_cut_range(x,y,z),...
%     pix_db_range(1,:),pix_db_range(2,:),grid_size_in,'UniformOutput',false);
run_id = zeros(1,nfiles);
for i=1:nfiles
    if hor_log_level>-1 && write_banner
        disp('--------------------------------------------------------------------------------')
        disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
        disp(' ')
    end
    %
    run_id(i) = run_files{i}.run_id;
    [w,grid_size_tmp,pix_range_tmp] = run_files{i}.calc_sqw(grid_size_in, pix_db_range);
    if i==1
        grid_size = grid_size_tmp;
        pix_range = pix_range_tmp;
    else
        if ~all(grid_size==grid_size_tmp)
            error('Logic error in calc_sqw - probably sort_pixels auto-changing grid. Contact T.G.Perring')
        end
        pix_range = [min([pix_range_tmp(1,:);pix_range(1,:)],[],1);...
            max([pix_range_tmp(2,:);pix_range(2,:)],[],1)];
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
unique_runid = unique(run_id);
update_runlabels = numel(unique_runid) ~= nfiles || any(isnan(unique_runid));
