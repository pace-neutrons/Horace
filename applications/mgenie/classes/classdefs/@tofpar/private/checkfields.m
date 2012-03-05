function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid sqw object, empty string if is valid.
%   wout    Output structure or object of the class 
%           wout can be an altered version of the input structure or object that must
%           have the same fields. For example, if a column array is provided for a field
%           value, but one wants the array to be a row, then checkfields could take the
%           transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Because checkfields must be in the folder defining the class, it
%     can change fields of an object without calling set.m, which means
%     that we do not get recursion from the call that set.m makes to 
%     isvalid.m and the consequent call to checkfields.m ...
%       
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)
    
% Original author: T.G.Perring

fields = {'emode';'delta';'x1';'x2';'twotheta';'azimuth';'efix'};  % column vector of expected fields in class structure

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    % Check emode
    if isnumeric(w.emode) && isscalar(w.emode)
        w.emode=round(w.emode);
        if w.emode<0 || w.emode>2
            message='Value of emode must be 0 (elastic), 1 (direct geometry) or 2 (indeirect geometry)'; return
        end
    else
        message='Check emode is a numeric scalar'; return
    end
    
    % Check delta
    if ~(isnumeric(w.delta) && isscalar(w.delta))
        message='Check delta is a numeric scalar'; return
    end
    
    % Check x1
    if ~(isnumeric(w.x1) && isscalar(w.x1) && w.x1>0)
        message='Primary flight path must be greater than zero'; return
    end
    
    % Check x2
    % (NaN is acceptable - needed for conventional case of mspec_core when av_mode = 'none')
    if ~(isnumeric(w.x2) && isscalar(w.x2) && ((w.emode>0 && w.x2>0)||w.emode==0||isnan(x2)))
        message='Secondary flight path must be a scalar, and greater than zero if emode=1 or 2'; return
    end
    
    % Check twotheta
    if ~(isnumeric(w.twotheta) && isscalar(w.twotheta))
        message='Check twotheta is a numeric scalar'; return
    end
    
    % Check azimuth
    if ~(isnumeric(w.azimuth) && isscalar(w.azimuth))
        message='Check azimuth is a numeric scalar'; return
    end
    
    % Check efix
    if w.emode==0
        if isempty(w.efix)
            wout.efix=0;
        elseif isnumeric(w.efix) && isscalar(w.efix)
            if w.efix~=0
                message='Fixed energy must be 0 for white beam diffraction i.e. emode=0'; return
            end
        else
            message='Check fixed energy is a numeric scalar and 0 for white beam diffraction i.e. emode=0'; return
        end
    else
        if isnumeric(w.efix) && isscalar(w.efix)
            if w.efix<=0
                message='Fixed energy must be greater than zero for inelastic scattering i.e. emode=1 or 2'; return
            end
        else
            message='Check fixed energy is a numeric scalar greater than zero for inelastic scattering i.e. emode=1 or 2'; return
        end
    end
    
else
    message='fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
