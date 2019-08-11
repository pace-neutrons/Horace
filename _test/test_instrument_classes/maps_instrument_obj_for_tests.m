function instrument = maps_instrument_obj_for_tests(ei,hz,chopper)
% Return instrument description for MAPS
%
%   >> instrument = maps_instrument_obj_for_tests(ei,hz,chopper)
%
% Input:
% ------
%   ei          Incident energy (meV)
%   hz          Chopper frequency
%   chopper     Fermi chopper package name ('S','A', or 'B')


% Check input arguments are valid
% -------------------------------
chop_name={'sloppy','a','b'};   % Make sure all of these choppers are defined below

if ~(isnumeric(ei) && isscalar(ei) && ei>0)
    error('Incident energy must be greater than zero (and scalar)')
end

if ~(isnumeric(hz) && isscalar(hz) && hz>0)
    error('Chopper frequency must be greater than zero (and scalar)')
end

if is_string(chopper) && ~isempty(chopper)
    ind=find(strncmpi(chopper,chop_name,numel(chopper)));
    if ~isscalar(ind)
        error('Unrecognised chopper type')
    end
else
    error('Check chopper argument is a character string')
end


% -----------------------------------------------------------------------------
% Moderator
% -----------------------------------------------------------------------------
%   distance        Distance from sample (m) (+ve, against the usual convention)
%   angle           Angle of normal to incident beam (deg)
%                  (positive if normal is anticlockwise from incident beam)
%   pulse_model     Model for pulse shape (e.g. 'ikcarp')
%   pp              Parameters for the pulse shape model (array; length depends on pulse_model)

distance=12.0;
angle=32.0;
pulse_model='ikcarp';
pp=[70/sqrt(ei),0,0];

moderator=IX_moderator(distance,angle,pulse_model,pp);

% -----------------------------------------------------------------------------
% Aperture
% -----------------------------------------------------------------------------
%   distance        Distance from sample (-ve if upstream, +ve if downstream)
%   width           Width of aperture (m)
%   height          Height of aperture (m)

distance=-10.01;
width =0.07013;
height=0.07013;

aperture=IX_aperture(distance,width,height);

% -----------------------------------------------------------------------------
% Fermi chopper
% -----------------------------------------------------------------------------
%   name            Name of the slit package (e.g. 'sloppy')
%   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
%   frequency       Frequency of rotation (Hz)
%   radius          Radius of chopper body (m)
%   curvature       Radius of curvature of slits (m)
%   slit_width      Slit width (m)  (Fermi)

distance=1.9;
radius=0.049;

chopper_array(1)=IX_fermi_chopper('sloppy',distance,hz,radius,1.300,0.002899);
chopper_array(2)=IX_fermi_chopper('a',     distance,hz,radius,1.300,0.001087);
chopper_array(3)=IX_fermi_chopper('b',     distance,hz,radius,0.920,0.001812);

fermi_chopper=chopper_array(ind);

% -----------------------------------------------------------------------------
% Build instrument
% -----------------------------------------------------------------------------
instrument = IX_inst_DGfermi (moderator, aperture, fermi_chopper, ei, 'MAPS');
