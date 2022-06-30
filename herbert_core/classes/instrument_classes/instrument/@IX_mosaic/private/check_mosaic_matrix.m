function [ok,mess,val_out,S,V] = check_mosaic_matrix (val)
% Check argument is valid scalar, vector, or 3x3 matrix that describes the
% covariance of the mosaic about three orthonormal axes.
% Actually, the arguments are FWHH not standard deviations, (FWHH^2 not
% covariances in the case of a matrix)

ok = true;
mess = '';
if isnumeric(val)
    if isscalar(val) && val>=0
        val_out = val;
        S = repmat(val_out,1,3);
        V = eye(3);
    elseif isvector(val) && numel(val)==3 && all(val>=0)
        val_out = val(:)';  % make row
        S = val;
        V = eye(3);
    elseif numel(size(val))==2 && all(size(val)==[3,3])
        small = 1e-10;
        del = val-val';
        if all(abs(del(:))<small*abs(val(:)) | abs(val(:))<small)
            val_out = val;
            [V,D] = eig(val);
            S = sqrt(diag(D));
            if all(S>=0)
                return
            else
                ok = false;
                mess = 'The mosaic matrix must be positive definite';
                val_out = []; S = []; V = [];
            end
        else
            ok = false;
            mess = 'The mosaic matrix must be symmetric';
            val_out = []; S = []; V = [];
        end
    else
        ok = false;
        mess = 'The mosaic must be a positive scalar, positive 3-vector, or a 3x3 positive definite matrix';
        val_out = []; S = []; V = [];
    end
else
    ok = false;
    mess = 'The mosaic must be a positive scalar, positive 3-vector, or a 3x3 positive definite matrix';
    val_out = []; S = []; V = [];
end
