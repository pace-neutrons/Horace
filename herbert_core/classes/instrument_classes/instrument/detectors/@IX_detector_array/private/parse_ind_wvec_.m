function [sz, ind, wvec] = parse_ind_wvec_ (obj, varargin)
% Check that the detector indices and wavevectors are consistently sized arrays
%
%   >> [sz, ind, wvec] = parse_ind_wvec_ (obj, wvec_in)
%
%   >> [sz, ind, wvec] = parse_ind_wvec_ (obj, ind_in, wvec_in)
%
%
% Input:
% ------
%   obj         Scalar instance of IX_det_abstractType
%
%   ind_in      Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   wvec_in     Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   sz          Size of output arrays - used to reshape output.
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec.
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Note that no check is made that ind is in range for the
%               detector object. This is a potentially expensive check.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.


% *** NOTE: this is identical to IX_det_abstractType/parse_ind_wvec_
%     In an ideal world we would have IX_detector_array inherit somehow,
%     but save that apple-polishing for later.


% Check ind and wvec
if numel(varargin)==1
    % Only wvec given; ind will be made the default 1:ndet
    wvec = varargin{1};
    if ~isempty(wvec)
        ind = 1:obj.ndet;
        if isscalar(ind) || isscalar(wvec) || numel(ind)==numel(wvec)
            if ~isscalar(wvec)
                sz = size(wvec);
            else
                sz = size(ind);
            end
        else
            error ('HERBERT:parse_ind_wvec_:invalid_arguments',...
                ['If ''wvec'' only is provided, and it is an array, then ',...
                 'the number of elements must equal the number of detectors',...
                 'if there is more than one']);
        end
    else
        error ('HERBERT:parse_ind_wvec_:invalid_arguments',...
            'Input argument(s) must not be empty');
    end
    
elseif numel(varargin)==2
    % Both ind and wvec are given
    ind = varargin{1};
    wvec = varargin{2};
    if ~(isempty(ind) || isempty(wvec))
        if isscalar(ind) || isscalar(wvec) || numel(ind)==numel(wvec)
            if ~isscalar(wvec)
                sz = size(wvec);
            else
                sz = size(ind);
            end
        else
            error ('HERBERT:parse_ind_wvec_:invalid_arguments',...
                ['If ''ind'' and ''wvec'' are both arrays, they must ', ...
                'have the same number of elements']);
        end
    else
        error ('HERBERT:parse_ind_wvec_:invalid_arguments',...
            'Input argument(s) must not be empty');
    end
    
else
    error ('HERBERT:parse_ind_wvec_:invalid_arguments',...
        'Check the number of input arguments')
end
