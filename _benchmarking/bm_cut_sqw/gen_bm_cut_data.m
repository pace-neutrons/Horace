function dataSource = gen_bm_cut_data(dataFile,dataSize)
% Generate sqw object or select exisiting sqw file for benchmarking cut_sqw
% If input parameter is a string represnting an existing sqw file then this
% will be selected, otherswise if the input is an integer, dummy_sqw will be
% used to generate an sqw object of the requested size/number of pixels
    
pths=horace_paths;

switch dataSize
  case 'small'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(6);
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(7);
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(8);
          dataSource = fullfile(pths.bm_common,'NumData8.sqw');
      end
    otherwise
        try
            gen_fake_sqw_data(dataSize);
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
end

end

