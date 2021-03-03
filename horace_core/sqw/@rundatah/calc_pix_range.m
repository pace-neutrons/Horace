function [pix_range,u_to_rlu]=calc_pix_range(obj,varargin)
% Method calculates q-dE range, this rundata object has
%
%Usage:
%>>[pix_range,u_to_rlu]=obj.calc_pix_range()  Calculate crystal cartesian range
%                                      for fully defined rundatah object
%
%>>[pix_range,u_to_rlu]=obj.calc_pix_range(emin,emax) Calculate range of the
%                  rundata object within the energy range provided.
%                  the object may be not fully defined (only detectors and
%                  (currently -- not mandatory) lattice should exist.
%                  if object is defined, energy range is calculated from
%                  min(emin,obj.en) to max(emax,obj.en)
%
%>>[pix_range,u_to_rlu,detdcn]=obj.calc_pix_range(...,'-cache_detectors')
%                  Calculate pix_range for fully defined rundatah object,
%                  using precacluated vectors, pointing to the detectors
%                  positons
%>>[pix_range,u_to_rlu,detdcn]=obj.calc_pix_range(...,'-ignore_transformation')
%                  if transformation is defined on the rundata, calculate
%                  range without it
%
%
keys_recognized = {'-cache_detectors','-ignore_transformation'};
[ok,mess,cache_detectors,ignore_transf,params] = parse_char_options(varargin,keys_recognized);
if ~ok
    error('RUNDATAH:invalid_arguments','calc_pix_range: %s',mess)
end

b_obj = obj.build_bounding_obj(params{:});
det = b_obj.get_par();
% request to return all angular units as radians
%
%---------------------------------------------------------------------------
%

if cache_detectors
    detdcn = calc_or_restore_detdcn_(det);
else
    detdcn = [];
end
if isempty(obj.transform_sqw) || ignore_transf %
    [u_to_rlu, pix_range] = b_obj.calc_projections_(detdcn,[],0);
else
    [b_obj,~,pix_range] = b_obj.calc_sqw(3,[],varargin{:});
    u_to_rlu = b_obj.data.u_to_rlu;
end
