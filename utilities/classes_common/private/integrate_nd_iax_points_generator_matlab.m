function integrate_nd_iax_points_generator_matlab
% Create integration functions for point data from template
%
%   >> integrate_nd_iax_points_generator_matlab
%
% Run from the folder that contains this utility function

% Construct list of files and substitutions:
template_file='integrate_nd_iax_points_template_matlab.m';

output_file={'integrate_1d_points_matlab.m',...
             'integrate_2d_x_points_matlab.m',...
             'integrate_2d_y_points_matlab.m',...
             'integrate_3d_x_points_matlab.m',...
             'integrate_3d_y_points_matlab.m',...
             'integrate_3d_z_points_matlab.m'};

substr_in={'integrate_nd_iax_points_template_matlab','iax=1','ndim=2','(ib,:)','(ilo,:)','(ihi,:)',...
    '(ml-1,:)','(ml,:)','(mu,:)','(mu+1,:)','(ml:mu-1,:)','(ml+1:mu-1,:)','(ml+1:mu,:)'};

substr_out{1}={'integrate_1d_points_matlab',  'iax=1','ndim=1','(ib)','(ilo)',    '(ihi)',...
    '(ml-1)','(ml)','(mu)','(mu+1)','(ml:mu-1)','(ml+1:mu-1)','(ml+1:mu)'};

substr_out{2}={'integrate_2d_x_points_matlab','iax=1','ndim=2','(ib,:)','(ilo,:)',  '(ihi,:)',...
    '(ml-1,:)','(ml,:)','(mu,:)','(mu+1,:)','(ml:mu-1,:)','(ml+1:mu-1,:)','(ml+1:mu,:)'};

substr_out{3}={'integrate_2d_y_points_matlab','iax=2','ndim=2','(:,ib)','(:,ilo)',  '(:,ihi)',...
    '(:,ml-1)','(:,ml)','(:,mu)','(:,mu+1)','(:,ml:mu-1)','(:,ml+1:mu-1)','(:,ml+1:mu)'};

substr_out{4}={'integrate_3d_x_points_matlab','iax=1','ndim=3','(ib,:,:)','(ilo,:,:)','(ihi,:,:)',...
    '(ml-1,:,:)','(ml,:,:)','(mu,:,:)','(mu+1,:,:)','(ml:mu-1,:,:)','(ml+1:mu-1,:,:)','(ml+1:mu,:,:)'};

substr_out{5}={'integrate_3d_y_points_matlab','iax=2','ndim=3','(:,ib,:)','(:,ilo,:)','(:,ihi,:)',...
    '(:,ml-1,:)','(:,ml,:)','(:,mu,:)','(:,mu+1,:)','(:,ml:mu-1,:)','(:,ml+1:mu-1,:)','(:,ml+1:mu,:)'};

substr_out{6}={'integrate_3d_z_points_matlab','iax=3','ndim=3','(:,:,ib)','(:,:,ilo)','(:,:,ihi)',...
    '(:,:,ml-1)','(:,:,ml)','(:,:,mu)','(:,:,mu+1)','(:,:,ml:mu-1)','(:,:,ml+1:mu-1)','(:,:,ml+1:mu)'};

% Generate code
aaa_generate_mcode_from_template (template_file, output_file, substr_in, substr_out)
