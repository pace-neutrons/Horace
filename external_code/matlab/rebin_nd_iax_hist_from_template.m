function rebin_nd_iax_hist_from_template
% Create functins from template
substr_in={'rebin_nd_iax_hist_template','iax=1','ndim=2','(iin,:)','(iout,:)'};

substr_out{1}={'rebin_1d_hist',  'iax=1','ndim=1','(iin)',    '(iout)'};
% substr_out{2}={'rebin_2d_x_hist','iax=1','ndim=2','(iin,:)',  '(iout,:)'};
% substr_out{3}={'rebin_2d_y_hist','iax=2','ndim=2','(:,iin)',  '(:,iout)'};
% substr_out{4}={'rebin_3d_x_hist','iax=1','ndim=3','(iin,:,:)','(iout,:,:)'};
% substr_out{5}={'rebin_3d_y_hist','iax=2','ndim=3','(:,iin,:)','(:,iout,:)'};
% substr_out{6}={'rebin_3d_z_hist','iax=3','ndim=3','(:,:,iin)','(:,:,iout)'};

% Read in template file, removing special comment lines
template_file='rebin_nd_iax_hist_template.m';
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
        if numel(opstr)==numel(opstrnew) && opstr==opstrnew
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
