function [ok, mess, S] = parse_doc_definitions_block_vals (cstr)
% Run the definition block to get the variable values as contained in the block
% Need to parse argument values like '#1' elsewhere
%
%   >> [ok, mess, S] = parse_doc_definitions_block_vals (cstr)
%
% Input:
% ------
%   cstr    Cell array of strings, all beginning with '%'. Assumed trimmed
%          of leading and trailing whitespace. These can be any valid
%          lines of code that define variables as:
%               - logical scalar (or 0 or 1)
%               - a string
%               - a cell array of strings
%           Any assignments to the strings '#1', '#2', ... (up to the number
%          of arguments in args, below) will be substituted by the
%          corresponding element of args.
%           If you want a variable to actually be the character string '#1',
%          then in the definition block give it the value '\#1'. Similarly,
%          if you actually want the varaible to be '\#1' use '\\#1' etc.
%
% Output:
% -------
%   ok      If all OK, then true; otherwise false
%
%   mess    Error message if not OK; empty if all OK
%
%   S       Structure whose fields are the names of variables and their
%          values. Fields can be:
%               - string
%               - cell array of strings (column vector)
%               - logical true or false (retain value for blocks)


% Initialise output objects
S=struct([]);   % ensure is an empty structure (rather than anything else)
ok=false;
mess='';

% Set cleanup function
curr_loc=pwd;
finishup = onCleanup(@() myCleanupFun(curr_loc));

% Check that the lines are all comments
if ~all(strncmp(cstr,'%',1))
    ok=false;
    mess='All lines in a documentation definition block must be comment lines';
    return
end

% Write mfile with definitions (use matlab itself to parse!)
[~,tmpname]=fileparts(tempname);
tmp_mfile=['docify_tmp_',tmpname];
tmp_mfile_full=fullfile(tmp_dir,[tmp_mfile,'.m']);
Cbeg={...
    'function S=docify_tmp',...
    '% Parse meta-documentation definitions. T.G.Perring April 2015',...
    '% -----------------------------------------------------------------------------'};
C=cell(numel(cstr),1);
for i=1:numel(cstr)
    tmp_str = strtrim(cstr{i}(2:end));
    if (numel(tmp_str)>=3 && strcmp(tmp_str(1:3),'<<-')) ||...
            allchar(tmp_str,'-') || allchar(tmp_str,'=')
        C{i}='';
    else
        C{i}=cstr{i}(2:end);
    end
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
    cd(tmp_dir)
    [~,S]=evalc(tmp_mfile);
    err=false;
catch
    S=struct([]);
    mess1='Unable to run meta-documentation temporary function. Check syntax of docify argument definition block.';
    mess2='Documentation temporary file ';
    warning('%s\n%s\n%s',mess1,mess2,tmp_mfile_full)
    err=true;
end
cd(curr_loc)

if ~err
    try
        delete(tmp_mfile_full)
    catch
        mess='Unable to delete meta-documentation temporary function.';
        warning(mess)
    end
end
if err, return, end

% OK if reached this point; check the contents of the structure
ok=true;
if isempty(S)
    S=struct([]);   % ensure is an empty structure (rather than anything else)
end

%------------------------------------------------------------------------------
function status = allchar(str,ch)
for i=1:numel(str)
    if str(i)~=ch
        status=false;
        return
    end
end
status=true;

%------------------------------------------------------------------------------
function myCleanupFun(loc)
cd(loc);
