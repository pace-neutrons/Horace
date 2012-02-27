function integrate_nd_iax_points_generator(target_dir)
% Create integration functions for point data from template
%
%>> integrate_nd_iax_points_generator
%
% Inputs:
% target_dif -- if present, specifies the folder for target files to place
%               into. if the folder does not exist, it will be created
%
% Run from the folder that contains this utility function

% Construct list of files and substitutions:
template_file='integrate_nd_iax_points_template.m';

output_file={'integrate_1d_points.m',...
             'integrate_2d_x_points.m',...
             'integrate_2d_y_points.m',...
             'integrate_3d_x_points.m',...
             'integrate_3d_y_points.m',...
             'integrate_3d_z_points.m'};
if nargin>0
    if ~exist(target_dir,'dir')
        mkdir(target_dir);
    end
    for i=1:numel(output_file)
        output_file{i}=fullfile(target_dir,output_file{i});
    end
end

substr_in={'integrate_nd_iax_points_template','iax=1','ndim=2'};

substr_out{1}={'integrate_1d_points',  'iax=1','ndim=1'};
substr_out{2}={'integrate_2d_x_points','iax=1','ndim=2'};
substr_out{3}={'integrate_2d_y_points','iax=2','ndim=2'};
substr_out{4}={'integrate_3d_x_points','iax=1','ndim=3'};
substr_out{5}={'integrate_3d_y_points','iax=2','ndim=3'};
substr_out{6}={'integrate_3d_z_points','iax=3','ndim=3'};

% Generate code
aaa_generate_mcode_from_template (template_file, output_file, substr_in, substr_out)
