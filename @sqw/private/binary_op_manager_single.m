function wout = binary_op_manager_single(w1,w2,binary_op)
% Implement binary operator for objects with a signal and a variance array.
%
% Generic method, generalised for sqw objects, that requires: 
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)
%   (3) have private function that returns class name
%           >> name = classname     % no argument - gets called by its association with the class

if ~isa(w1,'double') && ~isa(w2,'double')
    if (isa(w1,classname) && is_sqw_type(w1)) && (isa(w2,classname) && is_sqw_type(w2))
        [n1,sz1]=dimensions(w1);
        [n2,sz2]=dimensions(w2);
        if n1==n2 && all(sz1==sz2) && all(w1.data.npix(:)==w2.data.npix(:))
            wout = w1;
            result = binary_op(sigvar(w1.data.pix(8,:),w1.data.pix(9,:)), sigvar(w2.data.pix(8,:),w2.data.pix(9,:)));
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error('sqw type objects do not have commensurate arrays for binary operations')
        end
    elseif (isa(w1,classname) && is_sqw_type(w1))
        sz = sigvar_size(w2);
        if isequal([1,1],sz) || isequal(size(w1.data.npix),sz)
            wout = w1;
            wtmp = sigvar(w2);
            if ~isequal([1,1],sz)
                stmp = replicate_array(wtmp.s, w1.data.npix)';
                etmp = replicate_array(wtmp.e, w1.data.npix)';
                wtmp = sigvar(stmp,etmp);
            end
            result = binary_op(sigvar(w1.data.pix(8,:),w1.data.pix(9,:)), wtmp);
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    elseif (isa(w2,classname) && is_sqw_type(w2))
        sz = sigvar_size(w1);
        if isequal([1,1],sz) || isequal(size(w2.data.npix),sz)
            wout = w2;
            wtmp = sigvar(w1);
            if ~isequal([1,1],sz)
                stmp = replicate_array(wtmp.s, w2.data.npix)';
                etmp = replicate_array(wtmp.e, w2.data.npix)';
                wtmp = sigvar(stmp,etmp);
            end
            result = binary_op(wtmp, sigvar(w2.data.pix(8,:),w2.data.pix(9,:)));
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    else    % one or both are dnd-type
        sz1 = sigvar_size(w1);
        sz2 = sigvar_size(w2);
        if isequal(sz1,sz2)
            if isa(w1,classname), wout = w1; else wout = w2; end
            result = binary_op(sigvar(w1), sigvar(w2));
            wout = sigvar_set(wout, result);
        else
            error ('Sizes of signal arrays in the objects are different')
        end
    end
    
elseif ~isa(w1,'double') && isa(w2,'double')
    if is_sqw_type(w1)
        if isscalar(w2) || isequal(size(w1.data.npix),size(w2))
            wout = w1;
            if ~isscalar(w2)
                s_tmp = replicate_array(w2, w1.data.npix)';
            else
                s_tmp = w2;
            end
            result = binary_op(sigvar(w1.data.pix(8,:),w1.data.pix(9,:)), sigvar(s_tmp,[]));
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    else
        if isscalar(w2) || isequal(size(w1.s),size(w2))
            wout = w1;
            result = binary_op(sigvar(w1), sigvar(w2,[]));
            wout = sigvar_set(wout,result);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    end
    
elseif isa(w1,'double') && ~isa(w2,'double')
    if is_sqw_type(w2)
        if isscalar(w1) || isequal(size(w2.data.npix),size(w1))
            wout = w2;
            if ~isscalar(w1)
                s_tmp = replicate_array(w1, w2.data.npix)';
            else
                s_tmp = w1;
            end
            result = binary_op(sigvar(s_tmp,[]), sigvar(w2.data.pix(8,:),w2.data.pix(9,:)));
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    else
        if isscalar(w1) || isequal(size(w2.s),size(w1))
            wout = w2;
            result = binary_op(sigvar(w1,[]), sigvar(w2));
            wout = sigvar_set(wout,result);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    end
    
else
    error ('binary operations between objects and doubles only defined')
end
