function wout=multifit_func_eval(w,xye,func,bkdfunc,pin,bpin,pf,pinfo)
% Calculate the functions over the input data objects

wout=cell(size(w));

[p,bp]=ptrans(pf,pinfo);    % Get latest numerical parameters

% Calculate global function calculated values
pars=parameter_set(pin,p);
if ~iscell(pars), pars={pars}; end  % make a cell for convenience
for i=1:numel(w)
    if xye(i)
        wout{i}=w{i};
        wout{i}.y=func(w{i}.x{:},pars{:});
        wout{i}.e=zeros(size((w{i}.x{1})));
    else
        wout{i}=func(w{i},pars{:});
    end
end

% Calculate background function calculation
for i=1:numel(w)
    if ~isempty(bkdfunc{i})
        pars=parameter_set(bpin{i},bp{i});
        if ~iscell(pars), pars={pars}; end  % make a cell for convenience
        if xye(i)
            wout{i}.y=wout{i}.y + bkdfunc{i}(w{i}.x{:},pars{:});
        else
            wtmp=bkdfunc{i}(w{i},pars{:});
            wout{i}=wout{i}+wtmp;
        end
    end
end
