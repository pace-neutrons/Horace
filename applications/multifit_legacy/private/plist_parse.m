function [ok,mess,np,plist]=plist_parse(plist_in,func)
% Check if form of parameter object is a valid parameter list for an array of functions
%
%   >> [ok,mess,np,plist]=plist_parse(plist_in,func)
%
% Input:
% ------
%   plist_in    List of parameters for the function(s).
% 
%               If there is only one function for which parameters are needed
%              (i.e. input argument func is a scalar), then plist_in must be
%                 - A valid parameter list (see below for details)
%                Equivalently:
%                 - A cell array containing a single valid parameter list
%
%               If there is more than one function then plist_in must be:
%                 - A cell array of valid parameter lists, one parameter list
%                  per function
%                 - A cell array containing a single valid parameter list; this
%                  will be repeated as the parameter list for each function
%                 - A numeric vector; this will be repeated as the parameter
%                  list for each function
%
%   func        Cell array of function handles (if just one, must still be a cell array)
%
% Output:
% -------
%   ok          Status flag: =true if plist_in is valid; false otherwise
%   mess        Error message: ='' if OK, contains error message if not OK
%   np          Array of the number of parameters in the root numeric array for each function
%   plist       Cell array of valid parameter lists, one list per function. size(plist)==size(func)
%              (constructed from plist_in according to description below)
%
%
% Format of a valid parameter list
% --------------------------------
%  A valid parameter list is one of the following:
%   - A numeric vector with at least one element e.g. p=[10,100,0.01]
%
%   - A cell array of parameters, the first of which is a numeric vector with
%    at least one element
%       e.g.  {p, c1, c2}
%
%   - A recursive nesting of functions and parameter lists:
%       plist<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%                :
%       plist<1> = {@func<0>, plist<0>, c1<1>, c2<1>,...}
%       plist<0> = {p, c1<0>, c2<0>,...}    % p is a numeric vector with at least one element
%             or =  p                       % p is a numeric vector with at least one element
%
%     This defines a recursive form for the parameter list that it is assumed
%     the functions in argument func accept:
%       p<0> = p               numeric vector
%         or ={p, c1, c2, ...} cell array, with first parameter a numeric vector
%
%       p<1> = {@func<0>, p<0>, c1<1>, c1<2>,...}
%
%       p<2> = {@func<1>, {@func<0>, p<0>, c1<1>, c2<1>,...}, c1<2>, c2<2>,...}
%            :
%
% When recursively nesting functions and parameter lists, there can be any
% number of additional arguments c1, c2,... , including the case of no
% additional arguments. The exception is the parameter list at the base.
% For example, the following are valid (p is a numeric vector with at least one element):
%        p
%       {@myfunc,p}
%       {@myfunc1,@myfunc,p}
% but these are not valid:
%       {p}
%       {@myfunc,{p}}
%
%
% ---------------------
% EXAMPLES of plist_in:
% ---------------------
%   If just one function (i.e. func is scalar):
%      [10,2]
%     {[10,2],'filter',true}
%    {{[10,2],'filter',true}}   % valid, but it is unnecessary to put in a cell
%
%   If two functions:
%      [10,5,2]                 % will apply to both functions
%     {[10,5,2]}                % equivalent alternative syntax
%     {[10,2],[15,3]}           % different parameters for each function
%     {[10,2],'filter',true}    % *** NOT VALID: not a single parameter list
%                                (interpreted as three parameter lists, the first
%                                 [10,2], the second 'filter', the third true)
%     {{[10,2],'filter',true}}  % valid: now a single parameter list
%                               % and will apply to both functions
%     {{[10,2],'filter',true},{[15,3],'hat',false}}  % different parameters for each function
%
%  NOTES:
%   A simple cell array is only valid for plist when there is just the one function
%  as the examples above indicate.
%
%   This is because with more than one function there is an ambiguity in
%  interpretation. For example, suppose
%       plist = {p, c1, c2}
%   This could either be a single parameter list or three separate parameter lists.
%  In the former case, the list should then be replicated once
%  for each function. However, if numel(func)==3, then plist coul equally be
%  understood to mean the parameter list is p for the first, c1 for the second, and
%  c2 for the third function. There is no way to resolve the ambiguity. Therefore
%  we insist in the case of more than one function that if one parameter list is
%  to be repeated for each function it is explicitly written as
%       plist = {{p, c1, c2}}


if numel(func)==1
    % Single function
    if iscell(plist_in) && isscalar(plist_in)
        % Case of {parameter_list} (there is no valid plist such that {plist} is also valid)
        plist_in=plist_in{1};
    end
    [ok,np]=plist_parse_single(plist_in);
    if ok
        mess='';
        plist={plist_in};
    else
        mess='parameter list has invalid form';
        np=[];
        plist={};
    end
