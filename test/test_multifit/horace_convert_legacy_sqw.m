function wout=test_convert_legacy_sqw(win)
% Convert old sqw object to new sqw object with ionstumnet and sample fields
%
%   >> wout=test_convert_legacy_sqw(win)
%
% If not an sqw object, leave unchanged

wout=win;
for i=1:numel(win)
    if isa(win,'sqw') && is_sqw_type(win(i))
        hnew=win(i).header;
        if ~iscell(hnew)
            hnew.instrument=struct;
            hnew.sample=struct;
        else
            for j=1:numel(hnew)
                hnew{j}.instrument=struct;
                hnew{j}.sample=struct;
            end
        end
        wout(i).header=hnew;
    end
end
