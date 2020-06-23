function tube = get_default_detector_from_detpar(detpar)
%GET_DETAULT_TUBE_FROM_DETPAR Create a detector instance from the minimal information in the detpar object.
%
% Return a new He3 tube at 10atms, wall thickness=0.635mm

PRESSURE = 6.35e-4; % atmospheres
THICKNESS = 10; % mm

tube = IX_det_He3tube( ...
    detpar.width, ...
    detpar.height, ...
    PRESSURE, ...
    THICKNESS);
end
