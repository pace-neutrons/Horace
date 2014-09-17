function [grid_size, urange] = rundata_write_to_sqw (run_files, sqw_file, grid_size_in, urange_in, instrument, sample,...
                                                        sparse_format, write_banner)
% Read a cell array of rundata objects, and create a set of sqw files.
%
%   >> [grid_size, urange] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample,...
%                                                       sparse_format, write_banner)
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
%   sparse_format   =true then create sqw files in sparse format; if false then standard sqw files
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

horace_info_level=get(hor_config,'horace_info_level');

% ==== *** TGP 27/05/14: are these lines necessary (will need to be done for each file if are)
% % detector's information into memory
% if isa(run_file,'rundata')
%     run_file = get_rundata(run_file,'det_par','-this');
% end

data = struct();
det_buff=[];    % buffer of detector information

for i=1:nfiles
    if horace_info_level>-1 && write_banner
        disp('--------------------------------------------------------------------------------')
        disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
        disp(' ')
    end
    
    % Read spe file and detector parameters
    % -------------------------------------
    % Masked detectors (i.e. containing NaN signal) are removed from data and detectors
    bigtic
    [data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=...
        get_rundata(run_files{i},'S','ERR','en','efix','emode','alatt','angdeg','u','v',...
        'psi','omega','dpsi','gl','gs','det_par','-rad','-nonan');
    [data.filepath,data.filename]=get_source_fname(run_files{i});
    
    % Note: algorithm updates only if not already read from disk
    % Get the list of all detectors, including the detectors corresponding to masked detectors
    det0 = get_rundata(run_files{i},'det_par');
    
    if horace_info_level>-1
        bigtoc('Time to read spe and detector data:')
        disp(' ')
    end
    
    
    % Create sqw object
    % -----------------
    bigtic
    if isempty(det_buff) || ~isequal(det,det_buff)
        detdcn=calc_detdcn(det);
        det_buff=det;
    end
    [w, grid_size_tmp, urange_tmp]=calc_sqw(efix, emode, alatt, angdeg, u, v, psi,...
        omega, dpsi, gl, gs, data, det, detdcn, det0, grid_size_in, urange_in, instrument(i), sample(i), sparse_format);
    if i==1
        grid_size = grid_size_tmp;
        urange = urange_tmp;
    else
        if ~all(grid_size==grid_size_tmp) || ~all(urange(:)==urange_tmp(:))
            error('Logic error in calc_sqw - probably sort_pixels auto-changing grid. Contact T.G.Perring')
        end
    end
    
    % RHEL bug try to go around it
    hc = hor_config();
    if hc.estimate_processing_time
        time = bigtoc;
        increase_threads = hc.check_time_acceptable(time(1));
        if increase_threads>0
            warning('SQW:rundata_to_sqw','Thread pool increased to 8')
            hc.threads = 8;
        elseif increase_threads<0
            warning('SQW:rundata_to_sqw','Thread pool decreased to 1')
            hc.threads = 1;
        end
    end
    
    
    if horace_info_level>-1
        bigtoc('Time to convert from spe to sqw data:',horace_info_level)
        disp(' ')
    end
    
    
    % Write sqw object
    % ----------------
    bigtic
    if ~sparse_format
        save(w,sqw_file{i});
    else
        [ok,mess]=put_sqw (sqw_file{i},w);
        if ~isempty(mess)
            error(['Error saving to file: ',mess])
        end
    end
    
    if horace_info_level>-1
        bigtoc('Time to save sqw data to file:',horace_info_level)
    end
    
end
