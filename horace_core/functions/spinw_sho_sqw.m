function weight = spinw_sho_sqw(obj, qh, qk, ql, en, p_in)
% calculates spin wave dispersion/correlation functions to be called from Horace
%
% weight = HORACE_SHO_SQW(obj, qh, qk, ql, en, p)
%
% The function produces spin wave dispersion and intensity for Horace by convoluting
% the spinW output with a simple harmonic oscillator times the Bose function.
% (<a href=http://horace.isis.rl.ac.uk>http://horace.isis.rl.ac.uk</a>).
%
% Input:
%
% obj        Input sw object.
% qh, qk, ql Reciprocal lattice components in reciprocal lattice units.
% en         Energy transfers at which to calculate S(q,w)
% p          Parameters, in the order defined by horace_setpar.
%            In addition, if numel(p)>numel(mapping) where mapping is
%            the cell array defined in horace_setpar, the next 3 values
%            are taken to be:
%              gam  - width of the damped harmonic oscillator.
%              temp - sample temperature in Kelvin for the Bose factor.
%              amp  - amplitude to scale S(q,w) by.
%            Default values are: gamma = 0.1; temp = 0; amp = 1;
%
% Output:
%
% weight     Array of neutron intensity at specified hkl, energy points.
%
% Example:
%
% ...
% horace_on;
% tri = sw_model('triAF',2);
% tri.horace_setpar('mapping',{'J1' 'J2'},'fwhm',0.2);
% d3dobj = d3d(tri.abc,[0 1 0 0],[0,0.01,1],[0 0 1 0],[0,0.01,1],[0 0 0 1],[0,0.1,10]);
% d3dobj = sqw_eval(d3dobj,@cryst.horace_sqw,[1 0.5 1.5 0.5 0.01]);
% plot(d3dobj);
%
% This example creates a d3d object, a square in (h,k,0) plane and in
% energy between 0 and 10 meV. Then calculates the inelastice neutron
% scattering intensity of triagular lattice antiferromagnet and plots it
% using sliceomatic.
%
% See also SW, SW.SPINWAVE, SW.MATPARSER, SW.HORACE_SETPAR, SW_READPARAM.
%

if nargin <= 1
    help spinw_sqw;
    return;
end

% Check input is actually a spinW object, taking care of v3 nameing conventions.
if ~isa(obj,'sw') && ~isa(obj,'spinw')
    error('obj should be a spinW object');
end

nPar = numel(obj.matrix.horace.mapping);
gam = 0.1;
temp = 0;
amp = 1;
if numel(p_in) > nPar
    gam = p_in(nPar+1);
end
if numel(p_in) > (nPar+1)
    temp = p_in(nPar+2);
end
if numel(p_in) > (nPar+2)
    amp = p_in(nPar+3);
end

[e, sf] = spinw_disp(obj,qh,qk,ql,p_in(1:nPar));

if abs(temp)<sqrt(eps) 
    Bose = ones(numel(qh),1);
else
    Bose = en./ (1-exp(-11.602.*en./temp));%Bose factor from Tobyfit. 
end

%Use damped SHO model to give intensity:
weight = zeros(numel(qh),1);
for ii=1:numel(e)
    weight = weight + (4.*gam.*e{ii})./(pi.*((en-e{ii}).^2 + 4.*(gam.*en).^2));
end
weight = amp*reshape(Bose.*weight,size(qh));
