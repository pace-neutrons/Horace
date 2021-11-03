function  [q1,q2,q3] = get_q_axes(obj)
% return 3 q-axes in the order of dnd object regardless of the integration
% along any of sqw_dnd object dimensions
%
%TODO: Probably should be removed

pin=cell(1,4);
pin(obj.pax)=obj.p;   % works even if zero elements


iint = obj.iint;
inf_min = find(iint(1,:)==-Inf);
if ~isempty(inf_min)
    error('HORACE:axes_block:runtime_error',...
        ['Transition to new classes logic: Object integration ranges can not be infinite\n',...
        'found range(s): %s equal to -Inf'],fevalc('disp(inf_min)'))    
    %iax = obj.iax(inf_min);
    %iint(1,inf_min) = obj.img_db_range(1,iax);
end
inf_max = find(iint(2,:)==Inf);
if ~isempty(inf_max)
    error('HORACE:axes_block:runtime_error',...
        ['Transition to new classes logic: Object integration ranges can not be infinite\n',...
        'found range(s): %s equal to +Inf'],fevalc('disp(inf_max)'))
    %iax = obj.iax(inf_max);
    %iint(2,inf_max) = obj.img_db_range(2,iax);
end

pin(obj.iax)=mat2cell(iint,2,ones(1,numel(obj.iax)));

q1 = pin{1};
q2 = pin{2};
q3 = pin{3};
% 
    % is empty, then the order is as the axes displayed in a plot
%    ptmp=pbin;          % input refers to display axes
%    pbin=cell(1,4);     % Will reorder and insert integration ranges as required from input data
   % Get binning array from input display axes rebinning
%   for i=1:numel(data.pax)
%        j=data.dax(i);   % plot axis corresponding to ith binning argument
%        pbin(data.pax(j))=ptmp(i);
%    end
