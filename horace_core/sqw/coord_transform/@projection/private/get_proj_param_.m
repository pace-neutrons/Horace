function [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param_(proj,data_in,pax)
% store parameters, describing cut sqw object and important for
% its behaviour wrt subsequent cuts.
%

if ~isempty(proj.projaxes_)
    uoffset = proj.uoffset;
    ulabel = proj.lab;   
    dax = 1:length(pax);   % until we have option to select display axes in place    
else
    uoffset = data_in.uoffset;
    ulabel = data_in.ulabel;    
    dax = zeros(1,length(pax));
    plotaxis = data_in.pax(data_in.dax);   % plot axes in the input data set in order x-axis, y-axis, ...
    j=1;
    for i=1:length(plotaxis)
        idax = find(plotaxis(i)==pax);
        if ~isempty(idax)   % must be in the list if a plot axis
            dax(j)=idax;
            j=j+1;
        end
    end
   
end
[~,~,~,~,~,u_to_rlu,ulen] = proj.get_pix_transf_();
u_to_rlu = [[u_to_rlu,[0;0;0]];[0,0,0,1]];
ulen = [ulen,1];
