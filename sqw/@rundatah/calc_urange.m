function [urange,obj]=calc_urange(obj,varargin)
% Method calculates q-dE range, this rundata object has in laboratory frame
% (e.g. Crystal Cartesian coordinate system)
%
%Usage:
%>>urange=obj.calc_urange()  Calculate urange for fully defined
%                                      rundatah object
%>>urange=obj.calc_urange('-cash_detectors')
%                           Calculate urange for fully defined
%                           rundatah object, using pre-calculated
%                           vectors, pointing detectors positions. If these
%                           vectors are not provided, the detectors
%                           positions are pre-calculated for subsequent
%                           usage.
%
%>>urange=obj.calc_urange(emin,emax) Calculate urange of the
%                  rundata object within the energy range provided.
%                  the object may be not fully defined (only detectors and
%                  (currently -- not mandatory) lattice should exist.
%                  if object is defined, energy range is calculated from
%                  min(emin,obj.en) to max(emax,obj.en)
%
%>>[urange,obj]=obj.calc_urange(emin,emax,'-cash_detectors')
%                       the combination of the previous two options
%
% if obj present in output parameters, loaded detectors are returned in the
% object together with precalculated detectors values in detdcn_cash
% property if '-cash_detectors' option is enabled
%
%
% $Revision$ ($Date$)
%
keys_recognized = {'-cash_detectors'};
[ok,mess,cash_detectors,params] = parse_char_options(varargin,keys_recognized);
if ~ok
    error('RUNDATAH:invalid_arguments','calc_urange: %s',mess)
end

b_obj = obj.build_bounding_obj(params{:});
det = b_obj.get_par();
if nargout > 1
    obj.det_par = det;
end
% request to return all angular units as radians
%
%---------------------------------------------------------------------------
%

if cash_detectors
    detdcn = calc_or_restore_detdcn_(det);
    if nargout > 2
        obj.detdcn_cash = detdchn;
    end
else
    detdcn = [];
end
if isempty(obj.transform_sqw) % minor optimization not worth deploying ?
    urange = convert_to_lab_frame_(b_obj,detdcn,[],0);
else
    [~,~,urange] = b_obj.calc_sqw(2,[],varargin{:});
end
