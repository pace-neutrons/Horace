function inst = convert_legacy_instrument_structure (S)
% Convert an instrument structure into a new instrument object#
%
%   >> inst = convert_legacy_instrument_structure (S)
%
% If the structure is not recognised as an instrumentm the class is
% returned unchanged
%
% Input:
% ------
%   S       Structure (scalar only)
%
% Output:
% -------
%   inst    Instrument object: either IX_inst_DGfermi or IX_inst_DGdisk
%           If the instrument 

if ~isstruct(S) || ~isscalar(S)
    error('Can only accept a scalar structure')
end

try
    inst = IX_inst_DGfermi.loadobj (S);
catch
    try
        inst = IX_inst_DGdisk.loadobj (S);
    catch
        inst = S;
    end
end
