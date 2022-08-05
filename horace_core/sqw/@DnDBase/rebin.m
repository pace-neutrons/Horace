function obj = rebin(obj,varargin)
% Rebin the current object according to inputs or input object with higher
% dimensionality onto the current object
%
% Usage:
% >>obj = obj.rebin(other_obj);
% >>obj = obj.rebin(other_obj,'-keep_contents');
% >>obj = obj.rebin(bin_range1,bin_range2,bin_range3,bin_range4)
% Where:
% obj       -- current object with some dimensionality
% other_obj -- other object with the same or bigger dimensionality.
%              The binning of this object have to be commensurate with the
%              binning of the current object
% bin_range1,2,3.... the pairs or triplets of numbers in the form
%             [bin_min,step,bin_max] or [bin_min,bin_max] on which current
%             object have to be rebinned.
% Output:
% If other object is provided as input, the object of the current size and
% shape with the signal, error and npix values rebinned and collected from
% current object.
% If "-keep_contents" key is provided as input, and original object is not
% empty, contents of another object is added to the contents of the current
% object
% If binning parameters are provided, current object is rebinned on the
% object with dimensionality, defined by binning parameters.

[ok,mess,keep_contents,argi] = parse_char_options(varargin,{'-keep_contents'});
if ~ok
    error(['HORACE:',class(obj),':invalid_argument'],mess);
end
if isempty(argi)
    error(['HORACE:',class(obj),':invalid_argument'], ...
        'This method need binning parameters or other dnd object as input');
else
    if ~isa(varargin{1},'DnDBase')
        error(['HORACE:',class(obj),':not_implemented'], ...
            'The rebinning of class %s has not yet been implemented', ...
            class(obj))
    end
end
if obj.dimensions()~=0
    error(['HORACE:',class(obj),':not_implemented'], ...
        'The rebinning to the class %s has not yet been implemented', ...
        class(obj))
end
obj = rebin_to_0dim_obj_(obj,varargin{1},keep_contents);