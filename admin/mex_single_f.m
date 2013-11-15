function   mex_single_f(in_dir,out_dir,lib_dir,varargin)
% build a single mex fortran routine from the list of files and objects
% provided in varargin.
%
%  -o      if switch is selected, the string, which follows to the
%          switch defines the name of the target mex file.
% if this option is not present, the name of the target mex file assumed to
% be the name of the first file in varargin
%
% -missing if switch is present, routine will build only missing mex files
%          it will rebuild exisign mex files otherwise
%


if nargin<3
    error('MEX_SINGLE:invalid_argument','needs at least three arguments, but got %d',nargin)
end
outdir = fullfile(out_dir,'');
% remove empty fields
argi = varargin(~ismember(varargin,''));
% PROCESSING INPUT KEYS
% do we want build all mex files or just the missing one.
rebuild_mex=true;
if ismember('-missing',argi)
    rebuild_mex=false;
    argi = argi(~ismember(argi,'-missing'));
end

% if target file name is different from the mex file name, choose the file name requested;
if ismember('-o',argi )
    nofile = ismember(argi,'-o');
    ind    = find(nofile);
    if numel(ind) > 1
        error('MEX_SINGLE:invalid_argument',' more then 1 -o option find in input arguments');
    end
    [f_path,f_name]=fileparts(argi{ind+1});   
    % this is not a source file but the target file name
    nofile(ind+1) = true;
    target_fname = [f_name,'.',mexext];    
    files  = argi (~nofile);        
else
    files  = argi;
    [f_path,f_name]=fileparts(files{1});
    % identify target file name
    target_fname = [f_name,'.',mexext];
end

% strip possible empty cells
ic=0;
for i=1:numel(files)
    if ~isempty(files{i})
        ic=ic+1;        
        files{ic} = make_filename(in_dir,files{i});
    end
end
files=files(1:ic);


targ_file=fullfile(outdir,target_fname);    
if exist(targ_file,'file')
    if rebuild_mex
        try
            delete(targ_file)
        catch
            cd(old_path);
            error([' file: ',f_name,mexext,' locked. deleteon error: ',lasterr()]);
        end
    else
        return;
    end
end

fprintf('%s',['===>Mex file creation from: ',f_name,' ...'])
%mex('-v','-outdir',outdir,files{:});
mex(['-I',lib_dir],'-outdir',outdir,'-output',target_fname,files{:});
disp(' <=== completed');


