function wout = IX_dataset_1d (w)
% Convert 1D sqw object into IX_dataset_1d
%
%   >> wout = IX_dataset_1d (w)

% Original author: T.G.Perring
%
% Fill output
wout=IX_dataset_1d;
if numel(w)>1
    wout=repmat(wout,size(w));
end  % allocate array

for i=1:numel(wout)
    title_fun_calc = w(i).axes.axis_caption;
    
    [title_main, title_pax] = title_fun_calc.data_plot_titles(w(i));   % note: axes annotations correctly account for permutation in w.data_.dax
    

    s_axis = IX_axis ('Intensity');
    x_axis = IX_axis (title_pax{1});

    nopix=(w(i).npix==0);
    signal=w(i).s;
    signal(nopix)=NaN;
    err=sqrt(w(i).e);
    err(nopix)=0;

    wout(i) = IX_dataset_1d (title_squeeze(title_main), signal, err, s_axis, w(i).p{1}, x_axis, true);
end


