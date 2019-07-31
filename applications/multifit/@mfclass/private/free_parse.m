function [ok,mess,free]=free_parse(free_in,np)
% Determine if an argument is a valid free and expand input argument to full argument
%
%   >> [ok,mess,free]=free_parse(free_in,np)
%
% Input:
% ------
%   free_in    Description of which parameters are free and which are fixed
%
%               If there is only one function, that is, it applies globally
%              to all datasets, then free_in must be:
%                - An empty argument (which means all parameters are free)
%                - A row vector of zeros and ones (or a row of logicals)
%                 indicating which parameters are fixed or free for a function.
%                Equivalently:
%                - A cell array with a single row vector
%
%               If there is more than one function, that is they apply locally,
%              one function per dataset, then free_in must be:
%                - An empty argument (which means all parameters are free for all functions)
%                - A cell array of row vectors, one per function
%                - A single row vector (or a cell array with a single row vector) which
%                 will be repeated for each function
%
%   np          Array with number of parameters for each function. Can
%              have zero length (i.e. no functions)
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%   free       Cell array with same size as input argument np, of logical
%              row vectors, where the number of elements of the ith vector
%              equals the number of parameters for the ith function, and with
%              elements =true for free parameters, =false for fixed parameters
%               If not OK, free={}
%
%
%  EXAMPLES of free_in:
%   If just one function:
%      [0,1,1,0]
%     {[0,1,1,0]}   % valid, but it is unnecessary to make it a cell
%
%   If two functions:
%      [0,1,1,0]    % applies to both functions; valid if both have four parameters
%     {[0,1,1,0]}   % equivalent syntax
%     {[0,1,1,0],[0,0,1,0]}     % to have different free parameters
%     {[0,1,1,0],[0,0,1]}       % if the functions have four and three parameters respectively


ok=false;
free={};

if isempty(free_in)    % Empty argument; assume all parameters are free
    free=cell(size(np));
    for i=1:numel(np)
        [~,~,free{i}]=free_parse_single([],np(i));
    end
    ok=true;
    mess='';
    
elseif iscell(free_in)
    if isscalar(free_in)   % the parameter list is assumed to apply for every function
        [ok_tmp,mess,free_tmp]=free_parse_single(free_in{1},np(1));
        if ~ok_tmp
            mess=['Function index ',arraystr(size(np),1),': ',mess];
            return
        end
        if ~all(np(:)==np(1))
            mess='A single free parameter list is only valid if all functions have same number of parameters';
            return
        end
        free=cell(size(np));
        for i=1:numel(np)
            free{i}=free_tmp;
        end
        ok=true;
        mess='';
    elseif numel(free_in)==numel(np)
        free=cell(size(np));
        for i=1:numel(np)
            [ok,mess,free{i}]=free_parse_single(free_in{i},np(i));
            if ~ok
                free={};
                mess=['Function index ',arraystr(size(np),i),': ',mess];
                return
            end
        end
        ok=true;
        mess='';
    else
        mess='Array of free parameters lists is not scalar or does not have same size as array of data sources';
        return
    end
    
elseif isnumeric(free_in)||islogical(free_in)     % Assume applies to all functions
    [ok_tmp,mess,free_tmp]=free_parse_single(free_in,np(1));
    if ~ok_tmp
        return
    end
    if ~all(np(:)==np(1))
        mess='A single free parameter list is only valid if all functions have same number of parameters';
        return
    end
    free=cell(size(np));
    for i=1:numel(np)
        free{i}=free_tmp;
    end
    ok=true;
    mess='';
    
else
    mess='Free parameter list must be empty, numeric or logical array or a cell array of numeric or logical arrays';
    return
end

%------------------------------------------------------------------------------
function [ok,mess,free]=free_parse_single(free_in,np)
% Determine if an argument is a valid free and expand input argument to full argument
%
%   >> [ok,mess,free]=free_parse_single(free_in,np)
%
% Input:
% ------
%   free_in     Vector describing which parameters are free and which are fixed. Must be:
%               - empty, then all parameters are free
%               - numeric vector of zeros and ones, or logical vector
%   np          Number of parameters in total
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%   free        Logical row vector length np with elements =true for free parameters,
%              and =false for fixed parameters


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


if isempty(free_in)
    ok=true;
    free=true(1,np);
    mess='';
elseif (isnumeric(free_in)||islogical(free_in))
    if isvector(free_in) && numel(free_in)==np   % note: isvector(arg)==0 if isempty(arg)
        if isnumeric(free_in) && all(free_in==1|free_in==0)
            ok=true;
            free=logical(free_in(:)');
            mess='';
        elseif islogical(free_in)
            ok=true;
            free=free_in(:)';
            mess='';
        else
            ok=false;
            free=true(0);
            mess=message(np);
        end
    else
        ok=false;
        free=true(0);
        mess=message(np);
    end
else
    ok=false;
    free=true(0);
    mess=message(np);
end

%------------------------------------------------------------------------------
function mess = message(np)
if np>0
    mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
else
    mess='Free parameters argument must be an empty numeric or logical vector as the parameter list is empty';
end
