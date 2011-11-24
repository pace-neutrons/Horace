function [par,argout,present,filled]=parse_arguments(parargin,arglist,varargin)
% Utility to parse varargin to find values of named parameters passed to a function
%
% Syntax:
%   >> [par,argout,present,filled]=parse_arguments(parargin,arglist,flags)
%
% The use of parse_arguments is most clearly illustrated by an example:
% Consider the function:
%
%   function parse_test (varargin)
%   % 
%   arglist = struct('background',[12000,18000], ...    % argument names and default values
%                    'normalise', 1, ...
%                    'modulation', 0, ...
%                    'output', 'data.txt');
%   flags = {'normalise','modulation'};                 % arguments which are logical flags
%   
%   [par,argout,present] = parse_arguments(varargin,arglist,flags);
%   par
%   argout
%   present
%
% Then calling my_func with input:
%   >> parse_test('input_file.dat',18,{'hello','tiger'},...
%                       'back',[15000,19000],'mod','nonorm')
%
% results in the output:
%   par = 
%        'input_file.dat'    [18]    {1x2 cell}
% 
%   argout = 
%        background: [15000 19000]
%         normalise: 0
%        modulation: 1
%            output: 'data.txt'
% 
%   present = 
%        background: 1
%         normalise: 1
%        modulation: 1
%            output: 0
%
% In more detail:
% ===============
%   >> [par,argout,present]=parse_arguments(varargin,arglist,flags)
%
% Input:
% ------
% parargin  Cell array of arguments to be parsed. The list of arguments in varargin is
%               par_1, par_2, par_3, ..., name_1 [,val_1] name_2 [,val_2], ...
%           where: par_1, par_2, ... are the values of un-named parameters,
%             and: name_1 [,val_1], ... are names of arguments (given in arglist, below)
%                  and their corresponding values.
%            Note:
%             - The argument names can be exact matches or unambiguous abbreviations of 
%              the names in arglist
%             - The negation of a name is also a valid argument name e.g. if 'mask' is
%              a name, then 'nomask' is implicity also a name.
%             - If a name takes a value (i.e. is not indicated as a logical in flags, below)
%              then the following are valid within varargin:
%                   ...,'foo',bar,...        argument 'foo' is given value: bar
%                                           (i.e. argout.foo = bar)
%                   ...,'nofoo',...          argument 'foo' is set to empty value
%                                           (i.e. isempty(argout.foo) is
%                                           true, but present.foo is true
%             - If a name is a logical, then any of the following are valid
%                   ...,'foo',1,...          sets argout.foo = 1
%                   ...,'foo',...            sets argout.foo = 1
%                   ...,'foo',0,...          sets argout.foo = 0
%                   ...,'nofoo',...          sets argout.foo = 0
%
%             - If a name does not appear in varargin, then the output value in argout is
%              set to the default value in arglist.
%
% arglist   Structure with field names giving the argument names, and values giving the
%           default output values for those arguments.
%            Note:
%             - Because the negation of a name is also a valid argument name - e.g. if 'mask'
%              is a name, then 'nomask' is implicity also a name - there are some combinations
%              of naems that are not permitted e.g. 'ne' and 'none' cannot bothe be names as
%              the negation of the first is equal to the second.
%
% flags     Cell array giving the names of the arguments that can only be logical 0 or 1
%           The names must be given in full (i.e. not abbreviations), and the corresponding
%           default values given in arglist must be false, true, 0 or 1, otherwise an
%           error is returned.
%
% Output:
% -------
%
% par       Cell array that contains the leading arguments that do not correspond to 
%           values of named arguments named in the input argument 'arglist'. Any argument
%           type can be given; the first character string that is an abbreviation or
%           exact match to one of one of the argument names in arglist will indicate
%           the start of name-value pairing.
%
% argout    Structure with fieldnames provided by the input argument arglist, and
%           contains the values of the arguments named in varargin. Arguments that
%           were not given values retain the default values given in the input argument arglist.
%
% present   Structure with the same field names as argin and argout but which have value
%           logical 0 or 1 indicating if the argument name appeared in varargin. If a name
%           was appeared vai its negation e.g. 'nofoo', then it is deemed to have been present
%           i.e. present.foo = 1
%
% filled    Structure with the same field names as argin, and argout with values
%           logical 0 or 1 indicating if the argument is non-empty (whether that be because
%           it was supplied with a non-empty default, or because it was given a non-empty value
%           on the command line). Provided for convenience.
%           
% 

% names of valid arguments
fnames = fieldnames(arglist);
nnames = length(fnames);

% default output argument values
par = {};           % empty cell array
argout = arglist;   % output is same as input
present = cell2struct(repmat({false},nnames,1),fnames); % no arguments present

% Get list of parameters that are flags, if given
% ----------------------------------------------------
if length(varargin)>=1  % list of flag arguments provided
%    flagnames = lower(strvcat(varargin{1}));    % character array of flags: works for both 1xn and nx1 cell arrays of strings
    if isa_size(varargin{1},'vector','cellstr')
        flagnames = lower(varargin{1});
    else
        error('List of flag names must be a cell array of strings')
    end
end

% Get list of names and whether or not they are flags
% ----------------------------------------------------

% Create list of names
name = lower(fnames);
name_char = char(name);
negname_char = [repmat('no',nnames,1),name_char];
negname = cellstr(negname_char);

% Check that no name matches the negative of another
ind = strmatch('no',name_char);
for i=1:length(ind)
    ipos = strmatch(name{ind(i)},negname,'exact');
    if ~isempty(ipos);
        error (['Argument name ''',name{ind(i)},''' matches the negative of argument name ''',name{ipos},''''])
    end
end

% set flag list:
flag = false(length(fnames),1);
if exist('flagnames','var') % there is a list of flagnames
    for i=1:length(flagnames)
        ipos = strmatch(flagnames{i},name,'exact');
        if ~isempty(ipos)
            flag(ipos) = true;
            % if argument is a flag, then check default value is 0 or 1 (and change type), or is logical true or false
            if islogical_value(arglist.(fnames{ipos}))
                argout.(fnames{ipos}) = logical(arglist.(fnames{ipos}));
            else
                if isnumeric(arglist.(fnames{ipos}))
                    error (['Default value of argument ''',name{ipos},''' is numeric but does not have value 0 or 1'.\n'...
                            'Function parse_arguments does not accept is as a logical'],'')
                else
                    error (['Default value of argument ''',name{ipos},''' has class type ',class(arglist.(fnames{ipos})),'.\n'...
                            'Cannot convert to a logical'],'')
                end
            end
        else
            error(['Flag name ''',flagnames{i},''' not in list of argument names'])
        end
    end
end

% Parse cell array of input arguments and un-named parameters
% -----------------------------------------------------------
par_read = true;    % indicates that un-named parameters are being read
ipar = 0;           % number of un-named parameters read so far from parargin
i = 1;              % index of current element in parargin

nparargin = length(parargin);
while i <= nparargin
    if ~isa_size(parargin{i},'row','char')
        % not a character string, so accumulate parameters if no arguments yet encountered
        if par_read
            ipar=ipar+1;
            par{ipar} = parargin{ipar};
        else    % demand that once a named parameter has been read that all subsequent parameters are named
            str = disp_string(parargin{i});
            error (['Encountered the following argument when expecting an argument name:\n',str],'')
        end
    else
        % is a character string, so check against argument names
        ipos_name = [];
        iname = strmatch(lower(parargin{i}),name_char);
        inegname = strmatch(lower(parargin{i}),negname_char);
        if length(iname)+length(inegname)==0
            % name not found in list of valid arguments, so accumulate parameters if no arguments yet encountered
            if par_read
                ipar=ipar+1;
                par{ipar} = parargin{ipar};
            else
                str = disp_string(parargin{i});
                error (['Encountered the following argument when expecting an argument name:\n',str],'')
            end
        else
            % determine if name is an unambigous abbreviation or exact match to a named argument
            if length(iname)+length(inegname)==1    % abbreviation of just one name
                if length(iname)==1
                    is_negname = false;
                    ipos_name = iname;
                elseif length(inegname)==1
                    is_negname = true;
                    ipos_name = inegname;
                end
            elseif length(iname)+length(inegname)>1 % ambiguous abbreviation
                iname_exact = iname(strmatch(lower(parargin{i}),name(iname),'exact'));
                inegname_exact = inegname(strmatch(lower(parargin{i}),negname(inegname),'exact'));
                % determine if there is an exact match (recall that by construction that there can only be one)
                if ~isempty(iname_exact)
                    is_negname = false;
                    ipos_name = iname_exact;
                elseif ~isempty(inegname_exact)
                    is_negname = true;
                    ipos_name = inegname_exact;
                else    % cannot resolve the ambiguity. Don't attempt to interpret as an un-named parameter
                    % get two examples the ambiguity
                    if length(iname)>1; name1=name{iname(1)}; name2=name{iname(2)};
                    elseif length(inegname)>1; name1=negname{inegname(1)}; name2=negname{inegname(2)};
                    else name1=name{iname(1)}; name2=negname{inegname(1)};
                    end
                    if length(iname)+length(inegname)==2
                        error(['Argument name ''',lower(parargin{i}),''' is an ambiguous abbrevation of\n'...
                               'the valid argument names:   ''',name1,'''   &   ''',name2,''''],'')
                    else
                        error(['Argument name ''',lower(parargin{i}),''' is an ambiguous abbrevation of\n'...
                               '   ''',name1,'''   &   ''',name2,'''\n',...
                               'and ',num2str(length(iname)+length(inegname)-2),' other valid argument name(s)'],'')
                    end
                end
            end
            par_read = false;
            % Check if we have already had the current named argument
            if ~present.(fnames{ipos_name})
                present.(fnames{ipos_name}) = true;
            else
                error (['Argument (or abbreviations) named ''',name{ipos_name},''' &/or ''',negname{ipos_name},'''\n'...
                        'appears more than once in the argument list'],'')
            end
            if ~is_negname  % argument is a name, not the negative of a name
                if flag(ipos_name)
                    if i<nparargin && islogical_value(parargin{i+1})
                        i = i + 1;
                        argout.(fnames{ipos_name}) = logical(parargin{i});
                    else
                        argout.(fnames{ipos_name}) = true;
                    end
                else
                    if i<nparargin
                        i = i + 1;
                        argout.(fnames{ipos_name}) = parargin{i};
                    else
                        error (['Argument name ''',name{ipos_name},''' expects a value but none was provided'])
                    end
                end
            elseif is_negname    % argument is the negative of a names argument
                if flag(ipos_name)
                    argout.(fnames{ipos_name}) = false;
                else
                    try % attempt to fill with empty matrix of the same class as the default value
                        argout.(fnames{ipos_name}) = eval([class(arglist.(fnames{ipos_name})),'([])']);
                    catch
                        argout.(fnames{ipos_name}) = [];
                    end
                end
            end
        end
    end
    i = i + 1;
end

% Fill filled:
filled=argout;
for i=1:numel(fnames)
    if ~isempty(argout.(fnames{i}))
        filled.(fnames{i})=true;
    else
        filled.(fnames{i})=false;
    end
end

%--------------------------------------------------------------------------------------------------
function ok = islogical_value (par)
% strict testing that a parameter is numeric 0,1 or logical true, false
if islogical(par)
    ok = true;
elseif isnumeric(par)
    temp = double(par);
    if temp==0 || temp==1
        ok = true;
    else
        ok = false;
    end
else
    ok = false;
end

%--------------------------------------------------------------------------------------------------
function str = disp_string(var)
% create a string with newlines that attempts to give the outline of contents of a variable so
% that informative error messages can be given.
% Inelegant and idiosynchratic perhaps, but invaluable when performing diagnosis

max_row = 5;    % max. no. rows to print for a numeric array
max_col = 4;    % max. no. columns to print for a numeric array
max_char = 50;  % max. no. characters to print in a string
dims = size(var);

% Get size and class of input variable
str_type = '['; 
for i=1:length(size(var))
    str_type = [str_type,num2str(dims(i)),'x'];
end
str_type(end:end)=']';
if iscellstr(var)
    str_type = [str_type,'   ','cellstr'];
else
    str_type = [str_type,'   ',class(var)];
end

% Create string containing values for some classes
if (isnumeric(var) || islogical(var)) && length(dims)==2 && length(var)>0
    str = num2str(var(1:min(dims(1),max_row),1:min(dims(2),max_col)));
    if dims(2)>max_col
        str = [repmat('     ',min(dims(1),max_row),1),str,repmat(' ...\n',min(dims(1),max_row),1)];
    else
        str = [repmat('     ',min(dims(1),max_row),1),str,repmat('\n',min(dims(1),max_row),1)];
    end
    str=reshape(str',1,prod(size(str)));
    if dims(1)>max_row
        str = [str,'        :\n'];
    end
elseif iscellstr(var) && length(var)>0
    if length(var)>1
        ind=['1,1',repmat(',1',1,length(dims)-2)];
        str = ['     element(',ind,') = '];
    else
        str = '     ';
    end
    str = [str,'''',var{1}(1:min(length(var{1}),max_char)),''''];
    if length(var{1})>max_char
        str = [str(1:end-1),'...'];
    end
elseif ischar(var) && length(var)>0
    if dims(1)>1
        ind=['1,:',repmat(',1',1,length(dims)-2)];
        str = ['     element(',ind,') = '];
    else
        str = '     ';
    end
    str = [str,'''',var(1,1:min(dims(2),max_char)),''''];
    if dims(2)>max_char
        str = [str(1:end-1),'...'];
    end
end

if exist('str','var') 
    if ~isempty(str) 
        str = ['     ',str_type,'\nvalue:\n',str];
    else 
        str = ['     ',str_type];
    end
else
    str = ['     ',str_type];
end
