% this file should be placed in /Debug /Release folders to enable running Matlab mex-file unit test test_hdf_pix_group
%
horace_on();
this_path = pwd;
m_path = fileparts(fileparts(fileparts(this_path)));
addpath(m_path);
tc = test_hdf_pix_group();
