function w = d1d_to_spectrum (d1d)
% Use fields from a 1D dataset to construct an mgenie spectrum for mathematical
% manipulation, plotting etc.
%
% Use in conjuction with combine_d1d_spectrum to reassemble a 1D dataset after
% using the mgenie spectrum methods.
%
% Syntax:
%   >> w = d1d_to_spectrum (d1d)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

nelmts=prod(size(d1d));
for i=1:nelmts
    x = d1d(i).p1;
    n = d1d(i).n;
    n(find(n==0)) = nan;    % replace infinities with NaN
    y = d1d(i).s./n;
    e = sqrt(d1d(i).e)./n;
    [title, xlab] = dnd_cut_titles (get(d1d(i)));
    ylab = 'Intensity (arb. units)';
    xunit = '';
    distribution = 0;
    if i==1
        w = spectrum (x,y,e,title,xlab,ylab,xunit,distribution);
        if nelmts>1; w(nelmts)=w; end   % pre-initialise array if needed
    else
        w(i)= spectrum (x,y,e,title,xlab,ylab,xunit,distribution);
    end
end
