% test pdf_table_array

% Create individual pdfs
% ----------------------
% gaussian
x_gauss = -5:0.1:7;
y_gauss = gauss(x_gauss,[10,1,1.5]);
w_gauss = IX_dataset_1d(x_gauss,y_gauss);
area = integrate(w_gauss);
w_gauss = w_gauss/area.val;
pdf_gauss = pdf_table(x_gauss,@gauss,[10,1,1.5]);

% hat
x_hat = [-2,3]; % just two points - pushes to the limit
y_hat = [1,1];
w_hat = IX_dataset_1d(x_hat,y_hat)/5;
pdf_hat = pdf_table(x_hat,y_hat);

% triangle
x_tri = -6:0.05:9;
y_tri = conv_hh(x_tri,3,3);
w_tri = IX_dataset_1d(x_tri,y_tri);
pdf_tri = pdf_table(x_tri,@conv_hh,3,3);

% hat*hat
x_hh = -4:0.05:8;
y_hh = conv_hh(x_hh,2,4);
w_hh = IX_dataset_1d(x_hh,y_hh);
pdf_hh = pdf_table(x_hh,@conv_hh,2,4);

%xsamp = rand(pdf_hat,1e7,1);
%wsamp = samp2distr(xsamp);


% Create random samples from all of the distributions
% ---------------------------------------------------
pdf_arr = [pdf_gauss,pdf_hat;pdf_tri,pdf_hh]';
pdf = pdf_table_array(pdf_arr);

nsamp = 1e7;
ind = floor(numel(pdf_arr)*rand(ceil(nsamp/10),10)) + 1;
xsamp = rand_ind(pdf,ind);

w1 = samp2distr(xsamp(ind==1));
w2 = samp2distr(xsamp(ind==2));
w3 = samp2distr(xsamp(ind==3));
w4 = samp2distr(xsamp(ind==4));

acolor('k'); dl(w_gauss); acolor('r'); ph(w1); keep_figure
acolor('k'); dl(w_hat);   acolor('r'); ph(w2); keep_figure
acolor('k'); dl(w_tri);   acolor('r'); ph(w3); keep_figure
acolor('k'); dl(w_hh);    acolor('r'); ph(w4); keep_figure


% Special case of a single table
% ------------------------------

pdf_single = pdf_table_array(pdf_hh);
xsamp = rand_ind(pdf_single, ones(1,nsamp));
w_single = samp2distr(xsamp);

acolor('k'); dl(w_hh);    acolor('r'); ph(w_single); keep_figure


