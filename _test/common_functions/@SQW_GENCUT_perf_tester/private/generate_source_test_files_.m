function [filelist,smpl_data_size] = generate_source_test_files_(obj,varargin)
% generate fake source files used in performance tests
%
n_files = obj.n_files_to_use;
if n_files ==0
    filelist = {};
    smpl_data_size = 0;
    return;
end
filelist = cell(n_files,1);
if obj.build_sqw_file_directly
    file_name_form = [obj.template_name_form_,'.tmp'];
    if is_file(obj.sqw_file)
        hh = head_sqw(obj.sqw_file);
        smpl_data_size = hh.npixels;
        nf = hh.nfiles;
        if nf == n_files
            % if proper file already exist, do not add it to delete list.
            % we are probably in the place, where tests are debugged and do
            % not want to wait for creating the file each time.
            filelist = {};
            return;
        end
    end
else
    file_name_form = [obj.template_name_form_,'.nxspe'];
end
for i=1:n_files
    filelist{i} = sprintf(file_name_form,i);
end

[psi,efix,alatt,angdeg,u,v,omega,dpsi,gl,gs,...
    en,par_file,alatt_true,angdeg_true,qfwhh,efwhh,rotvec]=obj.gen_sqw_parameters();

% Create sqw file for performance testing
% --------------------------------------
[pix_range,ndet] = calc_sqw_pix_range (efix, 1, en(1), en(end), par_file, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

smpl_data_size = ndet*obj.num_energy_bins;
for i=1:n_files
    filelist{i}=fullfile(obj.working_dir,filelist{i});
    if is_file(filelist{i})
        continue;
    end
    wtmp=dummy_sqw (en, par_file, '', efix, 1, alatt, angdeg,...
        u, v, psi(i), omega, dpsi, gl, gs, [50,50,50,50], pix_range);
    % Simulate cross-section on all the sqw files: place blobs at Bragg positions of the true lattice
    wtmp=sqw_eval(wtmp{1},@make_bragg_blobs,{[1,qfwhh,efwhh],[alatt,angdeg],[alatt_true,angdeg_true],rotvec,1});
    
    
    if obj.build_sqw_file_directly
        save(wtmp,filelist{i});
    else
        rd = rundatah(wtmp);
        rd.saveNXSPE(filelist{i});
    end
end
%

if obj.build_sqw_file_directly
    write_nsqw_to_sqw(filelist,obj.sqw_file);
    hc = hor_config;
    if hc.delete_tmp
        if isempty(obj.test_source_files_list_)
            obj.test_source_files_list_ = filelist;
        else
            obj.test_source_files_list_ = [obj.test_source_files_list_(:),filelist(:)];
        end
        obj.delete_tmp_files();
    end
    filelist = {obj.sqw_file};
end
