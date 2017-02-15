function wout=multifit_func_eval(w,xye,func,bfunc,plist,bplist,...
    f_pass_caller_info,bf_pass_caller_info,pf,p_info,eval_fore,eval_back)
% Calculate the functions over the input data objects
%
%   >> wout=multifit_func_eval(w,xye,func,bfunc,plist,bplist,...
%                f_pass_caller_info,bf_pass_caller_info,pf,p_info,eval_fore,eval_back)
%
% Input:
% ------
%   w           Cell array where each element w(i) is either
%                 - an x-y-e triple with w(i).x a cell array of arrays, one
%                  for each x-coordinate,
%                 - a scalar object
%
%   xye         Logical array, size(w): indicating which data are x-y-e triples (true),
%              or objects (false)
%
%   func        Handles to foreground functions:
%                 - a single function handle
%                 - cell array of function handles
%               Some, but not all, elements of the cell array can be empty.
%              Empty elements are interpreted as not having a function to
%              evaluate for the corresponding data set.
%
%   bfunc       Handles to background functions; same format as func, above
%
%   plist       Cell array of valid parameter lists, one list per foreground function.
%
%   bplist      Cell array of valid parameter lists, one list per background function.
%
%   f_pass_caller_info  Keep internal state of foreground function evaluation e.g. seed of random
%              number generator. Dictates the format of the fit fuction argument list.
%              Nothing is actually kept, however; it is just used to call the function
%              with the correct syntax.
%
%   bf_pass_caller_info Keep internal state of background function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit fuction argument list.
%              Nothing is actually kept, however; it is just used to call the function
%              with the correct syntax.
%
%   pf          Free parameter initial values
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   eval_fore   Include evaluation of foreground functions (true or false)
%
%   eval_back   Include evaluation of background functions (true or false)
%
%
% Output:
% -------
%   wout        Calculated output dataset(s). Same form as the input dataset(s)


wout=cell(size(w));

[p,bp]=ptrans_par(pf,p_info);    % Get latest numerical parameters

fstate_store={[]};
bfstate_store={[]};
caller.reset_state=true;
caller.ind=[];
% Foreground function calculations
if eval_fore
    if numel(func)==1
        if ~isempty(func{1})
            pars=parameter_set(plist{1},p{1});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            for i=1:numel(w)
                caller.ind=i;
                if xye(i)
                    wout{i}=w{i};
                    if ~f_pass_caller_info
                        wout{i}.y=func{1}(w{i}.x{:},pars{:});
                    else
                        wout{i}.y=func{1}(w{i}.x{:},caller,fstate_store,pars{:});
                    end
                    wout{i}.e=zeros(size((w{i}.y)));
                else
                    if ~f_pass_caller_info
                        wout{i}=func{1}(w{i},pars{:});
                    else
                        wout{i}=func{1}(w{i},caller,fstate_store,pars{:});
                    end
                end
            end
        end
    else
        for i=1:numel(w)
            caller.ind=i;
            if ~isempty(func{i})
                pars=parameter_set(plist{i},p{i});
                if ~iscell(pars), pars={pars}; end  % make a cell for convenience
                if xye(i)
                    wout{i}=w{i};
                    if ~f_pass_caller_info
                        wout{i}.y=func{i}(w{i}.x{:},pars{:});
                    else
                        wout{i}.y=func{i}(w{i}.x{:},caller,fstate_store,pars{:});
                    end
                    wout{i}.e=zeros(size((w{i}.y)));
                else
                    if ~f_pass_caller_info
                        wout{i}=func{i}(w{i},pars{:});
                    else
                        wout{i}=func{i}(w{i},caller,fstate_store,pars{:});
                    end
                end
            end
        end
    end
end

% Background function calculations
if eval_back
    if numel(bfunc)==1
        if ~isempty(bfunc{1})
            pars=parameter_set(bplist{1},bp{1});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            for i=1:numel(w)
                caller.ind=i;
                if xye(i)
                    if isempty(wout{i})
                        wout{i}=w{i};
                        if ~bf_pass_caller_info
                            wout{i}.y=bfunc{1}(w{i}.x{:},pars{:});
                        else
                            wout{i}.y=bfunc{1}(w{i}.x{:},caller,bfstate_store,pars{:});
                        end
                        wout{i}.e=zeros(size((w{i}.y)));
                    else
                        if ~bf_pass_caller_info
                            wout{i}.y=wout{i}.y + bfunc{1}(w{i}.x{:},pars{:});
                        else
                            wout{i}.y=wout{i}.y + bfunc{1}(w{i}.x{:},caller,bfstate_store,pars{:});
                        end
                    end
                else
                    if isempty(wout{i})
                        if ~bf_pass_caller_info
                            wout{i}=bfunc{1}(w{i},pars{:});
                        else
                            wout{i}=bfunc{1}(w{i},caller,bfstate_store,pars{:});
                        end
                    else
                        if ~bf_pass_caller_info
                            wout{i}=wout{i}+bfunc{1}(w{i},pars{:});
                        else
                            wout{i}=wout{i}+bfunc{1}(w{i},caller,bfstate_store,pars{:});
                        end
                    end
                end
            end
        end
    else
        for i=1:numel(w)
            caller.ind=i;
            if ~isempty(bfunc{i})
                pars=parameter_set(bplist{i},bp{i});
                if ~iscell(pars), pars={pars}; end  % make a cell for convenience
                if xye(i)
                    if isempty(wout{i})
                        wout{i}=w{i};
                        if ~bf_pass_caller_info
                            wout{i}.y=bfunc{i}(w{i}.x{:},pars{:});
                        else
                            wout{i}.y=bfunc{i}(w{i}.x{:},caller,bfstate_store,pars{:});
                        end
                        wout{i}.e=zeros(size((w{i}.y)));
                    else
                        if ~bf_pass_caller_info
                            wout{i}.y=wout{i}.y + bfunc{i}(w{i}.x{:},pars{:});
                        else
                            wout{i}.y=wout{i}.y + bfunc{i}(w{i}.x{:},caller,bfstate_store,pars{:});
                        end
                    end
                else
                    if isempty(wout{i})
                        if ~bf_pass_caller_info
                            wout{i}=bfunc{i}(w{i},pars{:});
                        else
                            wout{i}=bfunc{i}(w{i},caller,bfstate_store,pars{:});
                        end
                    else
                        if ~bf_pass_caller_info
                            wout{i}=wout{i}+bfunc{i}(w{i},pars{:});
                        else
                            wout{i}=wout{i}+bfunc{i}(w{i},caller,bfstate_store,pars{:});
                        end
                    end
                end
            end
        end
    end
end

% Catch any datsets where neither foreground nor background functions contribute
for i=1:numel(wout)
    if isempty(wout{i})
        if xye(i)
            wout{i}=w{i};
            wout{i}.y=zeros(size((w{i}.y)));
            wout{i}.e=zeros(size((w{i}.y)));
        else
            wout{i}=0*w{i};
        end
    end
end
