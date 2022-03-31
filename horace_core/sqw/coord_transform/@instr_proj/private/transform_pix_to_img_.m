function pix_coord  = transform_pix_to_img_(~,pix,varargin)
% Transform instrument signal obtained from instrument into Crystal
% Cartesian coordinate system.
%
% As this is instrument projection, its image is crystal
% Cartesian, so we just extract pixel coordinates.
%
pix_coord = pix.data;
%
% Some symmetry transformation over pixels will be efficient to apply here.
% TODO: there are currently no interface for such transformation.
%

