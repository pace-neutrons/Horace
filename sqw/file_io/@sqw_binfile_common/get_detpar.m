function det = get_detpar(obj)
% Read the detector parameter from propertly initialized binary file.
%
%   >> det = obj.get_sqw_detpar()
%
% Input:
% ------
%   obj        properly initialized sqw loader object
%
% Output:
% -------
%   det         Structure containing fields read from file (details below)
%
%
% Fields read from file are:
% --------------------------
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number
%   det.x2          Row vector of secondary flightpath (m)
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
if ischar(obj.num_contrib_files)
    error('SQW_FILE_INTERFACE:runtime_error',...
        ' get_sqw_detpar called on un-initialized loader')
end
sz = obj.data_pos_-obj.detpar_pos_;

fseek(obj.file_id_,obj.detpar_pos_,'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_INTERFACE:runtime_error',...
        'can not move to the start of the detectors data, Reason: %s',mess);
end
bytes = fread(obj.file_id_,sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_INTERFACE:runtime_error',...
        'can not read the detectors data, Reason: %s',mess);
end


det_format = obj.get_detpar_form();
det = obj.sqw_serializer_.deserialize_bytes(bytes,det_format,1);

% convert to double if necessary
if obj.convert_to_double
    det = obj.do_convert_to_double(det);
end


