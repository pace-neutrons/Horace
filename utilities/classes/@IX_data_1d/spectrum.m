function s = spectrum(w)
% Convert array of IX_dataset_1d object to array of mgenie spectra
%
%   >> s = spectrum(w)

if numel(w)==1
    s=spectrum(w.x,w.signal,w.error,w.title,w.x_axis.caption,w.s_axis.caption,w.x_axis.units,double(w.x_distribution));
else
    s=repmat(spectrum,size(w));
    for i=1:numel(w)
        s=spectrum(w.x,w.signal,w.error,w.title,w.x_axis.caption,w.s_axis.caption,w.x_axis.units,double(w.x_distribution));
    end
end
