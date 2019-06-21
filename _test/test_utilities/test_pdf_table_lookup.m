function test_pdf_table_lookup
% Test pdf_table_lookup works as expected

hc = herbert_config;
log_level = hc.log_level;

%--------------------------------------------------------------------------
% Create some Fermi chopper objects
% ---------------------------------
c1=IX_fermi_chopper(10,150,0.049,1.3,0.003,Inf, 0, 0,50);
c2a=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,100);
c2b=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,120);     % differs in column index >1 from c2a
c3=IX_fermi_chopper(10,350,0.049,1.3,0.003,Inf, 0, 0,300);
c4=IX_fermi_chopper(10,450,0.049,1.3,0.003,Inf, 0, 0,400);
c5=IX_fermi_chopper(10,550,0.049,1.3,0.003,Inf, 0, 0,350);

[y,t] = pulse_shape(c1);  ww1=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c2a); ww2=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c3);  ww3=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c4);  ww4=IX_dataset_1d(t,y);
[y,t] = pulse_shape(c5);  ww5=IX_dataset_1d(t,y);

ww1 = ww1/c1.transmission();    % normalised to unit integral
ww2 = ww2/c2a.transmission();
ww3 = ww3/c3.transmission();
ww4 = ww4/c4.transmission();
ww5 = ww5/c5.transmission();

%--------------------------------------------------------------------------
% Check Fermi chopper sorting
% -------------------------------
% Do this here as the operation of pdf_lookup_table depends on sorting working
% so check this part is bug free

% Check sort
carr1=[c5,c3,c2b,c1,c2a,c4];

[csort1,ix]=sortObj(carr1);
if ~isequal(ix,[4,5,3,2,6,1]) || ~isequal(carr1(ix),csort1)
    error('Fermi chopper sort not working')
end

% Check unique
carr2=[c5,c2b,c3,c5,c2b,c1,c4,c2a,c4];

[csort2,ix,ib]=uniqueObj(carr2,'last');
if ~isequal(ix',[6     8     5     3     9     4]) ||...
        ~isequal(ib',[6     3     4     6     3     1     5     2     5]) ||...
        ~isequal(carr2(ix),csort2) ||...
        ~isequal(carr2,csort2(ib))
    error('Fermi chopper unique not working')
end


% Check unique in reverse
carr2=[c5,c2b,c3,c5,c2b,c1,c4,c2a,c4];

[csort2,ix,ib]=uniqueObj(carr2,'first');
if ~isequal(ix',[6     8     2     3     7     1]) ||...
        ~isequal(ib',[6     3     4     6     3     1     5     2     5]) ||...
        ~isequal(carr2(ix),csort2) ||...
        ~isequal(carr2,csort2(ib))
    error('Fermi chopper unique not working')
end


%--------------------------------------------------------------------------
% Test the lookup table
% ----------------------

arr1 = [c2a,c1,c4,c1,c1,c2a];
arr2 = [...
    c4, c3, c3;...
    c2a,c1, c3];
arr3 = [c3,c1];

lookup = pdf_table_lookup({arr1,arr2,arr3});

%----------
% Test:
%----------
w1_ref = [ww2,ww1,ww4,ww1,ww1,ww2];
w2_ref = [ww4,ww2,ww3,ww1,ww3,ww3];
w3_ref = [ww3,ww1];


%----------
nsamp = 1e7;
ind1 = floor(numel(arr1)*rand(ceil(nsamp/10),10)) + 1;
xsamp1 = rand_ind(lookup,1,ind1);

w1samp(1) = vals2distr(xsamp1(ind1==1),'norm','poisson');
w1samp(2) = vals2distr(xsamp1(ind1==2),'norm','poisson');
w1samp(3) = vals2distr(xsamp1(ind1==3),'norm','poisson');
w1samp(4) = vals2distr(xsamp1(ind1==4),'norm','poisson');
w1samp(5) = vals2distr(xsamp1(ind1==5),'norm','poisson');
w1samp(6) = vals2distr(xsamp1(ind1==6),'norm','poisson');

if log_level>0, disp('-----------------'), end
for i=1:numel(w1samp)
    if log_level>0
        [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w1_ref(i),w1samp(i),3,'rebin','chi');
        if ~ok
            disp([i,chisqr])
            disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
        else
            disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
        end
    end
end

%----------
nsamp = 1e7;
ind2 = floor(numel(arr2)*rand(ceil(nsamp/10),10)) + 1;
xsamp2 = rand_ind(lookup,2,ind2);

w2samp(1) = vals2distr(xsamp2(ind2==1),'norm','poisson');
w2samp(2) = vals2distr(xsamp2(ind2==2),'norm','poisson');
w2samp(3) = vals2distr(xsamp2(ind2==3),'norm','poisson');
w2samp(4) = vals2distr(xsamp2(ind2==4),'norm','poisson');
w2samp(5) = vals2distr(xsamp2(ind2==5),'norm','poisson');
w2samp(6) = vals2distr(xsamp2(ind2==6),'norm','poisson');

if log_level>0, disp('-----------------'), end
for i=1:numel(w2samp)
    if log_level>0
        [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w2_ref(i),w2samp(i),3,'rebin','chi');
        if ~ok
            disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
        else
            disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
        end
    end
end

%----------
nsamp = 1e7;
ind3 = floor(numel(arr3)*rand(ceil(nsamp/10),10)) + 1;
xsamp3 = rand_ind(lookup,3,ind3);

w3samp(1) = vals2distr(xsamp3(ind3==1),'norm','poisson');
w3samp(2) = vals2distr(xsamp3(ind3==2),'norm','poisson');

if log_level>0, disp('-----------------'), end
for i=1:numel(w3samp)
    if log_level>0
        [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w3_ref(i),w3samp(i),3,'rebin','chi');
        if ~ok
            disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
        else
            disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
        end
    end
end
