function [S,ok,mess]=parse_doc_definitions(cstr,args)
% Get the values of variables from the documentation definitions block.
%
%   [S,ok,mess]=parse_doc_definitions(cstr,args)
%
% Input:
% ------
%   cstr    Cell array of strings, all beginning with '%'. Assumed trimmed.
%   args    Cell array of arguments (each must be a string or cell array of
%          strings)
%
% Output:
% -------
%   S       Structure whose fields are the names of variables and their
%          values.
%           The format of the definitions block constrains variables to have
%          values that are one of:
%               - logical 0 or 1,
%               - a string or cell array of strings
%               - reference to an argument index passed down by the caller
%                 can only be '#1', '#2', ...
%           If you want a variable to actually be the character string '#1',
%           then in the definition block give it the value '\#1'. Similarly,
%           if you actually want the varaible to be '\#1' use '\\#1' etc.
%               
%
% EXAMPLE: (lines can have comments at the end or terminal semi-colons)
%
%   % main = 1
%   % fname = 'c:\temp\weasel.txt'
%   % fnams = {'c:\temp\weasel.txt','hello'...
%   %            'there'}
%   % warn = '#1'           % warn will be set to arg{1}
%   % odd_string = '\#1'    % odd_string will be set to '#1'


% Initialise output objects
ok=false;
mess='';

% Set cleanup function
curr_loc=pwd;
finishup = onCleanup(@() myCleanupFun(curr_loc));

% Write mfile with definitions (use matlab itself to parse!)
[~,tmpname]=fileparts(tempname);
tmp_mfile=['docify_tmp_',tmpname];
tmp_mfile_full=fullfile(tempdir,[tmp_mfile,'.m']);
Cbeg={...
    'function S=docify_tmp',...
    '% Parse meta-documentation definitions. T.G.Perring April 2015',...
    '% -----------------------------------------------------------------------------'};
C=cell(numel(cstr),1);
for i=1:numel(cstr)
    C{i}=cstr{i}(2:end);
end
Cend={...
    '% -----------------------------------------------------------------------------',...
    'var=whos;',...
    'S=struct;',...
    'for i=1:numel(var)',...
    '    if ~strcmpi(var(i).name,''ans'')',...
    '        S.(var(i).name)=eval(var(i).name);',...
    '    end',...
    'end'
    };
save_text([Cbeg(:);C;Cend(:)],tmp_mfile_full);

% Run the file, and delete afterwards
try
    cd(tempdir)
    [~,S]=evalc(tmp_mfile);
    err=false;
catch
    S=struct([]);
    mess='Unable to run meta-documentation temporary function. Check syntax.';
    warning(mess)
    err=true;
end
cd(curr_loc)

try
    delete(tmp_mfile_full)
catch
    mess='Unable to delete meta-documentation temporary function.';
    warning(mess)
end
if err, return, end

% Check the contents
if isempty(S)
    S=struct([]);   % ensure is an empty structure (rather than anything else)
    ok=true;
    return
end

name=fields(S);
for i=1:numel(name)
    value=S.(name{i});
    if iscellstr(value) || islognumscalar(value) || is_string(value)
        if islognumscalar(value)
            S.(name{i})=logical(value);   % convert to scalar logical
        elseif iscellstr(value)
            S.(name{i})=str_trim_cellstr(value);    % remove blank lines and trim
        end
    else
        S=struct([]);
        mess=['''',name{i},''' must be set to a character string, cell array or 0 or 1'];
        return
    end
end

% Substitute arguments
for i=1:numel(name)
    [val_out,changed,ok,mess]=parse_doc_definition_arg(S.(name{i}),args);
    if ok && changed
        S.(name{i})=val_out;
    elseif ~ok
        S=struct([]);
        mess=['''',name{i},''' : ',mess];
        return
    end
end

ok=true;
mess='';

%------------------------------------------------------------------------------
function myCleanupFun(loc)
cd(loc);
