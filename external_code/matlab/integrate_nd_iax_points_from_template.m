function integrate_nd_iax_points_from_template
% Create functions from template
substr_in={'integrate_nd_iax_points_template','iax=1','ndim=2','(ib,:)','(ilo,:)','(ihi,:)',...
    '(ml-1,:)','(ml,:)','(mu,:)','(mu+1,:)','(ml:mu-1,:)','(ml+1:mu-1,:)','(ml+1:mu,:)'};

substr_out{1}={'integrate_1d_points',  'iax=1','ndim=1','(ib)','(ilo)',    '(ihi)',...
    '(ml-1)','(ml)','(mu)','(mu+1)','(ml:mu-1)','(ml+1:mu-1)','(ml+1:mu)'};

substr_out{2}={'integrate_2d_x_points','iax=1','ndim=2','(ib,:)','(ilo,:)',  '(ihi,:)',...
    '(ml-1,:)','(ml,:)','(mu,:)','(mu+1,:)','(ml:mu-1,:)','(ml+1:mu-1,:)','(ml+1:mu,:)'};

substr_out{3}={'integrate_2d_y_points','iax=2','ndim=2','(:,ib)','(:,ilo)',  '(:,ihi)',...
    '(:,ml-1)','(:,ml)','(:,mu)','(:,mu+1)','(:,ml:mu-1)','(:,ml+1:mu-1)','(:,ml+1:mu)'};

substr_out{4}={'integrate_3d_x_points','iax=1','ndim=3','(ib,:,:)','(ilo,:,:)','(ihi,:,:)',...
    '(ml-1,:,:)','(ml,:,:)','(mu,:,:)','(mu+1,:,:)','(ml:mu-1,:,:)','(ml+1:mu-1,:,:)','(ml+1:mu,:,:)'};

substr_out{5}={'integrate_3d_y_points','iax=2','ndim=3','(:,ib,:)','(:,ilo,:)','(:,ihi,:)',...
    '(:,ml-1,:)','(:,ml,:)','(:,mu,:)','(:,mu+1,:)','(:,ml:mu-1,:)','(:,ml+1:mu-1,:)','(:,ml+1:mu,:)'};

substr_out{6}={'integrate_3d_z_points','iax=3','ndim=3','(:,:,ib)','(:,:,ilo)','(:,:,ihi)',...
    '(:,:,ml-1)','(:,:,ml)','(:,:,mu)','(:,:,mu+1)','(:,:,ml:mu-1)','(:,:,ml+1:mu-1)','(:,:,ml+1:mu)'};

% Read in template file, removing special comment lines
template_file='integrate_nd_iax_points_template.m';
tstr=read_text(template_file);
ok=true(numel(tstr),1);
for i=1:numel(tstr)
    if numel(tstr{i})>=2 && strcmp(tstr{i}(1:2),'%!')
        ok(i)=false;
    end
end
tstr=tstr(ok);

% Create output files, if necessary
for i=1:numel(substr_out)
    create_output_file(tstr,[substr_out{i}{1},'.m'],substr_in,substr_out{i});
end

%----------------------------------------------------------------------------------------
function create_output_file(tstr,output_file,substr_in,substr_out)

% Create output 
opstrnew=tstr;
for i=1:numel(substr_in)
    opstrnew=strrep(opstrnew,substr_in{i},substr_out{i});
end

% See if existing file needs to be replaced
if ~isempty(output_file)
    if ~isempty(dir(output_file))
        opstr=read_text(output_file);
        if numel(opstr)==numel(opstrnew) && isequal(opstr,opstrnew)
            return
        end
    end
end

% Write output
fid=fopen(output_file,'wt');
if fid<0
    error(['Problem writin to ',output_file])
end
for i=1:numel(opstrnew)
    fprintf(fid,'%s\n', opstrnew{i});
end
fclose(fid);
