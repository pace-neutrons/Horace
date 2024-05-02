function inst = maps_instrument(ei, hz, chopper, varargin)
% Return instrument description for MAPS
%
%   >> inst = maps_instrument(ei, hz, chopper, '-version', inst_ver)
%
%   >> inst = maps_instrument(...,'-moderator', mod_value)
%
% [NOTE: for historical reasons, if you don't give the instrument version
% it will be set to that for the pre-2017 MAPS i.e. no guide]
%
%
% Input:
% ------
%   ei          Incident energy (meV)
%
%   hz          Chopper frequency (Hz)
%
%   chopper     Fermi chopper package name ('S','A', or 'B')
%
%   inst_ver    Instrument version:
%                   inst_ver = 1    MAPS from 2000 to 2017 (no guide)
%                   inst_ver = 2    MAPS from 2017 onwards (i.e. with guide)
%
%               Default: the original instrument configuration i.e. pre-2017
%               This is for historical backwards compatibility reasons.
%               Please ensure you specify explicity the instrument version
%               to ensure you get the same results from using this function
%               even if the instrument is modified in the future.
%
%   mod_value   Origin of moderator width data
%                   mod_value = 'empirical'     [default]
%                       Empirical model: chi-squared t^2 exp(-t/tau) with
%                      tau_microseconds = 70/sqrt(Ei_in_meV). A good
%                      starting value for refinement.
%
%                   mod_value = 'base2016'
%                       Baseline moderator simulation from the ISIS
%                      simulation group for ISIS before the 2020/2021 upgrade
%
% Output:
% -------
%   inst        Instrument description: object of class IX_inst_DGfermi
%               This class is recognised by Tobyfit and other resolution 
%               function utilities


% Parse arguments
% ---------------
default_version = 1;

keyval_def =  struct('version',default_version,'moderator','empirical');  
[par,keyval] = parse_arguments (varargin, keyval_def);
if numel(par)==0
    inst_ver = keyval.version;
    moderator_model = keyval.moderator;
else
    error('HERBERT:instriments:invalid_argument',[ ...
        'Check the number and type of input arguments.\n' ...
        'Unrecognized inputs:\n%s'],disp2str(par))

end


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

if ~(isnumeric(inst_ver) && isscalar(inst_ver) && (inst_ver==1 || inst_ver==2))
    error('Instrument version must be 1 or 2')
end

if ischar(moderator_model)
    if strncmpi(moderator_model,'empirical',numel(moderator_model))
        moderator_model = 'empirical';
    elseif strncmpi(moderator_model,'base2016',numel(moderator_model))
        moderator_model = 'base2016';
    else
        error('Check that the moderator model has one of the valid values')
    end
else
    error('Check that the moderator model has one of the valid values')
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

if strcmpi(moderator_model,'empirical')
    pulse_model='ikcarp';
    pp=[70/sqrt(ei),0,0];
elseif strcmpi(moderator_model,'base2016')
    pulse_model = 'table';
    mod_file = 'TS1verBase2016_LH8020_newVM-var_South01_Maps.mat';
    [t, y] = ISIS_Baseline2016_moderator_time_profile (mod_file, ei);
    pp = {t, y};
else
    error('Check moderator model')
end

moderator=IX_moderator(distance,angle,pulse_model,pp);

% -----------------------------------------------------------------------------
% Aperture
% -----------------------------------------------------------------------------
%   distance        Distance from sample (-ve if upstream, +ve if downstream)
%   width           Width of aperture (m)
%   height          Height of aperture (m)

if inst_ver==1
    distance=-10.01;
    width =0.07013;
    height=0.07013;
    aperture=IX_aperture(distance,width,height);
else
    distance=-(12.0-1.671);
    width =0.094;
    height=0.094;
    fac=sqrt(maps_flux_gain(ei));   % Compute effective aperture size from flux gain
    aperture=IX_aperture(distance,fac*width,fac*height);
end

% -----------------------------------------------------------------------------
% Fermi chopper
% -----------------------------------------------------------------------------
%   name            Name of the slit package (e.g. 'sloppy')
%   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
%   frequency       Frequency of rotation (Hz)
%   radius          Radius of chopper body (m)
%   curvature       Radius of curvature of slits (m)
%   slit_width      Slit width (m)  (Fermi)

if inst_ver==1
    distance=1.9;
else
    distance=1.857;
end
radius=0.049;

chopper_array(1)=IX_fermi_chopper('sloppy',distance,hz,radius,1.300,0.002899);
chopper_array(2)=IX_fermi_chopper('a',     distance,hz,radius,1.300,0.001087);
chopper_array(3)=IX_fermi_chopper('b',     distance,hz,radius,0.920,0.001812);

fermi_chopper=chopper_array(ind);


% -----------------------------------------------------------------------------
% Build instrument
% -----------------------------------------------------------------------------
source = IX_source('ISIS','',50);
inst = IX_inst_DGfermi (moderator, aperture, fermi_chopper, ei,...
    'name', 'MAPS', 'source', source);
