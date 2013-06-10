function [par,argout,present,filled,ok,mess]=parse_args_simple(parargin,arglist)
% Utility to parse varargin to find values of named parameters passed to a function.
%
% This is a simple version of parse_arguments that assumes that the keywords must always
% take values (i.e. the concept of logical flags is not implemented.
%
% Common use:
%   >> [par,argout,present,filled]=parse_arguments(parargin,arglist)
%
% To avoid a failure on error, but pass an error flag and message instead:
%   >> [par,argout,present,filled,ok,mess]=parse_arguments(parargin,arglist)
%
%
% EXAMPLE:
% ========
% The use of parse_args_simple is most clearly illustrated by an example:
% Consider the function:
%
%   function parse_test (varargin)
%   % 
%   arglist = struct('background',[12000,18000], ...    % argument names and default values
%                    'normalise', 1, ...
%                    'modulation', 0, ...
%                    'output', 'data.txt');
%   
%   [par,argout,present,filled] = parse_args_simple(varargin,arglist);
%   par
%   argout
%   present
%
% Then calling my_func with input:
%   >> parse_test('input_file.dat',18,{'hello','tiger'},...
%                       'back',[15000,19000],'mod',true)
%
% results in the output:
%   par = 
%        'input_file.dat'    [18]    {1x2 cell}
% 
%   argout = 
%        background: [15000 19000]
%         normalise: 1
%        modulation: 1
%            output: 'data.txt'
% 
%   present = 
%        background: 1
%         normalise: 0
%        modulation: 1
%            output: 0
%
%
% In more detail:
% ===============
%   >> [par,argout,present,filled]=parse_arguments(varargin,arglist,flags,keys_apart)
%
% Input:
% ------
% varargin  Cell array of arguments to be parsed. The list of arguments in varargin is
%               par_1, par_2, par_3, ..., name_1 ,val_1, name_2 ,val_2, ...
%           where: par_1, par_2, ... are the values of un-named parameters,
%             and: name_1 ,val_1, ... are names of arguments (given in arglist, below)
%                  and their corresponding values.
%           If a name does not appear in varargin, then the output value in argout is
%           set to the default value in arglist.
%
% arglist   Structure with field names giving the argument names, and values giving the
%           default output values for those arguments.
%
%
% Output:
% -------
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
% present   Structure with the same field names as arglist and argout but which have value
%           logical 0 or 1 indicating if the argument name appeared in varargin.
%
% filled    Structure with the same field names as arglist and argout with values
%           logical 0 or 1 indicating if the argument is non-empty (whether that be because
%           it was supplied with a non-empty default, or because it was given a non-empty value
%           on the command line). Provided for convenience.
%
% ok        =true if input has form described above, =false otherwise
%
% mess      Error message if not OK


keywords=fieldnames(arglist);

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax (keywords,parargin{:});
if ~ok
    if nargout>4
        par=cell(1,0); argout=struct([]); present=[]; filled=[];
    else    % throw error if ok not a return argument
        error(mess)
    end
end

% Fill return arguments
if nargout>=2
    argout=arglist;
    if ~isempty(ind)
        for i=1:numel(ind)
            argout.(keywords{ind(i)})=val{i};
        end
    end
end

if nargout>=3
    ispresent=false(numel(keywords),1);
    ispresent(ind)=true;
    present=cell2struct(num2cell(ispresent),keywords,1);
end

if nargout>=4
    isfilled=true(numel(keywords),1);
    for i=1:numel(keywords)
        if isempty(argout.(keywords{i}))
            isfilled(i)=false;
        end
    end
    filled=cell2struct(num2cell(isfilled),keywords,1);
end
