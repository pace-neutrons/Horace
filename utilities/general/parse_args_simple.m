function [par,argout,present,filled,ok,mess]=parse_args_simple(parargin,arglist)
% Utility to parse varargin to find values of named parameters passed to a function
% Simplified version of parse_arguments that assumes that the keywords must always take values
% (i.e. the concept of logical flags is not implemented - see parse_arguments for details)
%
% Syntax:
%   >> [par,argout,present,filled,ok,mess]=parse_arguments(parargin,arglist)
%
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

keywords=fieldnames(arglist);

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax (keywords,parargin{:});
if ~ok
    if nargout>4
        par={}; argout=struct([]); present=[]; filled=[];
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
