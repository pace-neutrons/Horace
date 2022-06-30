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
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec_in     Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               This serves only to determine the size of the output arrays
%               from calling functions in the case when ind is a scalar
%
% If both ind and wvec are arrays, then they must have the same number of elements
%
%
% Output:
% -------
%   sz          Size of output arrays - used to reshape output.
%               If one of ind or wvec is scalar, then it will
%              be the size of that array; if both are arrays, then
%              it will be the size of wvec
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.


% Check ind and wvec
if numel(varargin)==1
    if ~isempty(varargin{1})
        ind = 1:obj.ndet;
        if isscalar(ind) || isscalar(varargin{1}) ||...
                numel(ind)==numel(varargin{1})
            wvec = varargin{1};
            if ~isscalar(varargin{1})
                sz = size(varargin{1});
            else
                sz = size(ind);
            end
        else
            throwAsCaller(MException('parse_ind_wvec_:invalid_arguments',...
                'If ''wvec'' is an array, the number of elements must equal the number of detectors'));
        end
    else
        throwAsCaller(MException('parse_ind_wvec_:invalid_arguments',...
            'Input argument(s) must not be empty'));
    end
    
elseif numel(varargin)==2
    if ~(isempty(varargin{1}) || isempty(varargin{2}))
        if isscalar(varargin{1}) || isscalar(varargin{2}) ||...
                numel(varargin{1})==numel(varargin{2})
            ind = varargin{1};
            wvec = varargin{2};
            if ~isscalar(varargin{2})
                sz = size(varargin{2});
            else
                sz = size(ind);
            end
        else
            throwAsCaller(MException('parse_ind_wvec_:invalid_arguments',...
                'If ''ind'' and ''wvec'' are both arrays, they must have the same number of elements'));
        end
    else
        throwAsCaller(MException('parse_ind_wvec_:invalid_arguments',...
            'Input argument(s) must not be empty'));
    end
    
else
    throwAsCaller(MException('parse_ind_wvec_:invalid_arguments',...
        'Check the number of input arguments'))
end
