function [detpar,obj]  = get_detpar(obj,varargin)
% return detectors container, stored in sqw file 
% Usage:
%>>detpar = obj.get_detpar() % Returns detectors block
%         stored in the file
[obj,detpar] = obj.get_sqw_block('bl__detpar',varargin{:});

