function rebin_nd_iax_hist_generator_matlab
% Create rebin functions for histogram data from template
%
%   >> rebin_nd_iax_hist_generator_matlab
%
% Run from the folder that containsa this utility function

% Construct list of files and substitutions:
template_file='rebin_nd_iax_hist_template_matlab.m';

output_file={'rebin_1d_hist_matlab.m',...
             'rebin_2d_x_hist_matlab.m',...
             'rebin_2d_y_hist_matlab.m',...
             'rebin_3d_x_hist_matlab.m',...
             'rebin_3d_y_hist_matlab.m',...
             'rebin_3d_z_hist_matlab.m'};
         
substr_in={'rebin_nd_iax_hist_template_matlab','iax=1','ndim=2','(iin,:)','(iout,:)'};

substr_out{1}={'rebin_1d_hist_matlab',  'iax=1','ndim=1','(iin)',    '(iout)'};
substr_out{2}={'rebin_2d_x_hist_matlab','iax=1','ndim=2','(iin,:)',  '(iout,:)'};
substr_out{3}={'rebin_2d_y_hist_matlab','iax=2','ndim=2','(:,iin)',  '(:,iout)'};
substr_out{4}={'rebin_3d_x_hist_matlab','iax=1','ndim=3','(iin,:,:)','(iout,:,:)'};
substr_out{5}={'rebin_3d_y_hist_matlab','iax=2','ndim=3','(:,iin,:)','(:,iout,:)'};
substr_out{6}={'rebin_3d_z_hist_matlab','iax=3','ndim=3','(:,:,iin)','(:,:,iout)'};

% Generate code
aaa_generate_mcode_from_template (template_file, output_file, substr_in, substr_out)
