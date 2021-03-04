function build_version_h(pack_folder)
% Build Horace/herbert version file used by C++ code
%
% Input: location of the upper root folder of the package (where
% _LowLevelCode is located)
%
% using predefined
%
version_file = 'version.h';
ver_file_fp = fullfile(pack_folder,'_LowLevelCode','cpp','utility',version_file);
if is_file(ver_file_fp)
    return;
end
[~,pack_name] = fileparts(pack_folder);
%
version_template = fullfile(pack_folder,'VERSION');
fh_source = fopen(version_template );
if fh_source<1
    error('HERBERT_MEX:runtime_error',...
        ' Can not open version template %s',...
        version_template);
end
clob_in = onCleanup(@()fclose(fh_source));
ver = fscanf(fh_source,'%s');
%
fh_targ = fopen(ver_file_fp,'w');
clob_ou = onCleanup(@()fclose(fh_targ));
fprintf(fh_targ,['namespace %s {\n',...
    '    constexpr char VERSION[] = "%s from %s";\n}'],...
    pack_name,ver,date);
