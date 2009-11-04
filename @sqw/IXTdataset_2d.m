function wout = IXTdataset_2d (w)
% Convert 2D sqw object into IXTdataset_2d
%
%   >> wout = IXTdataset_2d (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Check input
if isempty(w)
    error('sqw object is an empty array')
end
for i=1:numel(w)
    if dimensions(w(i))~=2
        if numel(w)==1
            error('sqw object is not two dimensional')
        else
            error('Not all elements in the array of sqw objects are two dimensional')
        end
    end
end

% Fill output
wout=IXTdataset_2d;
if numel(w)>1, wout(numel(w))=wout; end  % allocate array

for i=1:numel(w)
    [title_main, title_pax] = data_plot_titles (w(i).data);    % note: axes annotations correctly account for permutation in w.data.dax

    s_axis = IXTaxis ('Intensity');
    axis_1 = IXTaxis (title_pax{1});
    axis_2 = IXTaxis (title_pax{2});

    nopix=(w(i).data.npix==0);
    signal=w(i).data.s;
    signal(nopix)=NaN;
    err=sqrt(w(i).data.e);
    err(nopix)=0;

    % Check if display axes are reversed
    if all(w(i).data.dax==[2,1])    % axes are permuted for plotting purposes
        wout(i) = IXTdataset_2d (IXTbase, title_squeeze(title_main), signal', err',...
            s_axis, w(i).data.p{2}', axis_1, false, w(i).data.p{1}', axis_2, false);
    else
        wout(i) = IXTdataset_2d (IXTbase, title_squeeze(title_main), signal, err,...
            s_axis, w(i).data.p{1}', axis_1, false, w(i).data.p{2}', axis_2, false);
    end

end

wout=reshape(wout,size(w));
