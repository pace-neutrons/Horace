function export_perf_to_csv_(perf_data_struc,filename,short_form)
% export performance data stored in performance structure into csv file for
% future analysis



comp_names = fieldnames(perf_data_struc);

% build full map of test names performed on every computer
test_names_map = containers.Map();
for i=1:numel(comp_names)
    cn = comp_names{i};
    if strcmpi(cn,'comment'); continue; end
    
    test_struc = perf_data_struc.(cn);
    if isempty(test_struc); continue; end
    test_names_map = build_test_names_map(test_names_map,test_struc);
end

fh = fopen(filename,'w');
if fh<1
    error('TEST_PERFORMANCE:runtime_error',...
        ' Can not open file %s for writing',filename);
end
clob = onCleanup(@()fclose(fh));
write_csv_header(fh,test_names_map);
write_header = true;
for i=1:numel(comp_names)
    computer_name = comp_names{i};
    if strcmpi(computer_name,'comment'); continue; end
    
    test_struc = perf_data_struc.(computer_name);
    if isempty(test_struc)
        write_empty_row(fh,computer_name,test_names_map);
        continue
    end
    
    [descr,exec_time,date,start_time,n_workers_list,info] = build_test_info(test_names_map,test_struc);
    
    if short_form
        write_exec_time(fh,computer_name,n_workers_list,exec_time);
    else
        if write_header 
            write_comment(fh,computer_name,descr);
            write_header = false;
        end
        write_start_date_time(fh,computer_name,'Test date:',date);
        write_start_date_time(fh,' -- | --','Test start:',start_time);        
        write_exec_time(fh,' -- | --',n_workers_list,exec_time);               
        %write_start_date_time(fh,'Start time:',start_time);
    end
    
end
function write_start_date_time(fh,computer_name,date_or_time,date_time)

fprintf(fh,'%s ,,, %s : ',computer_name,date_or_time);
for i=1:size(date_time,3)
    if isnan(date_time(1,i))
        fprintf(fh,',  : : : ');
    else
        fprintf(fh,', %d:%d:%2.0f ',date_time(1,i),date_time(2,i),date_time(3,i));
    end
end
fprintf(fh,'\n');

function  write_empty_row(fh,computer_name,test_names_map)

fprintf(fh,' %s :,, N_workers:, info: ',computer_name);
n_columns = test_names_map.length();
for i=1:n_columns 
    fprintf(fh,', ');
end
fprintf(fh,'\n');


function write_exec_time(fh,computer_name,n_workers_list,time_list)

n_work_cases = numel(n_workers_list);

for j=1:n_work_cases
    fprintf(fh,'%s,, %s :, ',computer_name,n_workers_list{j});
    for i=1:size(time_list,2)
        if isnan(time_list(j,i))
            fprintf(fh,' , ');
        else
            fprintf(fh,',%4.2f ',time_list(j,i));
        end
    end
    fprintf(fh,'\n');
    computer_name = ' -- | --';
end

function write_comment(fh,computer_name,description)

fprintf(fh,'%s , Description:,,',computer_name);
for i=1:numel(description)
    fprintf(fh,',%s ',description{i});
end
fprintf(fh,'\n');

function write_csv_header(fh,test_names_map)
test_names = test_names_map.keys();
position = test_names_map.values();
position = [position{:}];
headers = cell(1,numel(position));
for i=1:numel(position)
    hp = position(i);
    headers{hp} = test_names{i};
end

fprintf(fh,'Computer Name:,, N_workers:, info:');
for i=1:numel(headers)
    fprintf(fh,', %s:',headers{i});
end
fprintf(fh,'\n');


function [descr,exec_time,date,start_time,n_workers_list,info] = build_test_info(test_names_map,test_struc)
% extract test info from the test structure
all_these_tests = fieldnames(test_struc);
[this_test_names,c_workers,info] = cellfun(@parse_test_name,all_these_tests,'UniformOutput',false);

n_workers_map = build_key_map([],c_workers,true);

n_workers = n_workers_map.length();

%test  = test_names_map.keys();
n_tests_total = test_names_map.length();
n_these_tests = numel(this_test_names);

% define results
descr = cell(n_tests_total,1);
exec_time    = nan(n_workers,n_tests_total);

date  = nan(3,n_workers,n_tests_total);
start_time   = nan(3,n_workers,n_tests_total);

n_workers_list = cell(1,n_workers);
% -- fill in results
for i=1:n_these_tests
    full_test_name = all_these_tests{i};    
    [tn,c_wk] = parse_test_name(full_test_name);
    i_test = test_names_map(tn);
    j_wkr  = n_workers_map(c_wk);
    
    
    the_test = test_struc.(full_test_name);
    
    
    n_workers_list{j_wkr} = c_wk;
    % fill in ouptut arrays 
    descr{i_test} = the_test.comment;
    exec_time(j_wkr,i_test) = the_test.time_sec;
    time     = the_test.completed_on;    
    date(:,j_wkr,i_test) = time(1:3);
    start_time(:,j_wkr,i_test) = time(4:6);
end



function [test_name,c_workers,descr]  = parse_test_name(test_name)
names_cell = strsplit(test_name,'_nwk');
test_name = names_cell{1};
if numel(names_cell) == 1
    c_workers = test_name;
    descr = '';
else
    descr_cell = strsplit(names_cell{2},'_');
    c_workers = descr_cell{1};
    if numel(descr_cell) == 1
        descr = '-';
    else
        descr = descr_cell{end};
    end
end

function the_map = build_key_map(the_map,keywords,do_sort)

if isempty(the_map)
    the_map = containers.Map();
end

if do_sort
    keywords = sort(keywords);
end
n_existing  = the_map.length();
for i=1:numel(keywords)
    the_keyword = keywords{i};
    if ~the_map.isKey(the_keyword)
        n_existing = n_existing +1;
        the_map(the_keyword) = n_existing;
    end
end


function test_names_map = build_test_names_map(test_names_map,comp_tests)

test_names = fieldnames(comp_tests);
[test_names,~] = cellfun(@parse_test_name,test_names,'UniformOutput',false);


test_names_map = build_key_map(test_names_map,test_names,false);

