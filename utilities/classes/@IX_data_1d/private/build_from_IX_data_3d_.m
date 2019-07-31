function w1 = build_from_IX_data_3d_(obj,w3)
% Create an array of IX_dataset_1d object from an array of IX_dataset_3d objects
%
%   >> w1 = IX_dataset_1d (w3)

nw3=numel(w3);
nw1=zeros(nw3,1);
for i=1:nw3
    sz=size(w3(i).signal);
    nw1(i)=sz(2)*sz(3);
end
ibegw1=[0;cumsum(nw1)];

w1=repmat(obj,sum(nw1),1);
for i=1:nw3
    title=w3(i).title;      % get contents into temporary variables to avoid repeated call to IX_dataset_2d/get
    signal=w3(i).signal;
    error=w3(i).error;
    s_axis=w3(i).s_axis;
    x=w3(i).x; x_axis=w3(i).x_axis; x_distribution=w3(i).x_distribution;
    for j=1:nw1(i)
        %w1(ibegw1(i)+j).=IX_dataset_1d(title, signal(:,j), error(:,j), s_axis, x, x_axis, x_distribution);
		ii = ibegw1(i)+j;
        w1(ii).title = title;
        w1(ii).s_axis = s_axis;
        w1(ii).x_axis = x_axis;
        w1(ii).x_distribution = x_distribution;
        
        
        w1(ii).xyz_{1} = obj.check_xyz(x);
        w1(ii) = check_and_set_sig_err_(w1(ii),'signal',signal(:,j));
        w1(ii) = check_and_set_sig_err_(w1(ii),'error',error(:,j));
        
        % check and set valid property, verifying all connected fields are
        % consistent
        [ok,mess] = w1(ii).check_joint_fields();
        if ok
            w1(ii).valid_ = true;
        else % can not ever happen, unless w3 is invalid
            error('IX_data_1d:runtime_error',mess);
        end
        
    end
end
