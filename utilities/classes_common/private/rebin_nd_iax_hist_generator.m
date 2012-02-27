function rebin_nd_iax_hist_generator(target_dir)
% Create rebin functions for histogram data from template
%
%   >> rebin_nd_iax_hist_generator
% Inputs:
% target_dif -- if present, specifies the folder for target files to place
%               into. if the folder does not exist, it will be created
%
%
% Run from the folder that contains this utility function

% Construct list of files and substitutions:
template_file='rebin_nd_iax_hist_template.m';

output_file={'rebin_1d_hist.m',...
             'rebin_2d_x_hist.m',...
             'rebin_2d_y_hist.m',...
             'rebin_3d_x_hist.m',...
             'rebin_3d_y_hist.m',...
             'rebin_3d_z_hist.m'};

if nargin>0
    if ~exist(target_dir,'dir')
        mkdir(target_dir);
    end
    for i=1:numel(output_file)
        output_file{i}=fullfile(target_dir,output_file{i});
    end
end         
         
substr_in={'rebin_nd_iax_hist_template','iax=1','ndim=2'};

substr_out{1}={'rebin_1d_hist',  'iax=1','ndim=1'};
substr_out{2}={'rebin_2d_x_hist','iax=1','ndim=2'};
substr_out{3}={'rebin_2d_y_hist','iax=2','ndim=2'};
substr_out{4}={'rebin_3d_x_hist','iax=1','ndim=3'};
substr_out{5}={'rebin_3d_y_hist','iax=2','ndim=3'};
substr_out{6}={'rebin_3d_z_hist','iax=3','ndim=3'};

% Generate code
aaa_generate_mcode_from_template (template_file, output_file, substr_in, substr_out)
