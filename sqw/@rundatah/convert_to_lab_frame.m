function [urange,u_to_rlu,pix,obj] = convert_to_lab_frame(obj)
% transform rundatah pixel information into crystal cartezian coordinate system
%
%
% Usage:
%>> [urange,u_to_rlu,pix,obj] = rh.calc_projections()
%                           where rh is fully defined rundata object
% Returns:
%urange --  q-dE range of pixels in crystan cartesian coordinate
%           system
% u_to_rlu -- martix to use when converting crystal cartezian
%             coordinate systen into rlu coodidinate system
% pix      -- [9 x npix] array of sqw pixel's information
%             in crystal cartezian
%             coordinate system (see sqw pixels information on
%             the details of the pixels format)
% obj      -- rundatah object with all data loaded in memory and masked 
%             invalid pixels
%
% Substantially overlaps with calc_sqw method within all
% performance critical aras except fully fledged sqw object is
% not constructed

% Load data which have not been loaded in memory yet (do not
% reload)
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
