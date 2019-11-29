function varargout = det_orient_trans (val, type_in, type_out)
% Check the detector orientation, or convert from one type to another
%
% Convert:
%   >> [ok,mess,ndet,val_out] = det_orient_trans (val_in, type_in, type_out)
%
% Check validity:
%   >> [ok,mess,ndet] = det_orient_trans (val_in, type_in)
%
% List of options:
%   >> types = det_orient_trans
%
% Input:
% ------
%   val_in      Detector orientation array
%   type_in     Type of input. One of:
%                   'dmat' 'rotvec'
%   type_out    Type of output requested. One of:
%                   'dmat' 'rotvec'
%
% The definitions of the various type are:
%   'rotvec',V  Rotation vector(s) that gives the orientation of the detector
%              coordinate frame(s) with respect to the secondary spectrometer
%              frame. Vector length 3 or array size [3,ndet] (degrees).
%               The detector frame is obtained by rotation according to the vector
%              which has components in the secondary frame given by V
%
%   'dmat',D    Rotation matrix that gives components in secondary spectrometer
%              frame given those in the detector frame:
%                       x_f(i) = Sum_j [D(i,j) x_det(j)]
%              [Note that this definition means that D is the inverse of the
%               matrix obtained using rotmat_to_rotvec]


type = {'dmat','rotvec'};

% Catch case of requesting orientation types
if nargin==0
    varargout{1} = type;
    return
end

% Default output
ok = true;
mess = '';
ndet = [];
val_out = [];

% Validating or converting orientation type
if nargin==2 || nargin==3
    % Check arguments
    if ~isnumeric(val)
        error('Orientation data must be a numeric array')
    end
    
    if is_string(type_in) && ~isempty(type_in)
        iin = stringmatchi(type_in,type);
        if ~isscalar(iin)
            error('Unrecognised or ambiguous input orientation type')
        end
    else
        error('Check input orientation type')
    end
    if nargin==3
        if is_string(type_out) && ~isempty(type_out)
            iout = stringmatchi(type_out,type);
            if ~isscalar(iout)
                error('Unrecognised or ambiguous output orientation type')
            end
        else
            error('Check output orientation type')
        end
    end
    
else
    error('Check number of input arguments')
end

% Check input
tol = 1e-13;
if strcmp(type{iin},'dmat')
    % Check that the input is [3,3,ndet] as a stack of 3x3 rotation matricies
    if (numel(size(val))==2 || numel(size(val))==3) &&...
            size(val,1)==3 && size(val,2)==3 && size(val,3)>0
        diff_with_eye = mtimes_array(val,permute(val,[2,1,3])) - repmat(eye(3),[1,1,size(val,3)]);
        if max(abs(diff_with_eye(:)))>tol
            ok = false;
            mess = 'Not all rotation matricies are valid';
        end
    else
        ok = false;
        mess = 'Rotation matrix array must have size [3,3,ndet]';
    end
    ndet = size(val,3);
    
    % Convert if requested
    if nargin==3 && ok
        if strcmp(type{iout},'dmat')
            val_out = val;  % nothing to do
        elseif strcmp(type{iout},'rotvec')
            val_out = rotmat_to_rotvec(permute(val,[2,1,3]));
        else
            error('Conversion case not caught. Code error - contact developers.')
        end
    end
    
elseif strcmp(type{iin},'rotvec')
    % Check size is [3,ndet]
    if ~(numel(size(val))==2 && size(val,1)==3 && size(val,2)>0)
        ok = false;
        mess = 'Rotation vector array must have size [3,ndet]';
    end
    ndet = size(val,2);
    
    % Convert if requested
    if nargin==3 && ok
        if strcmp(type{iout},'dmat')
            val_out = rotvec_to_rotmat(val);
            val_out = permute(val_out,[2,1,3]);
        elseif strcmp(type{iout},'rotvec')
            val_out = val;  % nothing to do
        else
            error('Conversion case not caught. Code error - contact developers.')
        end
    end
end

% Fill output
varargout{1} = ok;
if nargout>=2
    varargout{2} = mess;
end
if nargout>=3
    varargout{3} = ndet;
end
if nargin==3 && nargout>=4
    varargout{4} = val_out;
end
