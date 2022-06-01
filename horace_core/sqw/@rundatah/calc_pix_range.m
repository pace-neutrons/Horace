function [pix_range,obj]=calc_pix_range(obj,varargin)
% Method calculates q-dE range, this rundata object has
%
%Usage:
%>>[pix_range]=obj.calc_pix_range()  Calculate crystal Cartesian range
%                                      for fully defined rundatah object
%
% >>[pix_range]=obj.calc_pix_range(emin,emax) Calculate range of the
%                  rundata object within the energy range provided.
%                  the object may be not fully defined (only detectors and
%                  (currently -- not mandatory) lattice should exist.
%                  if object is defined, energy range is calculated from
%                  min(emin,obj.en) to max(emax,obj.en)
%

%>>[pix_range,obj]=obj.calc_pix_range(...,'-ignore_transformation')
%                  if transformation is defined on the rundata, calculate
%                  range without it
%
%
keys_recognized = {'-ignore_transformation'};
[ok,mess,ignore_transf,params] = parse_char_options(varargin,keys_recognized);
if ~ok
    error('HORACE:rundatah:invalid_arguments','calc_pix_range: %s',mess)
end

[b_obj,obj] = obj.build_bounding_obj(params{:});

if isempty(obj.transform_sqw) || ignore_transf %
    proj = obj.get_projection();
    [pix_range,det0] = proj.convert_rundata_to_pix(b_obj);
    obj.det_par = det0;
else
    [~,~,pix_range] = b_obj.calc_sqw(3,[],varargin{:});
end

