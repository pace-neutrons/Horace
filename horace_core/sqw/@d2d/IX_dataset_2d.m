function wout = IX_dataset_2d (w)
% Convert 2D sqw object into IX_dataset_2d
%
%   >> wout = IX_dataset_2d (w)

% Original author: T.G.Perring
%


% Fill output
wout=IX_dataset_2d;
if numel(w)>1
    wout = repmat(wout,size(w));
end  % allocate array

for i=1:numel(w)
    title_fun_calc = w(i).axes.axis_caption;
    [title_main, title_pax] = title_fun_calc.data_plot_titles(w(i));   % note: axes annotations correctly account for permutation in w.data_.dax

    s_axis = IX_axis ('Intensity');
    axis_1 = IX_axis (title_pax{1});
    axis_2 = IX_axis (title_pax{2});

    nopix=(w(i).npix==0);
    signal=w(i).s;
    signal(nopix)=NaN;
    err=sqrt(w(i).e);
    err(nopix)=0;

    % Check if display axes are reversed
    if all(w(i).dax==[2,1])    % axes are permuted for plotting purposes
        wout(i) = IX_dataset_2d (title_squeeze(title_main), signal', err',...
            s_axis, w(i).p{2}, axis_1, true, w(i).p{1}, axis_2, true);
    else
        wout(i) = IX_dataset_2d (title_squeeze(title_main), signal, err,...
            s_axis, w(i).p{1}, axis_1, true, w(i).p{2}, axis_2, true);
    end
end
