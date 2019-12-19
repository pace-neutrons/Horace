function [xout,yout,inarea_out,outarea_out,sout,eout,nout]=shoelace_rearrangement(xin,yin,...
    inarea,outarea,sin,ein,nin,likely)
%
% Having calculated which bins are likely to overlap, we now
% want to make new input coordinate and signal arrays with the correct values
%

%Initialise the output:
sz=numel(likely);
xout=cell(1,sz);
yout=xout; sout=xout; eout=xout; nout=xout; inarea_out=xout; outarea_out=xout;

for i=1:numel(likely)
    if ~isempty(likely{i})
        xout{i}=xin(:,likely{i});
        yout{i}=yin(:,likely{i});
        sout{i}=sin(likely{i});
        eout{i}=ein(likely{i});
        nout{i}=nin(likely{i});
        inarea_out{i}=inarea(likely{i});
        outarea_out{i}=outarea(i);
    else
        xout{i}=[]; yout{i}=[]; sout{i}=[]; eout{i}=[]; nout{i}=[];
        inarea_out{i}=[]; outarea_out{i}=[];
    end
end