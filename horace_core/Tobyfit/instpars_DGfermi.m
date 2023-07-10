function [ei,x0,xa,x1,thetam,angvel,moderator,aperture,chopper]=...
    instpars_DGfermi(header)
% Get parameters needed for chopper spectrometer resolution function calculation
%
%   >> [ei,x0,xa,x1,thetam,angvel,moderator,aperture,chopper]=...
%                                                   instpars_DGfermi(header)
%
% Input:
% ------
%   header      Header field from sqw object
%
% Output: (arrays are column vectors with length equal to the number of contributing runs)
% -------
%   ei          Incident energies (mev)     [Column vector]
%   x0          Moderator - chopper distance (m)    [Column vector]
%   xa          Beam defining aperture - chopper distance (m)       [Column vector]
%   x1          Chopper - sample distance (m)       [Column vector]
%   thetam      Angle of moderator normal to incident beam (rad)    [Column vector]
%   angvel      Chopper angular velocity (rad/s)    [Column vector]
%   moderator   Array of moderator objects  [Column vector]
%   aperture    Array of aperture objects   [Column vector]
%   chopper     Array of chopper objects    [Column vector]
%
% The moderator and chopper objects contain thetam and angvel respectively, but they
% are extracted here for later convenience.
%
% The energy in the chopper objects is set to the corresponding value in the input header.
% This will avoid any possible inconsistency later on.


% Get array of instruments
instruments = header.instruments;
nrun=instruments.n_runs;

ei=zeros(nrun,1);
x0=zeros(nrun,1);
xa=zeros(nrun,1);
x1=zeros(nrun,1);
thetam=zeros(nrun,1);
angvel=zeros(nrun,1);
for i=1:nrun
    ei(i)=header.expdata(i).efix;
end

use_unique_objects = true;
% switch between old and new inputs to object lookup
% the old version will be removed after testing
if ~use_unique_objects

	inst=repmat({instruments{1}},[nrun,1]);
	for i=2:nrun
	    inst{i}=instruments{i};
	end
	
	% Fill output arguments
	moderator=repmat(IX_moderator,[nrun,1]);
	aperture=repmat(IX_aperture,[nrun,1]);
	chopper=repmat(IX_fermi_chopper,[nrun,1]);
	for i=1:nrun
	    x1(i)=abs(inst{i}.fermi_chopper.distance);
	    x0(i)=abs(inst{i}.moderator.distance) - x1(i);      % distance from Fermi chopper to moderator face
	    xa(i)=abs(inst{i}.aperture.distance) - x1(i);       % distance from Fermi chopper to beam defining aperture
	    thetam(i)=inst{i}.moderator.angle*(pi/180);         % angle of moderator face to inc. beam (radians)
	    angvel(i)=inst{i}.fermi_chopper.frequency*(2*pi);   % angular velocity of Fermi chopper
	    moderator(i)=inst{i}.moderator;
	    aperture(i)=inst{i}.aperture;
	    chopper(i)=inst{i}.fermi_chopper;
	    chopper(i).energy=ei(i);                            % Update incident energy to value in header
	end
	
else
	
	moderator=instruments.get_unique_field('moderator');
	aperture=instruments.get_unique_field('aperture');
	chopper=instruments.get_unique_field('fermi_chopper');
	
	for i=1:nrun
	    x1(i)=abs(chopper{i}.distance);
	    x0(i)=abs(moderator{i}.distance) - x1(i);      % distance from Fermi chopper to moderator face
	    xa(i)=abs(aperture{i}.distance) - x1(i);       % distance from Fermi chopper to beam defining aperture
	    thetam(i)=moderator{i}.angle*(pi/180);         % angle of moderator face to inc. beam (radians)
	    angvel(i)=chopper{i}.frequency*(2*pi);   % angular velocity of Fermi chopper
	    chopper(i).energy=ei(i);                            % Update incident energy to value in header    
	end

end

end
