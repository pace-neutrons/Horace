function grid_size = gensqw_write_all_tmp(spe_data,par_file,tmp_file,efix,emode,alatt,angdeg,...
                           u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange)

 % Write temporary sqw output file(s) (these can be deleted if all has gone well once gen_sqw has been run)
    % --------------------------------------------------------------------------------------------------------    
nfiles = numel(tmp_file);

nt=bigtic();
for i=1:nfiles
        disp('--------------------------------------------------------------------------------')
        disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
        grid_size_tmp = write_spe_to_sqw (spe_data{i}, par_file, tmp_file{i}, efix(i), emode, alatt, angdeg,...
            u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i), grid_size_in, urange);
        if i==1
            grid_size = grid_size_tmp;
        else
            if ~all(grid_size==grid_size_tmp)
                error('Logic error in code calling write_spe_to_sqw')
            end
        end
end
bigtoc(nt);
