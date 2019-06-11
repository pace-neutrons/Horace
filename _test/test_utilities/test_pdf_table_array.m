function test_pdf_table_array
% Test pdf_table_array

% Create individual pdfs
% ----------------------
% Gaussian
% ----------
x_gauss_bin = -5:0.05:7;
x_gauss = x_gauss_bin(1:end-1) + 0.025;
y_gauss = gauss(x_gauss,[10,1,1.5]);
w_gauss = IX_dataset_1d(x_gauss,y_gauss);
area = integrate(w_gauss);
w_gauss = w_gauss/area.val;
pdf_gauss = pdf_table(x_gauss,@gauss,[10,1,1.5]);

% Hat
% ----
% (will construct a plot of the distribution later)
x_hat = [-2,3]; % just two points - pushes to the limit
y_hat = [1,1];
pdf_hat = pdf_table(x_hat,y_hat);
% (now carefully construct a set of bin boundaries that can be used in the
% random sampling to compare)
x_hat_bin = -3:0.05:4;
y_hat_bin = zeros(size(x_hat_bin));
y_hat_bin(x_hat_bin>=-2 & x_hat_bin<2.99999) = 1;
w_hat = IX_dataset_1d(x_hat_bin,y_hat_bin(1:end-1));
val = integrate(w_hat);
w_hat = w_hat/(val.val);

% Triangle
% ---------
x_tri_bin = -6:0.05:9;
x_tri = x_tri_bin(1:end-1) + 0.025;
y_tri = conv_hh(x_tri,3,3);
w_tri = IX_dataset_1d(x_tri,y_tri);
pdf_tri = pdf_table(x_tri,@conv_hh,3,3);

% hat*hat
% -------
x_hh_bin = -4:0.05:8;
x_hh = x_hh_bin(1:end-1) + 0.025;
y_hh = conv_hh(x_hh,2,4);
w_hh = IX_dataset_1d(x_hh,y_hh);
pdf_hh = pdf_table(x_hh,@conv_hh,2,4);


% Create random samples from all of the distributions
% ---------------------------------------------------
pdf_arr = [pdf_gauss,pdf_hat;pdf_tri,pdf_hh]';
pdf = pdf_table_array(pdf_arr);

% Have an index of multiple mixed pdfs:
nsamp = 1e7;
ind = floor(numel(pdf_arr)*rand(ceil(nsamp/10),10)) + 1;
xsamp = rand_ind(pdf,ind);

wdist_gauss = samp2distr(xsamp(ind==1),x_gauss_bin);
wdist_hat = samp2distr(xsamp(ind==2),x_hat_bin);
wdist_tri = samp2distr(xsamp(ind==3),x_tri_bin);
wdist_hh = samp2distr(xsamp(ind==4),x_hh_bin);

% Compare random sampling from pdf_table_array
% --------------------------------------------
% For the comparison with a hat function, we need to handle the
% discontinuity carefully. Choose x positions that match the distribution
% constructed from the random sampling above


[ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w_gauss,wdist_gauss,4,'rebin','chi');
if ~ok
    error('Gaussian sampling failed')
end
[ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w_hat,wdist_hat,4,'rebin','chi');
if ~ok
    error('Hat sampling failed')
end
[ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wdist_tri,w_tri,4,'rebin','chi');
if ~ok
    error('Triangle sampling failed')
end
[ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wdist_hh,w_hh,4,'rebin','chi');
if ~ok
    error('Trapezoid sampling failed')
end




% Special case of a single table
% ------------------------------
% Checks a limiting case

pdf_single = pdf_table_array(pdf_hh);
xsamp = rand_ind(pdf_single, ones(1,nsamp));
w_single = samp2distr(xsamp,x_hh_bin);

[ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w_single,w_hh,10,'rebin','chi');
if ~ok
    error('Single trapezoid sampling failed')
end


