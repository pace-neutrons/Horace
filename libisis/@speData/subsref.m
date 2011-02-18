function varargout = subsref(this,index)
% accessor to the internal data of the speData class
%
% $Revision$ ($Date$)
%
%
switch index(1).type
    case '.'
        switch index(1).subs
            case 'nDetectors'
                varargout={this.nDetectors};
            case 'nEnergyBins'
                varargout={this.nEnergyBins};
            case 'fileDir'
                varargout={this.fileDir};
            case 'fileName'
                varargout={[this.fileName this.fileExt]};
            case 'en'
                varargout={this.en};
            case 'S'
                if(~this.data_loaded)                
                    this=loadSPEdata(this);                   
                end
                varargout={this.S};                
            case 'ERR'
                if(~this.data_loaded)
                    this=loadSPEdata(this);                                      
                end
                varargout={this.ERR};      
			case 'Ei'
				if isfield(this,'Ei')
    				varargout = this.Ei;
                else
        			varargout = NaN;
                end
            otherwise
                error('speData:Indexing_Error',...
                ['index refers to nonexisitng field or a privat variable'
                 index(1).subs] );
        end
    case '()'
        this_subset = this(index(1).subs{:});
        if length(index) == 1
            varargout = {this_subset};
        else
            % trick subsref into returning more than 1 ans
            varargout = cell(size(this_subset));
            [varargout{:}] = subsref(this_subset, index(2:end));
        end

    case '{}'
        error(['??? ' class(this) ' object, is not a cell array']);
        
    otherwise
        error('speData:Indexing_Error',['unsupported index type'
                 index(1).type ' for this class'] );
end
    
  if length(varargout)>1 && nargout <=1
      if (iscellstr(vavargout) || any([cellfun('isempty',varargout)]))
          varargout={varargout};
      else
          try
              varargout={[varargout{:}]};
          catch
              varargout={varargout};
          end
      end
  end
end