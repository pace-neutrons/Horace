function det_new=section_par(det,det_array)
% Obtain reduced par data file for a given subsection
%
%   >> data_new=section_par(data,det_array)
%
% Input:
%   det         par data structure (see get_par)
%   det_array   [det1,det2,...detn] is a list of the indexes of the entries in
%              detector arrays that are to be kept. THis is only the same as the 
%              detector group numbers if det.group = 1:ndet
%              (Note: the order is retained regardless if monotonic or not)
% Ouput:
%   det_new    Output par data structure

% T.G.Perring   15/5/07

ndet=length(det.phi);

% Check requested ranges
det_range=[min(det_array),max(det_array)];
if det_range(1)<1||det_range(2)>ndet
    error(['detector range must lie between 1 and ',num2str(ndet)])
end

% Section par file
det_new.filename=det.filename;
det_new.filepath=det.filepath;
det_new.group=det.group(det_array);
det_new.x2=det.x2(det_array);
det_new.phi=det.phi(det_array);
det_new.azim=det.azim(det_array);
det_new.width=det.width(det_array);
det_new.height=det.height(det_array);

