function dnd2d = instrument_view_cut(filename,varargin)
%INSTRUMENT_VIEW_CUT cuts input sqw file using special projection which
% provides 2-dimensional views of input sqw file, used for diagnostics of
% validity of this sqw file.
%
% The cut is performed over the whole sqw dataset so usually is slow.
%
% Two resulting images may be produces using this algorithm:
% 1) First (normal) view is Theta-dE vuew where Theta is the
%    angle between beam direction and a detector position in spherical
%    coordinate system with centre at sample and dE is the energy transfer.
%    This image presents background scattering not related with the sample
% 2) Second, validation view is kf-dE view, where x-axis contains energy
%    transfer values and y-axis -- module of energy transfer values. These
%    values are connected by the relation
%    kf = sqrt(dE/dEToKf_transformation_constant),
%    so the correct image should be a line describing this relation.
%    If plot contains full picture in kf-dE coordinates, the relation
%    between pixel indices and information, contained in the Experiment
%    class is violated. Such sqw file and cuts from this sqw file can not
%    be used for Tobyfitting.
%
% The indication that second type plot may be necessary is large fraction
% of the pixels have been discarded while making the first type of plot.
%
% Inputs:
% filename  -- name of the file containing sqw object. Does not work for
%              dnd objects
% theta_bin  -- binning arguments as for cut to use to bin data in theta-direction.
%               normally this shoule start at 0, step close to angular resolution
%               and ends at instrument's angular coverage range.
% en_bin     -- binning range to use along energy transfer direction
%
% Optional:
% '-check_coherence'
%            -- if provided, indicates that second type of the plot, 
%               reresenting kf-dE dependence is requested.
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