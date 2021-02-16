function wout = IX_dataset_1d (w)
% Convert 1D sqw object into IX_dataset_1d
%
%   >> wout = IX_dataset_1d (w)

% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


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
wout=IX_dataset_1d;
if numel(w)>1, wout(numel(w))=wout; end  % allocate array

for i=1:numel(w)
    if isfield(w(i).data_,'axis_caption') && ~isempty(w(i).data_.axis_caption)
        title_fun_calc = w(i).data_.axis_caption;
    else
        title_fun_calc  = an_axis_caption();
    end
    [title_main, title_pax] = title_fun_calc.data_plot_titles(w(i).data_);   % note: axes annotations correctly account for permutation in w.data_.dax
    

    s_axis = IX_axis ('Intensity');
    x_axis = IX_axis (title_pax{1});

    nopix=(w(i).data_.npix==0);
    signal=w(i).data_.s;
    signal(nopix)=NaN;
    err=sqrt(w(i).data_.e);
    err(nopix)=0;

    wout(i) = IX_dataset_1d (title_squeeze(title_main), signal, err, s_axis, w(i).data_.p{1}, x_axis, true);

end

wout=reshape(wout,size(w));

