c1=IX_fermi_chopper(10,150,0.049,1.3,0.003,Inf, 0, 0,50);
c2a=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,100);
c2b=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,120);
c3=IX_fermi_chopper(10,350,0.049,1.3,0.003,Inf, 0, 0,300);
c4=IX_fermi_chopper(10,450,0.049,1.3,0.003,Inf, 0, 0,400);
c5=IX_fermi_chopper(10,550,0.049,1.3,0.003,Inf, 0, 0,350);

[y,t] = pulse_shape(c1);  ww1=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c2a); ww2=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c3);  ww3=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c4);  ww4=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c5);  ww5=IX_dataset_1d(t,y);

ww1norm = ww1/c1.transmission();
ww2norm = ww2/c2a.transmission();
ww3norm = ww3/c3.transmission();
ww4norm = ww4/c4.transmission();
ww5norm = ww5/c5.transmission();

%--------------------------------------------------------------------------
% Test the lookup table for rand_ind
% -----------------------------------

arr1 = [c2a,c1,c4,c1,c1,c2a];
arr2 = [...
    c4, c3, c3;...
    c2a,c1, c3];
arr3 = [c3,c1];

objlookup2 = object_lookup({arr1,arr2,arr3});

%--------------------------------
% Test general case
%--------------------------------
w1_ref = [ww2norm,ww1norm,ww4norm,ww1norm,ww1norm,ww2norm];
w2_ref = [ww4norm,ww2norm,ww3norm,ww1norm,ww3norm,ww3norm];
w3_ref = [ww3norm,ww1norm];


%----------
nsamp = 1e7;
ind1 = randselection(1:numel(arr1),[ceil(nsamp/10),10]);
xsamp1 = rand_ind(objlookup2,1,ind1);

w1samp(1) = samp2distr(xsamp1(ind1==1));
w1samp(2) = samp2distr(xsamp1(ind1==2));
w1samp(3) = samp2distr(xsamp1(ind1==3));
w1samp(4) = samp2distr(xsamp1(ind1==4));
w1samp(5) = samp2distr(xsamp1(ind1==5));
w1samp(6) = samp2distr(xsamp1(ind1==6));

disp('-----------------')
for i=1:numel(w1samp)
    [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w1_ref(i),w1samp(i),10,'rebin','chi');
    if ~ok
        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
    else
        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
    end
end

%----------
nsamp = 1e7;
ind2 = randselection(1:numel(arr2),[ceil(nsamp/10),10]);
xsamp2 = rand_ind(objlookup2,2,ind2);

w2samp(1) = samp2distr(xsamp2(ind2==1));
w2samp(2) = samp2distr(xsamp2(ind2==2));
w2samp(3) = samp2distr(xsamp2(ind2==3));
w2samp(4) = samp2distr(xsamp2(ind2==4));
w2samp(5) = samp2distr(xsamp2(ind2==5));
w2samp(6) = samp2distr(xsamp2(ind2==6));

disp('-----------------')
for i=1:numel(w2samp)
    [ok,chisqr,wresid] = IX_dataset_1d_same (w2_ref(i),w2samp(i),10);
    if ~ok
        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
    else
        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
    end
end

%----------
nsamp = 1e7;
ind3 = randselection(1:numel(arr3),[ceil(nsamp/10),10]);
xsamp3 = rand_ind(objlookup2,3,ind3);

w3samp(1) = samp2distr(xsamp3(ind3==1));
w3samp(2) = samp2distr(xsamp3(ind3==2));

disp('-----------------')
for i=1:numel(w3samp)
    [ok,chisqr,wresid] = IX_dataset_1d_same (w3_ref(i),w3samp(i),20);
    if ~ok
        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
    else
        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
    end
end

%--------------------------------
% Test sorted index array
%--------------------------------
% rand_ind treats this as a special case to make faster

% This case of selecting 2,4,5 from first object array havppens to be all identical objects
nsamp = 1e7;
ind = randselection([2,4,5],[nsamp,1]);
ind = sort(ind);
ind = reshape(ind,[nsamp/10,10]);
xsamp = rand_ind(objlookup2,1,ind);

wsamp = repmat(IX_dataset_1d,size(w1_ref));
wsamp(2) = samp2distr(xsamp(ind==2));
wsamp(4) = samp2distr(xsamp(ind==4));
wsamp(5) = samp2distr(xsamp(ind==5));

disp('-----------------')
for i=[2,4,5]
    [ok,chisqr,wresid] = IX_dataset_1d_same (w1_ref(i),wsamp(i),10);
    if ~ok
        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
    else
        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
    end
end

% Now a case where just happens to pick out objects that are increasing index in the internal
% stored array
nsamp = 1e7;
ind = randselection([2,3],[nsamp,1]);
ind = sort(ind);
ind = reshape(ind,[nsamp/10,10]);
xsamp = rand_ind(objlookup2,1,ind);

wsamp = repmat(IX_dataset_1d,size(w1_ref));
wsamp(2) = samp2distr(xsamp(ind==2));
wsamp(3) = samp2distr(xsamp(ind==3));

disp('-----------------')
for i=[2,3]
    [ok,chisqr,wresid] = IX_dataset_1d_same (w1_ref(i),wsamp(i),15);
    if ~ok
        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
    else
        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
    end
end


%---------------------------------------------------------------------------
% Test the operation of func_eval
% ----------------------------------

% Complex case
% --------------
arr1 = [c2a,c1,c4,c1,c1,c2a];
arr2 = [...
    c4, c3, c3;...
    c2a,c1, c3];
arr3 = [c3,c1];

objlookup2 = object_lookup({arr1,arr2,arr3});

ind = [6,1,5,6,1,1];

[tlo_ref, thi_ref] = c3.pulse_range;
[tlo_ref(2), thi_ref(2)] = c4.pulse_range;
[tlo_ref(3), thi_ref(3)] = c3.pulse_range;
[tlo_ref(4), thi_ref(4)] = c3.pulse_range;
[tlo_ref(5), thi_ref(5)] = c4.pulse_range;
[tlo_ref(6), thi_ref(6)] = c4.pulse_range;

[tlo, thi] = objlookup2.func_eval(2,ind,@pulse_range);

if ~isequal(tlo_ref(:),tlo) || ~isequal(thi_ref(:),thi)
    error('Algorithmic failure in func_eval')
end


% Non-scalar output arguments
% ----------------------------

yref = [ww3.signal(:),ww4.signal(:),ww3.signal(:),ww3.signal(:),ww4.signal(:),ww4.signal(:)];
yref = reshape(yref,[1,size(yref)]);    % as ww3.signal is 1 x n (sim. others)

y = objlookup2.func_eval(2,ind,@pulse_shape);   % y has size 1 x n x (numel(ind))

if ~isequal(yref,y)
    error('Algorithmic failure for non-scalar output argument')
end



% Test simple case of a single object referred to internally
% -----------------------------------------------------------
ind2 = [6,3,5,6,3,3,3];

[tlo_ref, thi_ref] = c3.pulse_range;
tlo_ref = repmat(tlo_ref,numel(ind2),1);
thi_ref = repmat(thi_ref,numel(ind2),1);

[tlo, thi] = objlookup2.func_eval(2,ind2,@pulse_range);

if ~isequal(tlo_ref(:),tlo) || ~isequal(thi_ref(:),thi)
    error('Algorithmic failure in func_eval for single object')
end


% Non-scalar output arguments
% ----------------------------
