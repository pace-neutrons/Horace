function obj = remove_data (obj, i)
% Remove data sets, clearing corresponding functions and constraints:
%
%   >> obj = obj.remove_data        % Remove all data
%   >> obj = obj.remove_data (i)    % Remove ith dataset
%
% The global or local status of the foreground and background functions is
% retained.


if nargin==1
    % Remove all datasets. If object already has no data, then nothing to do.
    if obj.ndatatot_>0
        obj = remove_data_private_ (obj);
    end
else
    % Remove particular datsets
    if obj.ndatatot_>0
        if isscalar(i) && isa_index(i,obj.ndatatot_)
            obj = remove_data_private_ (obj, i);
        else
            error(['Check optional argument is a scalar in the range 1 -',num2str(ndatatot)])
        end
    else
        error('Cannot remove data set(s) as none are currently set')
    end
end

%--------------------------------------------------------------------------------------------------
function obj = remove_data_private_ (obj, id)
% Assumes there is data, and that item is valid if given

if nargin==1 || (isscalar(obj.ndata_) && obj.ndata_==1)
    % Remove all data (including case of removing the sole data set)
    % This is the same as reinitialising the object, with the exception that
    % the global/local status of the functions should be retained
    obj = obj.set_data();
    
else
    % There must be at least two data sets if reached this point, so that
    % there will be at least one left after the removal of the dataset

    % Remove data set:
    item = obj.item_(id);
    if obj.ndata_(item)==1      % removing a scalar dataset item
        keep = true(size(obj.data_));
        keep(item)=false;
        obj.data_ = obj.data_(keep);
        obj.ndim_ = obj.ndim_(keep);
    else
        ix = obj.ix_(id);
        keep = true(size(obj.data_{item}));
        keep(ix)=false;
        obj.data_{item} = obj.data_{item}(keep);
        obj.ndim_(item) = obj.ndim_(keep);
    end
    [obj.ndata_,obj.ndatatot_,obj.item_,obj.ix_] = data_indicies(obj.ndim_);
    keepw =  true(size(obj.w_));
    keepw(id) = false;
    obj.w_ = obj.w_(keepw);
    obj.msk_ = obj.msk_(keepw);

    % Remove function and constraints
    if obj.foreground_is_local_ || obj.background_is_local_
        S_fun = obj.get_fun_props_;
        S_con = obj.get_constraints_props_;
        if obj.foreground_is_local_
            S_fun = fun_remove (S_fun, true, id);
            S_con = constraints_remove (S_con, obj.np_, obj.nbp_, id, []);
        end
        if obj.background_is_local_
            S_fun = fun_remove (obj.get_fun_props_, false, id);
            S_con = constraints_remove (obj.get_constraints_props_, obj.np_, obj.nbp_, [], id);
        end
        obj = obj.set_fun_props_(S_fun);
        obj = obj.set_constraints_props_ (S_con);
    end
end
