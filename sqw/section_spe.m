function data_new=section_spe(data,det_array,en_range)
% Obtain reduced spe data file consisting of those bins entirely contained within
% given detector number range and energy transfer range
%
%   >> data_new=section_spe(data,det_array)
%   >> data_new=section_spe(data,det_array,en_range)
%
% Input:
%   data        spe data structure (see load_spe)
%   det_array   [det1,det2,...detn] are detector numbers to keep
%              (Note: the order is retained regardless if monotonic or not)
%   en_range    (Optional): [en_lo, en_hi] is energy transfer range to keep
%              Default is to keep full energy range
%
% Output:
%   data_new    Output spe data structure
%
% e.g.
%   >> dnew=section_spe(d,[15:50],[12,15]);

% T.G.Perring   15/5/07

[ne,ndet]=size(data.S);

% Check requested ranges
% Detector range:
det_range=[min(det_array),max(det_array)];
if det_range(1)<1||det_range(2)>ndet
    error(['detector range must lie between 1 and ',num2str(ndet)])
end

% Energy range:
if nargin==3
    if length(en_range)>2
        error('Give minimum and maximum energy transfer only');
    end
    en_range=sort(en_range);    % Get in increasing order
    en_ind=find((data.en>=en_range(1))&(data.en<=en_range(2)));
    if length(en_ind)<2
        error (['No complete energy bins in given range (bins are ',num2str(data.en(1)),':',...
            num2str((data.en(end)-data.en(1))/(length(data.en)-1)),':',num2str(data.en(end)),' meV)']);
    end
else
    en_ind=1:ne+1;
end

% Section spe file
data_new.filename=data.filename;
data_new.filepath=data.filepath;
data_new.S=data.S(en_ind(1:end-1),det_array);
data_new.ERR=data.ERR(en_ind(1:end-1),det_array);
%data_new.en=data.en(en_ind); T.G.P   % I.Bustinduy: <-- Is this OK??? 
data_new.en=data.en(en_ind(1:end-1)); % I.Bustinduy Mon Aug 27 12:39:40 CEST 2007

