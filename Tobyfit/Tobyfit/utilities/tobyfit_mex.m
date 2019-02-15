function tobyfit_mex(varargin)
% Compile and/or test the mex functions used in Tobyfit

% Check options
opt_default = struct('compile',false,'test',false,'which','all');
flagnames = {'compile','test'};
[~,inputs,~,~,ok,mess] = parse_arguments (varargin, opt_default, flagnames);
assert(ok,mess);

if ~(inputs.compile||inputs.test)
    warning('No compiling or testing requested.');
    return;
end


% Locate the directory containting the source files to be compiled
src = fullfile( fileparts(mfilename('fullpath')),'mex');
% List all files/folders in the folder
src_files = dir(src);
% Get just their names
src_names = {src_files.name};
% and their extensions
[~,~,src_ext]=cellfun(@fileparts,src_names,'UniformOutput',false);

% Pick out just those with the proper C++ extension
cpp_idx = strcmpi(src_ext,'.cpp');
cpp_files = src_names(cpp_idx);

% figure out what (if anything) we're compiling and/or testing
if ischar(inputs.which) && strcmp(inputs.which,'all')
    cpp_mex = cpp_files;
else
    if ischar(inputs.which)
        totest= {inputs.which};
    elseif iscellstr(inputs.which)
        totest= inputs.which;
    else
        totest=[];
    end
    inc = false(size(cpp_files));
    for i=1:numel(totest)
        [us,idx]=uniquestring(cpp_files,totest{i});
        if us
            inc(idx)=true;
        end
    end
    cpp_mex = cpp_files(inc);
end

oldpwd = pwd();
cd(src);
if inputs.compile
    if isempty(cpp_mex)
        % not 'all', not one or more character arrays.
        % Nothing to do.
        warning('No mex compiling performed for input passed');
        cd(oldpwd);
        return
    end

    if ispc()
        mexopt={'COMPFLAGS=$COMPFLAGS /openmp','LINKFLAGS=$LINKFLAGS /nodefaultlib:vcomp "$MATLABROOT\bin\win64\libiomp5md.lib"'};
    elseif ismac()
        mexopt={'COMPFLAGS="/openmp $COMPFLAGS"','CXXFLAGS=$CXXFLAGS -fopenmp -pthread'};
    else
        mexopt={'CXXFLAGS=$CXXFLAGS -fopenmp -pthread','LDFLAGS=$LDFLAGS -fopenmp'};
    end
    for i=1:length(cpp_mex)
        fprintf('Compiling %s via command\n\tmex %s',cpp_mex{i},cpp_mex{i});
        fprintf(' %s',mexopt{:});
        fprintf('\n');
        try
            mex(cpp_mex{i},mexopt{:});
        catch prob
            warning('Compiling mex file %s failed.',cpp_mex{i});
            if strcmp(prob.identifier,'MATLAB:mex:Error')
                disp(prob.message);
            end
        end
        fprintf('\n');
    end
    
end
if inputs.test
    % We have a (possibly empty) list of C++ file names in cpp_mex.
    % We want list of *.mex* files which are present, and which we can test
    % The exact extension is platform dependent -- but MATLAB has a
    % function to tell us what it is! 
    [~,mex_names,~]=cellfun(@fileparts,cpp_mex,'UniformOutput',false);
    mex_present = cellfun(@(x)exist([x,'.',mexext()],'file'),mex_names);
    if any(~mex_present)
        notpresent = find(~mex_present);
        warning('\n\tMex file for %s does not exist.',cpp_mex{notpresent});
    end
    if sum(mex_present)==0
        warning('No mex files to test!');
        cd(oldpwd);
        return;
    end
    present = find(mex_present);
    mex_test = mex_names(present);
    for i=1:length(mex_test)
        fprintf('Testing compiled mex function %s\n',mex_test{i});
        eval(mex_test{i});
        fprintf('\n');
    end
end
cd(oldpwd);


end

function [tf,b] = uniquestring(known,x)
assert(iscellstr(known),'known should be a cell array of strings');
assert(ischar(x),'x should be a character array');

matches = strncmpi(known,x,numel(x));
tf = sum(matches)==1;
b = find(matches,1,'last');
end
