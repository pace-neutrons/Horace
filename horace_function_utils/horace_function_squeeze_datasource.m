function wout=horace_function_squeeze_datasource(w)
% Recover the original input data source from a data source structure
%
%   >> wout=horace_function_squeeze_datasource(w)
%
%   w       Horace object (sqw,d0d,d1d,...d4d), file name or data source structure
%           The file name can be a single file or cell array of file names.
%
%   wout    Original data source: Horace object or file name.
%           If the original was a file name, then the return value is a cell array,
%          even if only one file.
%
% The consistency checks are not comprehensive.

if isstruct(w) && isfield(w,'data')
    if iscellstr(w.data)
        wout=w.data;
    elseif is_horace_data_object(w.data)
        [wout,mess]=recover_object(w.data);
        if ~isempty(mess)
            error(mess)
        end
    else
        error('Invalid data source')
    end
elseif is_horace_data_object(w)
    [wout,mess]=recover_object(w);
    if ~isempty(mess)
        error(mess)
    end
elseif is_filename(w)
    if ~iscellstr(w)    
        wout=cellstr(w);
    else
        wout=w;
    end
else
    error('Invalid data source')
end

%------------------------------------------------------------------------------------------------------------
function [wout,mess]=recover_object(w)
% Squeeze the Horace object (assumes it is a Horace object)
if isa(w,'sqw')
    if all(is_sqw_type(w))
        wout=w;
    elseif ~any(is_sqw_type(w))
        ndims=dimensions(w(1));
        for i=2:numel(w)
            if dimensions(w(i))~=ndims
                wout=[];
                mess='Not all the dimensions of the dnd-type data objects are the same in the data source';
                return
            end
        end
        wout=dnd(w);
    else
        wout=[];
        mess='Invalid data source: all objects must be either sqw-type, or dnd-type with the same dimensionality';
        return
    end
else
    wout=w;
end
mess='';
