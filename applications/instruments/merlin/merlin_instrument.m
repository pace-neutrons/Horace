function instrument = merlin_instrument(ei,hz,chopper)
% Return instrument description for MERLIN
%
%   >> instrument = merlin_instrument(ei,hz,chopper)
%
% Input:
% ------
%   ei          Incident energy (meV)
%   hz          Chopper frequency
%   chopper     Fermi chopper package name ('S','A','B','G')

% 11/6/15: Monitor2 1504mm before sample; M3 4247mm after sample (accounts
% for being V monitrs)


% Check input arguments are valid
% -------------------------------
chop_name={'sloppy','a','b','g'};   % Make sure all of these choppers are defined below

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

distance=11.837;        % From engineering drawing of Tatiana's, 11/6/15
angle=0.0;              % *** Needs to be set properly
pulse_model='ikcarp';
pp=[70/sqrt(ei),0,0];   
    
moderator=IX_moderator(distance,angle,pulse_model,pp);

% -----------------------------------------------------------------------------
% Aperture
% -----------------------------------------------------------------------------
%   distance        Distance from sample (-ve if upstream, +ve if downstream)
%   width           Width of aperture (m)
%   height          Height of aperture (m)

distance=-10.157;   % Rob Bewley says 1.68m from moderator 10/6/15, which is 11.837 (see above)
width =0.094;       % Rob Bewley 10/6/15
height=0.094;       %   "

fac=sqrt(merlin_flux_gain(ei));   % Compute effective aperture size from flux gain

aperture=IX_aperture(distance,fac*width,fac*height);



% -----------------------------------------------------------------------------
% Fermi chopper
% -----------------------------------------------------------------------------
%   name            Name of the slit package (e.g. 'sloppy')
%   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
%   frequency       Frequency of rotation (Hz)
%   radius          Radius of chopper body (m)
%   curvature       Radius of curvature of slits (m)
%   slit_width      Slit width (m)  (Fermi)

distance=1.8;       % Rob Bewley 10/6/15
radius=0.049;
radius_gd=0.005;    % Rob Bewley 10/6/15: 10mm think package, 0.2mm slits, 0.02mm slats, straight

% Take the chopper parameters for HET S,a,b; Gd parameters from Rob
chopper_array(1)=IX_fermi_chopper('sloppy',distance,hz,radius,1.300,0.00228);
chopper_array(2)=IX_fermi_chopper('a',     distance,hz,radius,1.300,0.00076);
chopper_array(3)=IX_fermi_chopper('b',     distance,hz,radius,0.920,0.00129);
chopper_array(4)=IX_fermi_chopper('g',     distance,hz,radius_gd,99999,0.0002);


% -----------------------------------------------------------------------------
% Build instrument
% -----------------------------------------------------------------------------
instrument.moderator=moderator;
instrument.aperture=aperture;
fermi_chopper=chopper_array(ind);
fermi_chopper.energy=ei;
instrument.fermi_chopper=fermi_chopper;
