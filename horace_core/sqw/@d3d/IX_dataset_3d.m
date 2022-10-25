function wout = IX_dataset_3d (w)
% Convert 3D sqw object into IX_dataset_3d
%
%   >> wout = IX_dataset_3d (w)

% R.A. Ewings, 14/10/08.


% Check input

% Fill output
wout=IX_dataset_3d;
if numel(w)>1
    wout =repmat(wout,size(w)); 
end  % allocate array

for i=1:numel(w)


    title_fun_calc = w(i).axes.axis_caption;
    [title_main, title_pax] = title_fun_calc.data_plot_titles(w(i));   % note: axes annotations correctly account for permutation in w.data_.dax

    %[title_main, title_pax] = data_plot_titles (w(i).data_);    % note: axes annotations correctly account for permutation in w.data_.dax

    s_axis = IX_axis ('Intensity');
    axis_1 = IX_axis (title_pax{1});
    axis_2 = IX_axis (title_pax{2});
    axis_3 = IX_axis (title_pax{3});

    nopix=(w(i).npix==0);
    signal=w(i).s;
    signal(nopix)=NaN;
    err=sqrt(w(i).e);
    err(nopix)=0;

    % Check if display axes are permuted
    dax = w(i).dax;   % display axes permutation
    p = w(i).p(dax);  % permute the projection axes into the display axes
    signal=permute(signal,dax);
    err=permute(err,dax);

    wout(i) = IX_dataset_3d (title_squeeze(title_main), signal, err, s_axis,...
        p{1}, axis_1, true, p{2}, axis_2, true, p{3}, axis_3, true);

end

wout=reshape(wout,size(w));
