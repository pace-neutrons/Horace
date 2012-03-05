function w=tofspectrum(varargin)
% Constructor for tofspectrum object for holding time-of-flight neutron data
%
%   >> w = tofspectrum
%   >> w = tofspectrum (spec, par, units)
%
% Input:
% ------
%   spec    Spectrum of counts for a single detector (IX_dataset_2d object)
%          or set of detectors (array of IX_dataset_2d objects, one per detector)
%
%   par     Time-of-flight parmeters (tofpar object)
%          If scalar, then applies to all detectors; if array, then one per detector
%           
%   units   Units along x-axis e.g. 'lam'
%          Valid units (depending on the energy mode) are:
%               t       time-of-flight
%               d       d-spacing (elastic only)
%               v       neutron velocity
%               tau     inverse neutron velocity
%               lam     wavelength
%               k       wavevector
%               e       neutron energy
%               w       energy transfer (meV)   (inelastic only)
%               wn      energy transfer (cm^-1) (inelastic only)
%               thz     energy transfer (THz)   (inelastic only)
%               q       momentum transfer
%               sq      square of momentum transfer
%
% Output:
% -------
%   w       Time-of-flight spectrum or array of such spectra
%          Fields are w.units, w.IX_dataset_2d, w.tofpar

% Original author: T.G.Perring

superiorto('IX_dataset_2d')

% Default class
if (nargin == 0)    % fill an empty object
    w.units='t';
    w.IX_dataset_2d=IX_dataset_2d([0,1],0,0,0,'','','','',true,false);    % histogram on x-axis, point on y axis
    w.tofpar=tofpar;
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(struct('units',w.units),'tofspectrum',w.IX_dataset_2d,w.tofpar); return, else error(mess); end
end

% Various input options
if nargin==1 && isa(varargin{1},'tofspectrum')   % if already tofspectrum object, return
    w=varargin{1};

elseif nargin==3
    w.units=varargin{3};
    w.IX_dataset_2d=varargin{1};
    w.tofpar=varargin{2};
    [ok,mess,w]=checkfields(w,true);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok
        if numel(w.IX_dataset_2d)==1
            w=class(struct('units',w.units),'tofspectrum',w.IX_dataset_2d,w.tofpar);
        else
            w=class(w.units,'tofspectrum',w.IX_dataset_2d,w.tofpar);
        end
        return
    else
        error(mess)
    end
    
else
    error('Check number of arguments')
end
