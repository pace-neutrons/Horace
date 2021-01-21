function [tmp_file,grid_size,pix_range] = accumulate_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                u, v, psi, psi_planned, omega, dpsi, gl, gs, grid_size_in, pix_range_in)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
% T.G.Perring  14 August 2007

% Modified 23/10/2010 by R.A. Ewings from gen_sqw

% -------------------------------------------
error(' This function is deprecated; Use gen_sqw with the same parameters and ''accumulate'' key instead')

