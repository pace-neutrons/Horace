function [ok,mess,nopt,ind_dataset_class,ind_wrapfun] = strip_trailing_opts_(varargin)
% Allow one or both of dataset_class and wrapfun at the tail of an argument list

ok = true; mess = ''; nopt = 0; ind_dataset_class=[]; ind_wrapfun = [];
is_wrapfun = @(x)isa(x,'mfclass_wrapfun');
is_dataset_class = @(x)(isa(x,'char') && is_string(x) && ~isempty(x));

narg = numel(varargin);
if narg>=1
    if is_wrapfun(varargin{end})
        nopt=1; ind_wrapfun = narg;
    elseif is_dataset_class(varargin{end})
        nopt=1; ind_dataset_class = narg;
    else
        return
    end
end

if narg>=2
    if is_wrapfun(varargin{end-1})
        if isempty(ind_wrapfun)
            nopt=2; ind_wrapfun = narg-1;
        else
            ok=false; mess='Optional function wrapper given twice';
        end
    elseif is_dataset_class(varargin{end-1})
        if isempty(ind_dataset_class)
            nopt=2; ind_dataset_class = narg-1;
        else
            ok=false; mess='Optional dataset class name given twice';
        end
    else
        return
    end
end

