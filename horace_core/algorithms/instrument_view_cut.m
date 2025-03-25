function dnd2d = instrument_view_cut(filename,varargin)
%INSTRUMENT_VIEW_CUT cuts input sqw file using special projection which
% provides 2-dimensional Theta-dE view of input sqw file where Theta is the
% angle between beam direction and a detector position in spherical coordinate
% system with centre at sample and dE is the energy transfer.
%
% Inputs:
% filename  -- name of the file containing sqw object. Does not work for
%              dnd objects
% theta_bin  -- binning arguments as for cut to use to bin data in theta-direction. 
%               normally this shoule start at 0, step close to angular resolution 
%               and ends at instrument's angular coverage range.
% en_bin     -- binning range to use along energy transfer direction
%
% Returns:
% dnd2d     -- d2d object, containing 2-dimensional instrument view of
%              input sqw file

if ~istext(filename)
    error('HORACE:instrument_view:invalid_argument',[ ...
        'Input for instrument_view has to be a text describing path to an existing sqw file.\n' ...
        'Actual class of input data is %s'],class(filename));
end

ldr = sqw_formats_factory.instance().get_loader(filename);
if ~ldr.sqw_type
    error('HORACE:instrument_view:invalid_argument', ...    
        'Instument_veiw input has to be an sqw file but input file %s does not contain sqw object', ...
        filename);
end
in = sqw(ldr);
dnd2d = in.instrument_view_cut(varargin{:});