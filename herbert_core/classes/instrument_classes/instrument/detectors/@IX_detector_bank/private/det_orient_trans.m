function varargout = det_orient_trans (val_in, type_in, type_out)
% Check the detector orientations, or convert from one type to another
%
% Check validity of orientation information:
%   >> ndet = det_orient_trans (val_in, type_in)
%
% Convert orientation information:
%   >> [ndet, val_out] = det_orient_trans (val_in, type_in, type_out)
%
% List of available orientation types:
%   >> types = det_orient_trans
%
%
% Input:
% ------
%   val_in      Detector orientation information for one or more detectors
%   type_in     Input detector orientation information type. One of:
%                   'dmat' 'rotvec'
%   type_out    Output detector orientation information type. One of:
%                   'dmat' 'rotvec'
%              [Default: same as type_in]
%
% The definitions of the detector information types are:
%   'rotvec'    Rotation vector(s) that gives the orientation of the detector
%              coordinate frame(s) with respect to the secondary spectrometer
%              frame. Vector length 3 or array size [3,ndet] (degrees).
%               The detector frame is obtained by rotation according to the vector
%              which has components in the secondary frame given by V
%
%   'dmat'      Rotation matrix that gives components in secondary spectrometer
%              frame given those in the detector frame:
%                       x_f(i) = Sum_j [D(i,j) x_det(j)]
%              [Note that this definition means that D is the inverse of the
%               matrix obtained using rotmat_to_rotvec]
%
% Output:
% -------
%   ndet        Number of detectors for which detector orientation information
%              is provided
%   val_out     Detector information in the form of the requested output type
%              (Note: rotation vector for a single detector is a column, so that
%              if the input was a row for a single detector, and the requested
%              output is also as a rotation vector, then the vector will have
%              been transposed.)


valid_types = {'dmat','rotvec'};

% Catch case of requesting available orientation types
if nargin==0
    varargout{1} = valid_types;
    return
end

% Check input argument types
if nargin==2 || nargin==3
    % Check arguments
    if ~isnumeric(val_in)
        error('HERBERT:IX_detector_bank:invalid_argument',...
            'Detector orientation information data must be a numeric array')
    end
    
    if is_string(type_in) && ~isempty(type_in)
        iin = stringmatchi(type_in, valid_types);
        if ~isscalar(iin)
            error('HERBERT:IX_detector_bank:invalid_argument',...
                ['Unrecognised or ambiguous input detector orientation ',...
                'information type'])
        end
    else
        error('HERBERT:IX_detector_bank:invalid_argument',...
            'Check input detector orientation information type')
    end
    
    if nargin==3
        if is_string(type_out) && ~isempty(type_out)
            iout = stringmatchi(type_out, valid_types);
            if ~isscalar(iout)
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['Unrecognised or ambiguous input detector orientation ',...
                    'information type'])
            end
        else
            error('HERBERT:IX_detector_bank:invalid_argument',...
                'Check input detector orientation information type')
        end
    else
        iout = iin;
    end
    
else
    error('HERBERT:IX_detector_bank:invalid_argument',...
        'Check number of input arguments')
end

% Check output arguments
if nargout<=2
    orientation_output = (nargout>1);   % flag if conversion output
else
    error('HERBERT:IX_detector_bank:invalid_argument',...
        'Too many output arguments.')
end

% Perform calculations
tol = 1e-13;
if strcmp(valid_types{iin}, 'dmat')
    % Check that the input is [3,3,ndet] as a stack of 3x3 rotation matricies
    % A rotation matrix has the property that its transpose is its inverse. To
    % check the input has the this property for all detectors, permute the first
    % two dimensions. Note, permute(val_in,[2,1,3]) works even if
    % numel(size(val_in))=2, i.e. just a 3x3 matrix. Similarly, size(val_in,3)
    % correctly return 1 for this case.
    if (numel(size(val_in))==2 || numel(size(val_in))==3) &&...
            size(val_in,1)==3 && size(val_in,2)==3 && size(val_in,3)>0
        diff_with_eye = mtimesx_horace (val_in, permute(val_in,[2,1,3])) - ...
            repmat(eye(3), [1,1,size(val_in,3)]);
        if max(abs(diff_with_eye(:))) > tol
            error('HERBERT:IX_detector_bank:invalid_argument',...
                'Not all detector rotation matricies are valid');
        end
    else
        error('HERBERT:IX_detector_bank:invalid_argument',...
            'Detector rotation matrix array must have size [3,3,ndet]');
    end
    ndet = size(val_in,3);      % works even if ndet==1
    
    % Orientation output requested, with conversion if requested
    if orientation_output
        if strcmp(valid_types{iout}, 'dmat')
            val_out = val_in;   % nothing to do
        elseif strcmp(valid_types{iout}, 'rotvec')
            val_out = rotmat_to_rotvec (permute (val_in, [2,1,3]));
        else
            error('HERBERT:IX_detector_bank:invalid_argument',...
                'Conversion case not caught. Code error - contact developers.')
        end
    end
    
elseif strcmp(valid_types{iin},'rotvec')
    % Check size is [3,ndet], or [1,3] if a single detector is also valid
    if ~numel(size(val_in))==2 || ~((size(val_in,1)==3 && size(val_in,2)>0) || ...
            (size(val_in,1)==1 && size(val_in,2)==3))
        error('HERBERT:IX_detector_bank:invalid_argument',...
            'Rotation vector array must have size [3,ndet]');
    end
    if size(val_in,1)==3
        ndet = size(val_in,2);
    else
        ndet = 1;
        val_in = val_in(:);     % convert to column vector
    end
    
    % Convert if requested
    if orientation_output
        if strcmp(valid_types{iout}, 'dmat')
            val_out = rotvec_to_rotmat (val_in);
            val_out = permute (val_out, [2,1,3]);
        elseif strcmp(valid_types{iout}, 'rotvec')
            val_out = val_in;   % nothing to do
        else
            error('HERBERT:IX_detector_bank:invalid_argument',...
                'Conversion case not caught. Code error - contact developers.')
        end
    end
end

% Fill output
if nargout>=0
    varargout{1} = ndet;
end
if nargout>=2
    varargout{2} = val_out;
end
