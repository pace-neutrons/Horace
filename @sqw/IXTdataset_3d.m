function wout = IXTdataset_3d (w)
% Convert 3D sqw object into IXTdataset_3d
%
%   >> wout = IXTdataset_3d (w)

% R.A. Ewings, 14/10/08.


% Check input
if isempty(w)
    error('sqw object is an empty array')
end
for i=1:numel(w)
    if dimensions(w(i))~=3
        if numel(w)==1
            error('sqw object is not three dimensional')
        else
            error('Not all elements in the array of sqw objects are three dimensional')
        end
    end
end

% Fill output
wout=IXTdataset_3d;
if numel(w)>1, wout(numel(w))=wout; end  % allocate array

for i=1:numel(w)
    [title_main, title_pax] = data_plot_titles (w(i).data);    % note: axes annotations correctly account for permutation in w.data.dax

    s_axis = IXTaxis ('Intensity');
    axis_1 = IXTaxis (title_pax{1});
    axis_2 = IXTaxis (title_pax{2});
    axis_3 = IXTaxis (title_pax{3});

    nopix=(w(i).data.npix==0);
    signal=w(i).data.s;
    signal(nopix)=NaN;
    err=sqrt(w(i).data.e);
    err(nopix)=0;

    % Check if display axes are permuted
    dax = w(i).data.dax;   % display axes permutation
    p = w(i).data.p(dax);  % permute the projection axes into the display axes
    signal=permute(signal,dax);
    err=permute(err,dax);

    wout(i) = IXTdataset_3d (IXTbase, title_squeeze(title_main), signal, err, s_axis,...
        p{1}', axis_1, false, p{2}', axis_2, false, p{3}', axis_3, false);

end

wout=reshape(wout,size(w));
