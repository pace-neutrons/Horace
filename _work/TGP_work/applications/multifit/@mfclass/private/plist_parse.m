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
%              plist is passed straight to the constructor for a parameter list, mfclass_plist
%
%               If there is more than one function then if plist_in is a cell array
%              with the same size as input argument func (see below), then plist_in{i}
%              is assumed to be the parameter list for the ith function. Otherwise,
%              plist_in is assumed to be the parmaeter list for every function.
%
%               If a function handle has not been given, then any empty value for the
%              corresponding plist_in for that function is interprested as being OK, and
%              the corresponding plist set to mfclass_plist()
%
%   func        Cell array of function handles (if just one, must still be a cell array)
%               Missing functions have element equal to []
%
% Output:
% -------
%   ok          Status flag: =true if plist_in is valid; false otherwise
%   mess        Error message: ='' if OK, contains error message if not OK
%   np          Array of the number of parameters in the root numeric array for each function
%   plist       Array of valid parameter lists, one list per function. size(plist)==size(func)
%              (constructed from plist_in according to description below)
%
%
%
% ---------------------
% EXAMPLES of plist_in:
% ---------------------
%   If just one function (i.e. func is scalar):
%      [10,2]
%     {[10,2],'filter',true}
%    {{[10,2],'filter',true}}   % valid, but perhaps not what you might expect:
%                               % plist will have a single, non-numeric argument
%                               % which is: {[10,2],'filter',true}
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


ok=true;
mess='';

if ~isa(plist_in,'mfclass_plist')
    if numel(func)==1
        % Single function
        % If the argument is a cell array containing a single cell array,a ssume that the
        % inner cell array is the argument; otherwise, assume that a single parameter list has
        % been given
        if iscell(plist_in) && isscalar(plist_in) && iscell(plist_in{1})
            if ~isempty(func{1})
                plist = mfclass_plist(plist_in{1});
            elseif isempty(plist_in{1})
                plist = mfclass_plist();
            else
                ok=false;
                mess='A function has not been given, but parameters have been provided for it';
            end
        else
            if ~isempty(func{1})
                plist = mfclass_plist(plist_in);
            elseif isempty(plist_in)
                plist = mfclass_plist();
            else
                ok=false;
                mess='A function has not been given, but parameters have been provided for it';
            end
        end
        
    else
        % Multiple functions
        % If the argument is a cell array with the same size as the array of
        % function handles, then assume that a cell array of parameter lists
        % has been provided.
        % Otherwise assume that a single parameter list has been given.
        if iscell(plist_in) && isequal(size(plist_in),size(func))
            plist = repmat(mfclass_plist(),size(func));
            for i=1:numel(plist)
                if ~isempty(func{i})
                    plist(i) = mfclass_plist(plist_in{i});
                elseif ~isempty(plist_in{i})
                    ok=false;
                    mess=['function ',arraystr(size(func),i),...
                        ' has not been given, but parameters have been provided for it'];
                end
            end
        elseif iscell(plist_in) && isscalar(plist_in) && iscell(plist_in{1})
            plist = repmat(mfclass_plist(plist_in{1}), size(func));
            empty_func = cellfun(@(x)isempty(x), func);
            if any(empty_func(:))
                if isempty(plist_in{1})
                    plist(empty_func) = mfclass_plist();
                else
                    ok=false;
                    mess=['function ',arraystr(size(func),find(empty_func,1)),...
                        ' has not been given, but parameters have been provided for it'];
                end
            end
        else
            plist = repmat(mfclass_plist(plist_in), size(func));
            empty_func = cellfun(@(x)isempty(x), func);
            if any(empty_func(:))
                if isempty(plist_in)
                    plist(empty_func) = mfclass_plist();
                else
                    ok=false;
                    mess=['function ',arraystr(size(func),find(empty_func,1)),...
                        ' has not been given, but parameters have been provided for it'];
                end
            end
        end
    end
else
    % Array of mfclass_plist
    if numel(plist_in)==numel(func)
        plist = plist_in(:)';   % make a row vector
    else
        ok = false;
        plist = repmat(mfclass_plist(),size(func));
        mess = 'Number of elements in parameter list object array does not match the number of functions';
    end
end

% Get the number of parameters
np=zeros(size(func));
for i=1:numel(func)
    np(i)=plist(i).np;
end
