function wout = IXTdataset_1d (w)
% Convert 1D sqw object into IXTdataset_1d
%
%   >> wout = IXTdataset_1d (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

nd=dimensions(w);

if nd~=1
    error('sqw object is not one dimensional')
end

[title_main, title_pax] = data_plot_titles (w.data);

s_axis = IXTaxis ('Intensity');
x_axis = IXTaxis (title_pax{1});

nopix=(w.data.npix==0);
signal=w.data.s';
signal(nopix)=NaN;
err=sqrt(w.data.e)';
err(nopix)=0;

wout = IXTdataset_1d (IXTbase, title_main, signal, err, s_axis, w.data.p{1}', x_axis, false);
