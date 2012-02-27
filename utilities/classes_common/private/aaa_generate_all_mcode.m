function aaa_generate_all_mcode
% Function that calls all generators of mcode from templates

theGenerator=mfilename('fullpath');
path=fileparts(theGenerator);
% define target folder one folder up to the current
path=fileparts(path);

integrate_nd_iax_points_generator(path);
integrate_nd_iax_points_generator_matlab();
rebin_nd_iax_hist_generator(path);
rebin_nd_iax_hist_generator_matlab();
