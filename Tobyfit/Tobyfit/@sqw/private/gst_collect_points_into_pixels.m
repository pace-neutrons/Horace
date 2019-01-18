function wout = gst_collect_points_into_pixels(win,iW,iPx,nPt,fst,lst,iPt,SQE,VxR)
% Initialise output arguments
% ---------------------------
wout = win;

nwin = numel(win);
nPx = arrayfun( @(x)(size( x.data.pix, 2)), win);
tPx = sum(nPx);
% Verify inputs:
if numel(iW)~=tPx || numel(iPx)~=tPx || numel(nPt) ~= tPx || numel(fst) ~= tPx || numel(lst) ~= tPx
    error('Pixel index, number of points per pixel, and first point index per pixel must have %d elements',tPx)
end
tPt = numel(iPt);
if nargin<8 || isempty(VxR)
    VxR = ones(1,tPt);
end
if numel(VxR) ~= tPt 
    error('The total number of points and probabilities must match')
end
nSQE = numel(SQE);
if size(SQE,2) ~= nSQE
    if size(SQE,1)==nSQE
        SQE = permute(SQE,[2,1]);
    else
        fprintf('S(Q,E) is expected to be a row vector, but is ')
        fprintf('%d ',size(SQE))
        fprintf('instead. Forcing reshape to row vector.')
        SQE = permute(SQE(:),[2,1]);
    end
end
if max(iPt) > nSQE || min(iPt) < 1
    error('All iPt must be valid indicies into S(Q,E)')
end

firstlast = cat(2,0,cumsum(nPx));
for i=1:nwin
    for j= 1+firstlast(i) : firstlast(i+1)
        if iW(j)~=i
            error('Something has gone horribly wrong') % DEBUG
        end
        % The signal for pixel iPx(j) is the V(R(Q0,E0)) times the integral of S(Q,E)*R(Q-Q0,E-E0)
        s = VxR(fst(j):lst(j)).*SQE(iPt(fst(j):lst(j)));
        % Which we're approximating as the sum over
        % V(R(Q0,E0))*R(Q-Q0,E-E0)*S(Q,E), all divided by the number of
        % points included in the sum.
        wout(i).data.pix(8,iPx(j)) = sum(s)/nPt(j);
        % If we assume the variance of S(Q,E) is Gaussian-like, we can
        % calculate the variance in our estimate to V(R(Q0,E0))*Int[S(Q,E)*R(Q-Q0,E-E0)]
        wout(i).data.pix(9,iPx(j)) = abs(sum(s.^2)-sum(s)^2)/nPt(j)^2;
        % Or we could use the real [variance]/nPt, if we know it. Or just
        % claim there is no error in our integration
        %   wout(i).data.pix(9,iPx(j)) = 0;
    end
    wout(i) = recompute_bin_data(wout(i));
end
