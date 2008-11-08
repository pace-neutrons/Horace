function wout = IXTdataset_2d (w)
% Convert 2D sqw object into IXTdataset_2d
%
%   >> wout = IXTdataset_2d (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

nd=dimensions(w);

if nd~=2
    error('sqw object is not two dimensional')
end

[title_main, title_pax] = data_plot_titles (w.data);    % note: axes annotations correctly account for permutation in w.data.dax

s_axis = IXTaxis (title_main);
axis_1 = IXTaxis (title_pax{1});
axis_2 = IXTaxis (title_pax{2});

nopix=(w.data.npix==0);
signal=w.data.s;
signal(nopix)=NaN;
err=sqrt(w.data.e);
err(nopix)=0;

% Check if display axes are reversed
if all(w.data.dax==[2,1])    % axes are permuted for plotting purposes
    wout = IXTdataset_2d (IXTbase, title_main, signal', err',...
        s_axis, w.data.p{2}', axis_1, false, w.data.p{1}', axis_2, false);
else
    wout = IXTdataset_2d (IXTbase, title_main, signal, err,...
        s_axis, w.data.p{1}', axis_1, false, w.data.p{2}', axis_2, false);
end
