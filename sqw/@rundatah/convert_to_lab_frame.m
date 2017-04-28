function [urange,u_to_rlu,pix,obj] = convert_to_lab_frame(obj)
% transform rundatah pixel information into crystal Cartesian coordinate system
%
%
% Usage:
%>> [urange,u_to_rlu,pix,obj] = rh.convert_to_lab_frame()
%                           where rh is fully defined rundata object located
%                           on disk or in memory.
% Returns:
% urange --   q-dE range of pixels in crystal Cartesian coordinate
%             system
% u_to_rlu -- matrix to use when converting crystal Cartesian
%             coordinate system into rlu coordinate system
% pix      -- [9 x npix] array of sqw pixel's information
%             in crystal Cartesian
%             coordinate system (see sqw pixels information on
%             the details of the pixels format)
% obj      -- rundatah object with all data loaded in memory and masked
%             invalid pixels
%
% Converts to crystal Cartesian system but does not bin into image
% like calc_sqw does. Sqw object, naturally, is not constructed.
%
%
% $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)
%

% Load data which have not been loaded in memory yet (does not reload)
obj = obj.load();
% remove masked data and detectors
[obj.S,obj.ERR,obj.det_par]=obj.rm_masked();

if nargout<3
    proj_mode = 0;
else
    proj_mode = 2;
end
%
% Calculate projections
[u_to_rlu,urange,pix] = convert_to_lab_frame_(obj,obj.detdcn_cash,obj.qpsecs_cash,proj_mode);
