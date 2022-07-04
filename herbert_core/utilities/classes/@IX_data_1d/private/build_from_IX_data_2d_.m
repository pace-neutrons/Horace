function   obj = build_from_IX_data_2d_(obj,w2)
% Convert IX_dataset_2d into array of IX_dataset_1d
%

nw2=numel(w2);
nw1=zeros(nw2,1);
for i=1:nw2
    nw1(i)=size(w2(i).signal,2);
end
ibegw1=[0;cumsum(nw1)];


obj=repmat(obj,sum(nw1),1);
for i=1:nw2
    title=w2(i).title;      % get contents into temporary variables to avoid repeated call to IX_dataset_2d/get
    signal=w2(i).signal;
    error=w2(i).error;
    s_axis=w2(i).s_axis;
    x=w2(i).x; x_axis=w2(i).x_axis; x_distribution=w2(i).x_distribution;
    for j=1:nw1(i)
        %obj(ibegw1(i)+j)=IX_dataset_1d(title, signal(:,j), error(:,j), s_axis, x, x_axis, x_distribution);
        obj(ibegw1(i)+j).title = title;
        obj(ibegw1(i)+j).x_axis = x_axis;
        obj(ibegw1(i)+j).s_axis = s_axis;
        obj(ibegw1(i)+j).x_distribution =x_distribution;
        
        
        obj(ibegw1(i)+j).xyz_{1} = obj.check_xyz(x);
        obj(ibegw1(i)+j) = check_and_set_sig_err_(obj(ibegw1(i)+j),'signal',signal(:,j));
        obj(ibegw1(i)+j) = check_and_set_sig_err_(obj(ibegw1(i)+j),'error',error(:,j));
        
        
        % check and set valid property, verifying all connected fields are
        % consistent
        [ok,mess] = obj(ibegw1(i)+j).check_joint_fields();
        if ok
            obj(ibegw1(i)+j).valid_ = true;
        else % can not ever happen, unless w2 is invalid
            error('IX_data_1d:runtime_error',mess);
        end
    end
end



