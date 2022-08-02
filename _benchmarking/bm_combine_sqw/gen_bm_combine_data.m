<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
function [cut1, cutN] = gen_bm_combine_data(nDims,dataFile,dataSize,dataSet)

pths = horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch dataSize
  case 'small'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(6);
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(7);
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(8);
          dataSource = fullfile(pths.bm_common,'NumData8.sqw');
      end
    otherwise
        try
            gen_fake_sqw_data(dataSize)
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
end
=======
function [cut1, cutN] = gen_bm_combine_data(nDims,dataType, dataNum)
common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
    )),'common_data');
=======
function [cut1, cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum)
<<<<<<< HEAD
% common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
%     )),'common_data');
<<<<<<< HEAD
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr'; 
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
=======

% pths = horace_paths;
% common_data = pths.bm_common;
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
function [cut1, cutN] = gen_bm_combine_data(nDims,dataSource, dataSize,dataSet)

pths = horace_paths;
common_data = pths.bm_common;
>>>>>>> 8d4db5de5 (updating gen_data functions)
=======
function [cut1, cutN] = gen_bm_combine_data(nDims,dataFile,dataSize,dataSet)

pths = horace_paths;
>>>>>>> 968c751e0 (using horace_paths and updating variable names)
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
>>>>>>> 810106e8b (Replace fake_sqw|spe with dummy throughout)

switch dataSize
  case 'small'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(6);
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(7);
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(8);
          dataSource = fullfile(pths.bm_common,'NumData8.sqw');
      end
    otherwise
        try
            gen_fake_sqw_data(dataSize)
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
    otherwise
        error("HORACE:test_combine_sqw_smallData:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts to combine: must be 1 or 2 ")
end

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);

switch dataSet
    case 'small'
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cut1.data.pix.signal;
    case 'medium'
        cut2 = cut1;
        cut2.data.pix.signal = 2*cut1.data.pix.signal;
        cutN=repmat(cut2,1,3);
    case 'large'
        cut2 = cut1;
        cut2.data.pix.signal = 2*cut1.data.pix.signal;
        cutN=repmat(cut2,1,7);
    otherwise
        try
            cut2 = cut1;
            cut2.data.pix.signal = 2*cut1.data.pix.signal;
            cutN=repmat(cut2,1,dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end
end
=======
switch dataType
    case "small"
        dataSource = fullfile(common_data,'ironSmall.sqw');
        %dummy_sqw()
    case "medium"
        dataSource = fullfile(common_data,'ironMedium.sqw');
        %dummy_sqw()
    case "large"
        dataSource = fullfile(common_data,'ironLarge.sqw');
        %dummy_sqw()
    otherwise
        warning("HORACE:gen_combine_bm_data:invalid_argument",...
            "datatype must be either a string (small, medium or large), or an integer")
end

=======
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
switch true
    case nDims==1 && dataType=="small" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==1 && dataType=="small" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="small" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="medium" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==1 && dataType=="medium" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="medium" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="large" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==1 && dataType=="large" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="large" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

     case nDims==2 && dataType=="small" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==2 && dataType=="small" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==2 && dataType=="small" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end
=======
cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
>>>>>>> 8d4db5de5 (updating gen_data functions)

switch dataSet
    case 'small'
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cut1.data.pix.signal;
    case 'medium'
        cut2 = cut1;
        cut2.data.pix.signal = 2*cut1.data.pix.signal;
        cutN=repmat(cut2,1,3);
    case 'large'
        cut2 = cut1;
        cut2.data.pix.signal = 2*cut1.data.pix.signal;
        cutN=repmat(cut2,1,7);
    otherwise
        try
            cut2 = cut1;
            cut2.data.pix.signal = 2*cut1.data.pix.signal;
            cutN=repmat(cut2,1,dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end
end
<<<<<<< HEAD

>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
>>>>>>> 810106e8b (Replace fake_sqw|spe with dummy throughout)