else
    % Multiple functions
    ok=false;
    np=[]; plist={};
    sz=size(func);
    if iscell(plist_in)
        if isscalar(plist_in)
            [ok_tmp,np_tmp]=plist_parse_single(plist_in{1});
            if ok_tmp
                np=np_tmp*ones(sz);
                plist=cell(sz);
                for i=1:prod(sz)
                    plist{i}=plist_in{1};
                end
            else
                mess='parameter list has invalid form';
                return
            end
        elseif numel(plist_in)==numel(func)
            np=zeros(sz);
            plist=cell(sz);
            for i=1:numel(plist_in)
                [ok_tmp,np_tmp]=plist_parse_single(plist_in{i});
                if ok_tmp
                    np(i)=np_tmp;
                    plist{i}=plist_in{i};
                elseif isempty(plist_in{i})
                    np(i)=0;
                    plist{i}=[];
                else
                    np=[]; plist={};
                    mess=['parameter list has invalid form for element ',arraystr(sz,i)];
                    return
                end
            end
        else
            mess='parameter list is not scalar or is not an array of lists with the same number of elements as data sources';
            return
        end
        
    elseif isvector(plist_in) && isnumeric(plist_in) && numel(plist_in)>0
        % Numeric vector; assumed to apply to every function
        np=numel(plist_in)*ones(sz);
        plist=cell(sz);
        for i=1:prod(sz)
            plist{i}=plist_in;
        end
        
    else
        mess='parameter list must be a cell array';
        return
    end
    
    % Valid parameter list if reached here. Now check that plist{i} is empty for missing functions,
    % and likewise that parameters have been provided for functions that are present
    for i=1:numel(func)
        if isempty(func{i}) && ~isempty(plist{i})
            np=[]; plist={};
            mess=['function ',arraystr(size(func),i),' is not given, but parameters have been provided for it'];
            return
        elseif ~isempty(func{i}) && isempty(plist{i})
            np=[]; plist={};
            mess=['function ',arraystr(size(func),i),' has not been given parameters'];
            return
        end
    end
    
    % All OK if got here
    ok=true;
    mess='';

end


%--------------------------------------------------------------------------------------------------------------------------------
function [ok,np]=plist_parse_single(plist)
% Check that a parameter list has valid format
%
%   >> [ok,np]=parameter_list_single_valid(plist)
%
% Input:
% ------
%   plist   Parameter list for a single function
%
% Output:
% -------
%   ok      Status flag: =true if plist_in is valid; false otherwise
%   mess    Error message: ='' if OK, contains error message if not OK
%   np      Number of parameters in the numeric array
%
%
% A valid parameter list is one of the following:
%   - A numeric vector with at least one element e.g. p=[10,100,0.01]
%   
%   - A cell array of parameters, the fist of which is a numeric vector with
%    at least one element
%       e.g.  {p, c1, c2}
%
%   - A recursive nesting of functions and parameter lists:
%       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%            :
%       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
%       p<0> = {p, c1<0>, c2<0>,...}        % p is a numeric vector with at least on element
%         or =  p                           % p is a numeric vector with at least on element
%
%     This defines a recursive form for the parameter list that it is assumed
%     the functions in argument func accept:
%       p<0> = p               numeric vector
%         or ={p, c1, c2, ...} cell array, with first parameter a numeric vector
%
%       p<1> = {@func<0>, p<0>, c1<1>, c1<2>,...}
%
%       p<2> = {@func<1>, {@func<0>, p<0>, c1<1>, c2<1>,...}, c1<2>, c2<2>,...}
%            :
%
% When recursively nesting functions and parameter lists, there can be any
% number of additional arguments c1, c2,... , including the case of no
% additional arguments. The exception is the parameter list at the base.
% For example, the following are valid (p is a numeric vector with at least one element):
%        p
%       {@myfunc,p}
%       {@myfunc1,@myfunc,p}
% but these are not valid:
%       {p}
%       {@myfunc,{p}}

ok=false;
np=[];
if iscell(plist) && numel(plist)>=2
    if isa(plist{1},'function_handle')
        [ok,np]=plist_parse_single(plist{2});
    elseif isvector(plist{1}) && isnumeric(plist{1}) && numel(plist{1})>0
        ok=true;
        np=numel(plist{1});
    end
elseif isvector(plist) && isnumeric(plist) && numel(plist)>0
    ok=true;
    np=numel(plist);
end
