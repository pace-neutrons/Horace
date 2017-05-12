function  [q1,q2,q3] = get_q_axes(obj)
% return 3 q-axes in the order of dnd object regardless of the integration
% along any of sqw_dnd object dimensions
%

pin=cell(1,4);
pin(obj.pax)=obj.p;   % works even if zero elements


iint = obj.iint;
inf_min = find(iint(1,:)==-Inf);
if ~isempty(inf_min)
    iax = obj.iax(inf_min);
    iint(1,inf_min) = obj.urange(1,iax);
end
inf_max = find(iint(2,:)==Inf);
if ~isempty(inf_max)
    iax = obj.iax(inf_max);
    iint(2,inf_max) = obj.urange(2,iax);
end

pin(obj.iax)=mat2cell(iint,2,ones(1,numel(obj.iax)));

% % Integration limit spefified as inf to use real data limit instead
% inf_min = cellfun(@(x)(x(1) == -Inf),pin);
% if sum(inf_min)>0
%     pin{inf_min}(1) = obj.urange(1,inf_min);
% end
% inf_max = cellfun(@(x)(x(end) == Inf),pin);
% if sum(inf_max)>0
%     pin{inf_max}(end) = obj.urange(2,inf_max);    
% end
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
