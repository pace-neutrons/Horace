function wout=set_header_fudge(w,field,val)
% Fudge to get around the object hierarchy in set functions that prevents direct assignment
% of sample or instrument fields to objects
wout=w;
tmp=wout.experiment_info;
if isstruct(tmp)
    if numel(val)~=1, error('Check number of values'), end
    tmp.(field)=val;
else
    if isa(tmp,'Experiment')
        if numel(val)==1
            if strcmp(field,'instrument')
                for i=1:tmp.instruments.n_runs

                    tmp.instruments{i}=val;
                end
            elseif strcmp(field,'sample')
                for i=1:tmp.samples.n_runs
                    tmp.samples{i}=val;
                end
            else
                for i=1:numel(tmp.expdata)
                    tmp.expdata(i).(field)=val;
                end
            end
        elseif numel(val)==numel(tmp.expdata)
            if strcmp(field,'instrument')
                for i=1:tmp.instruments.n_runs
                    tmp.instruments{i}=val(i);
                end
            elseif strcmp(field,'sample')
                for i=1:tmp.samples.n_runs
                    tmp.samples{i}=val(i);
                end
            else
                for i=1:numel(tmp.expdata)
                    tmp.expdata(i).(field)=val(i);
                end
            end
        else
            error('HORACE:set_header_fudge:Check number of values')
        end
    else
        if numel(val)==1
            for i=1:numel(tmp)
                tmp{i}.(field)=val;
            end
        elseif numel(val)==numel(tmp)
            for i=1:numel(tmp)
                tmp{i}.(field)=val(i);
            end
        else
            error('Check number of values')
        end
    end
end
wout = wout.change_header(tmp);
