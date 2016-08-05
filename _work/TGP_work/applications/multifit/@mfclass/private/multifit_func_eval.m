function wout=multifit_func_eval(w,xye,func,bkdfunc,plist,bplist,pf,p_info,eval_fore,eval_back)
% Calculate the functions over the input data objects
%
%   >> wout=multifit_func_eval(w,xye,func,bkdfunc,pin,bpin,pf,p_info)
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
%   bkdfunc     Handles to background functions; same format as func, above
%
%   plist       Cell array of valid parameter lists, one list per foreground function.
%
%   bkdlist     Cell array of valid parameter lists, one list per background function.
%
%   pf          Free parameter initial values
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   eval_fore   Include evaluation of forgraound functions (true or false)
%
%   eval_back   Include evaluation of background functions (true or false)
%
%
% Output:
% -------
%   wout        Calculated output dataset(s). Same form as the input dataset(s)

isfitting=false;
store_vals=false;

wout=cell(size(w));

[p,bp]=ptrans_par(pf,p_info);    % Get latest numerical parameters

% Foreground function calculations
if eval_fore
    if numel(func)==1
        if ~isempty(func{1})
            pars=parameter_set(plist{1},p{1});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            for i=1:numel(w)
                multifit_store_state (isfitting,i,true,store_vals)
                if xye(i)
                    wout{i}=w{i};
                    wout{i}.y=func{1}(w{i}.x{:},pars{:});
                    wout{i}.e=zeros(size((w{i}.y)));
                else
                    wout{i}=func{1}(w{i},pars{:});
                end
            end
        end
    else
        for i=1:numel(w)
            if ~isempty(func{i})
                pars=parameter_set(plist{i},p{i});
                if ~iscell(pars), pars={pars}; end  % make a cell for convenience
                multifit_store_state (isfitting,i,true,store_vals)
                if xye(i)
                    wout{i}=w{i};
                    wout{i}.y=func{i}(w{i}.x{:},pars{:});
                    wout{i}.e=zeros(size((w{i}.y)));
                else
                    wout{i}=func{i}(w{i},pars{:});
                end
            end
        end
    end
end

% Background function calculations
if eval_back
    if numel(bkdfunc)==1
        if ~isempty(bkdfunc{1})
            pars=parameter_set(bplist{1},bp{1});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            for i=1:numel(w)
                multifit_store_state (isfitting,i,false,store_vals)
                if xye(i)
                    if isempty(wout{i})
                        wout{i}=w{i};
                        wout{i}.y=bkdfunc{1}(w{i}.x{:},pars{:});
                        wout{i}.e=zeros(size((w{i}.y)));
                    else
                        wout{i}.y=wout{i}.y + bkdfunc{1}(w{i}.x{:},pars{:});
                    end
                else
                    if isempty(wout{i})
                        wout{i}=bkdfunc{1}(w{i},pars{:});
                    else
                        wout{i}=wout{i}+bkdfunc{1}(w{i},pars{:});
                    end
                end
            end
        end
    else
        for i=1:numel(w)
            if ~isempty(bkdfunc{i})
                pars=parameter_set(bplist{i},bp{i});
                if ~iscell(pars), pars={pars}; end  % make a cell for convenience
                multifit_store_state (isfitting,i,false,store_vals)
                if xye(i)
                    if isempty(wout{i})
                        wout{i}=w{i};
                        wout{i}.y=bkdfunc{i}(w{i}.x{:},pars{:});
                        wout{i}.e=zeros(size((w{i}.y)));
                    else
                        wout{i}.y=wout{i}.y + bkdfunc{i}(w{i}.x{:},pars{:});
                    end
                else
                    if isempty(wout{i})
                        wout{i}=bkdfunc{i}(w{i},pars{:});
                    else
                        wout{i}=wout{i}+bkdfunc{i}(w{i},pars{:});
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
