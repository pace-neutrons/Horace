function [point_integration, ok, mess] = rebin_point_integration_check (nax, option)
% Check point integration option
%
%   nax     Number of axes
%   option  Option: 'integrate' or cell array of 'integrate' or '', length=nax

ok=true; mess='';
if ischar(option) || (iscellstr(option) && numel(option)==1)
    if iscellstr(option), option=option{1}; end
    if isstringmatchi(option,'integrate')
        point_integration=true(1,nax);
    elseif isempty(option) || isstringmatchi(option,'average')
        point_integration=false(1,nax);
    else
        point_integration=false(0,0);
        ok=false; mess='Option must be ''integrate'' or ''average''';
    end
elseif iscellstr(option) && numel(option)==nax
    point_integration=true(1,nax);
    for iax=1:nax
        if isstringmatchi(option{iax},'integrate')
            point_integration(iax)=true;
        elseif isempty(option{iax}) || isstringmatchi(option{iax},'average')
            point_integration(iax)=false;
        else
            point_integration=false(0,0);
            ok=false; mess='Option must be ''integrate'' or ''average''';
        end
    end
else
    point_integration=false(0,0);
    ok=false; mess='Option must be ''integrate'' or ''average'' or a cell array of those options';
end
