function det_struct = build_det_struct(ndet)
% Build empty detector's structure in Horace format
%
%

det_struct = struct('filename','','filepath','',...
    'group',1:ndet,'x2',zeros(1,ndet),...
    'phi',zeros(1,ndet),'azim',zeros(1,ndet),...
    'width',zeros(1,ndet),'height',zeros(1,ndet));

