function cdata=one_color(colorspec,sz)
% Create an rgb colour array with specified size for use in plotting function called surface
%
%   >> cdata=one_color(colorspec,size)
%
%   colorspec   Colour specifier:
%               'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'
%               'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'white'
%   
%               or a single rgb triple
%                e.g. [0.5,0.5,1]   (all elements in the range 0 to 1)
%
%   size        Size of output array
%
%   cdata       An array of size [size,3]

col_brev = 'rgbcmykw';
col_full = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'white'};
rgb = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0; 0 0 0; 1 1 1];

if ~(isnumeric(sz) && numel(sz)>=2 && size(sz,1)==1)
    error('Check data array size')
end

if ischar(colorspec) && ~isempty(colorspec) && numel(size(colorspec))==2 && size(colorspec,1)==1
    if size(colorspec,2)==1
        ind=strfind(col_brev,lower(colorspec));
    else
        ind=strncmpi(col_full,colorspec,numel(colorspec));
    end
    if ~isempty(ind)
        cdata=reshape(repmat(rgb(ind,:),prod(sz),1),[sz,3]);
    else
        error('Unrecognised color specification')
    end
elseif isnumeric(colorspec) && numel(colorspec==3) && all(colorspec>=0&colorspec<=1)
    cdata=reshape(repmat(colorspec(:)',prod(sz),1),[sz,3]);
else
    error('Unrecognised form for colour specification')
end
