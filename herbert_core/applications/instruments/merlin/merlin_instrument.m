function inst = merlin_instrument(ei, hz, chopper, varargin)
% Return instrument description for MERLIN
%
%   >> inst = merlin_instrument(ei, hz, chopper, '-version', inst_ver)
%
%   >> inst = merlin_instrument(...,'-moderator', mod_value)
%
% Input:
% ------
%   ei          Incident energy (meV)
%
%   hz          Chopper frequency (Hz)
%
%   chopper     Fermi chopper package name ('S','A','B','G')
%
%   inst_ver    Instrument version:
%                   inst_ver = 1    Original configuration
%
%               Default: the latest version. Please ensure you specify 
%               explicity the instrument version to ensure you get the
%               same results from using this function even if the instrument
%               is modified
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


% 11/6/15: Monitor2 1504mm before sample; M3 4247mm after sample (accounts
% for being V monitors)


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

if ~(isnumeric(inst_ver) && isscalar(inst_ver) && inst_ver==1)
    error('Instrument version must be 1')
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

distance=11.837;        % From engineering drawing of Tatiana's, 11/6/15
angle=0.0;              % *** Needs to be set properly

if strcmpi(moderator_model,'empirical')
    pulse_model='ikcarp';
    pp=[70/sqrt(ei),0,0];
elseif strcmpi(moderator_model,'base2016')
    pulse_model = 'table';
    mod_file = 'TS1verBase2016_LH8020_newVM-var_South04_Merlin.mat';
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

fermi_chopper=chopper_array(ind);

% -----------------------------------------------------------------------------
% Build instrument
% -----------------------------------------------------------------------------
source = IX_source('ISIS','',50);
inst = IX_inst_DGfermi (moderator, aperture, fermi_chopper, ei,...
    'name', 'MERLIN', 'source', source);
