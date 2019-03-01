function [ind, wvec] = parse_ind_and_wvec_ (obj, varargin)
% Check that the wavevector
%
%   >> [ind, wvec] = parse_ind_and_wvec (obj, wvec_in)
%
%   >> [ind, wvec] = parse_ind_and_wvec (obj, ind_in, wvec_in)
%
%
% Input:
% ------
%   ind         Indicies of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%
% If both ind and wvec are arrays, then they must have the same number of elements


if numel(varargin)==1
    if ~isempty(varargin{1})
        ind = 1:obj.ndet;
        if isscalar(ind) || isscalar(varargin{1}) ||...
                numel(ind)==numel(varargin{1})
            wvec = varargin{1};
        else
            throwAsCaller(MException('parse_ind_and_wvec_:invalid_arguments',...
                'If the number of detectors and ''wvec'' are both arrays, they must have the same number of elements'));
        end
    else
        throwAsCaller(MException('parse_ind_and_wvec_:invalid_arguments',...
            'Input argument(s) must not be empty'));
    end
    
elseif numel(varargin)==2
    if ~(isempty(varargin{1}) || isempty(varargin{2}))
        if isscalar(varargin{1}) || isscalar(varargin{2}) ||...
                numel(varargin{1})==numel(varargin{2})
            ind = varargin{1};
            wvec = varargin{2};
        else
            throwAsCaller(MException('parse_ind_and_wvec_:invalid_arguments',...
                'If ''ind'' and ''wvec'' are both arrays, they must have the same number of elements'));
        end
    else
        throwAsCaller(MException('parse_ind_and_wvec_:invalid_arguments',...
            'Input argument(s) must not be empty'));
    end
    
else
    throwAsCaller(MException('parse_ind_and_wvec_:invalid_arguments',...
        'Check the number of input arguments'))
end
