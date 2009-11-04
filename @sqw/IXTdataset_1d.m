function wout = IXTdataset_1d (w)
% Convert 1D sqw object into IXTdataset_1d
%
%   >> wout = IXTdataset_1d (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Check input
if isempty(w)
    error('sqw object is an empty array')
end
for i=1:numel(w)
    if dimensions(w(i))~=1
        if numel(w)==1
            error('sqw object is not one dimensional')
        else
            error('Not all elements in the array of sqw objects are one dimensional')
        end
    end
end

% Fill output
wout=IXTdataset_1d;
if numel(w)>1, wout(numel(w))=wout; end  % allocate array

for i=1:numel(w)
    [title_main, title_pax] = data_plot_titles (w(i).data);    % note: axes annotations correctly account for permutation in w.data.dax

    s_axis = IXTaxis ('Intensity');
    x_axis = IXTaxis (title_pax{1});

    nopix=(w(i).data.npix==0);
    signal=w(i).data.s;
    signal(nopix)=NaN;
    err=sqrt(w(i).data.e);
    err(nopix)=0;

    wout(i) = IXTdataset_1d (IXTbase, title_squeeze(title_main), signal', err', s_axis, w(i).data.p{1}', x_axis, false);

end

wout=reshape(wout,size(w));
