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
        % w1 and w2 are both sqw-type sqw objects
        [n1,sz1]=dimensions(w1);
        [n2,sz2]=dimensions(w2);
        if n1==n2 && all(sz1==sz2) && all(size(w2.data.npix)==size(w1.data.npix))
            % npix for both sqw objects have to be equal as one would not
            % be able to extraxt pix data otherwise. 
            npix1 = sum(reshape(w1.data.npix,numel(w1.data.npix),1));
            npix2 = sum(reshape(w2.data.npix,numel(w2.data.npix),1));            
            if npix1~=npix2
                nDifrToPrint = 3; % number of elements to be printed if the data are different
                difr=find(w1.data.npix(:)~=w2.data.npix(:));
                nDifr=numel(difr);
                numEl=numel(w2.data.npix);
                fprintf('ERROR in binary operations: left operand has %d npix and right operand has %d npix contributed into it\n',npix1,npix2)
                if nDifr>nDifrToPrint
                    error('SQW type objects has %d npix elements and %d of them are different',numEl,nDifr)
                else
                    for i=1:nDifr
                       fprintf('Element N %d in npix for left operand equal to: %d and for right operand to: %d\n',difr(i),w1.data.npix(difr(i)),w2.data.npix(difr(i)));
                    end
                    error('Two sqw objects have different npix numbers ')
                end
            end
            wout = w1;
            result = binary_op(sigvar(w1.data.pix(8,:),w1.data.pix(9,:)), sigvar(w2.data.pix(8,:),w2.data.pix(9,:)));
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error('sqw type objects do not have commensurate arrays for binary operations')
        end
    elseif (isa(w1,classname) && is_sqw_type(w1))
        % w1 is sqw-type, but w2 could be anything that is not a double e.g. dnd-type sqw object, or a d2d object, or sigvar object etc.
        sz = sigvar_size(w2);
        if isequal([1,1],sz) || isequal(size(w1.data.npix),sz)
            wout = w1;
            % Need to remove bins with npix=0 in the non-sqw object in the binary operation
            if isa(w2,classname)||isa(w2,'d0d')||isa(w2,'d1d')||isa(w2,'d2d')||isa(w2,'d3d')||isa(w2,'d4d')
                if isa(w2,classname)    % must be a dnd-type sqw object
                    omit=logical(w2.data.npix);
                else    % must be a d0d,d1d...
                    omit=logical(w2.npix);
                end
                wout=mask(wout,omit);
            end
            wtmp = sigvar(w2);
            if ~isequal([1,1],sz)
                stmp = replicate_array(wtmp.s, wout.data.npix)';
                etmp = replicate_array(wtmp.e, wout.data.npix)';
                wtmp = sigvar(stmp,etmp);
            end
            result = binary_op(sigvar(wout.data.pix(8,:),wout.data.pix(9,:)), wtmp);
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    elseif (isa(w2,classname) && is_sqw_type(w2))
        % w2 is sqw-type, but w1 could be anything that is not a double e.g. dnd-type sqw object, or a d2d object, or sigvar object etc.
        sz = sigvar_size(w1);
        if isequal([1,1],sz) || isequal(size(w2.data.npix),sz)
            wout = w2;
            % Need to remove bins with npix=0 in the non-sqw object in the binary operation
            if isa(w1,classname)||isa(w1,'d0d')||isa(w1,'d1d')||isa(w1,'d2d')||isa(w1,'d3d')||isa(w1,'d4d')
                if isa(w1,classname)    % must be a dnd-type sqw object
                    omit=logical(w1.data.npix);
                else    % must be a d0d,d1d...
                    omit=logical(w1.npix);
                end
                wout=mask(wout,omit);
            end
            wtmp = sigvar(w1);
            if ~isequal([1,1],sz)
                stmp = replicate_array(wtmp.s, wout.data.npix)';
                etmp = replicate_array(wtmp.e, wout.data.npix)';
                wtmp = sigvar(stmp,etmp);
            end
            result = binary_op(wtmp, sigvar(wout.data.pix(8,:),wout.data.pix(9,:)));
            wout.data.pix(8:9,:) = [result.s;result.e];
            wout = recompute_bin_data (wout);
        else
            error ('Check that the numeric variable is scalar or array with same size as object signal')
        end
    else    % one or both are dnd-type
        %This block of code can be changed in the same manner as the dnds.
        sz1 = sigvar_size(w1);
        sz2 = sigvar_size(w2);
        if isequal(sz1,sz2)
            if isa(w1,classname), wout = w1; else wout = w2; end
            if isa(w1,classname) && isa(w2,classname)
                wout.data.npix(w2.data.npix==0)=0;    % ensures that empty bins in either w1 or w2 result in an empty bin
            end
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
