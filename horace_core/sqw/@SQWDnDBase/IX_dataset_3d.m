function wout = IX_dataset_3d (w)
% Convert 3D sqw object into IX_dataset_3d
%
%   >> wout = IX_dataset_3d (w)

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
wout=IX_dataset_3d;
if numel(w)>1, wout(numel(w))=wout; end  % allocate array

for i=1:numel(w)
    if isfield(w(i).data_,'axis_caption') && ~isempty(w(i).data_.axis_caption)
        title_fun_calc = w(i).data_.axis_caption;
    else
        title_fun_calc  = an_axis_caption();
    end
    [title_main, title_pax] = title_fun_calc.data_plot_titles(w(i).data_);   % note: axes annotations correctly account for permutation in w.data_.dax

    %[title_main, title_pax] = data_plot_titles (w(i).data_);    % note: axes annotations correctly account for permutation in w.data_.dax

    s_axis = IX_axis ('Intensity');
    axis_1 = IX_axis (title_pax{1});
    axis_2 = IX_axis (title_pax{2});
    axis_3 = IX_axis (title_pax{3});

    nopix=(w(i).data_.npix==0);
    signal=w(i).data_.s;
    signal(nopix)=NaN;
    err=sqrt(w(i).data_.e);
    err(nopix)=0;

    % Check if display axes are permuted
    dax = w(i).data_.dax;   % display axes permutation
    p = w(i).data_.p(dax);  % permute the projection axes into the display axes
    signal=permute(signal,dax);
    err=permute(err,dax);

    wout(i) = IX_dataset_3d (title_squeeze(title_main), signal, err, s_axis,...
        p{1}, axis_1, true, p{2}, axis_2, true, p{3}, axis_3, true);

end

wout=reshape(wout,size(w));
