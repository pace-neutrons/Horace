function pix_coord  = transform_pix_to_img_(~,pix,varargin)
% Transform instrument signal obtained from instrument into Crystal
% Cartesian coordinate system.
%
% As this is instrument projection, its image is crystal
% Cartesian, so we just extract pixel coordinates.
%
% Some symmetry transformation may be applied here
%
pix_coord = pix.data;
