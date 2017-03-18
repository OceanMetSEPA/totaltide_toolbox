function dataSeries = getHeights(port, startDate, numDays, interval)
    % This function builds a times-series of water levels for the requested
    % station across the requested time-period. This can be used to
    % generate either historical or future water level variations.
    %
    % The TotalTide API limits water height data retreival to time-periods
    % of 7 days, therefore any longer timeframes require multiple TotalTide
    % queries which can result a long computation time (e.g. 10 mins for 1
    % year of data at 20 min resolution).
    %
    % If only water level highs and lows are required, see the
    % TotalTide.getSlackHeights() function.
    %
    % Usage:
    % TotalTides.getHeights(station, startDate, numDays, interval) 
    %   where 
    %
    %     port is an instance of TotalTide::IPort. See http://www.chersoft.co.uk/totaltidesdk/reference/interface_total_tide_1_1_i_port.html
    %
    %     startDate is a string representing the date from which the water level 
    %     record is required (format should be 'dd/mm/yyyy' consistent with 
    %     TotalTide *PredictionTime*)
    %
    %     numDays is the number of days from the start date to be included
    %
    %     interval is the resolution of the data series in minutes
    %
    % OUTPUT:
    %    A struct containing two data vectors
    %      - .time
    %      - .height
    %
    % EXAMPLES:
    %
    %    tt   = TotalTide.connection;
    %    port = tt.StationByNumber('0345')
    %    tide = TotalTide.getHeights(port,'16/05/2006',100,20)
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - TotalTide.connection.m
    
    if nargin==0
      help TotalTide.getPortHeights
      return
    end
    
    dataSeries = struct;
    
    batchSize = 7; % number of days to retreive in each TotalTide query (max = 7)
    
    tt = TotalTide.connection;

    numberIterations  = ceil(numDays/batchSize);
    lastIterationDays = mod(numDays, batchSize);
    
    dataSeries.time   = [];
    dataSeries.height = [];
    
    for i = 1:numberIterations
        
        % Increment the start time according to the iteration number and
        % batch size
        tt.PredictionTime = datestr(addtodate(datenum(startDate, 'dd/mm/yyyy'), (i-1)*batchSize, 'day'), 'dd/mm/yyyy');
        
        % Number of days to retreive is always the declared batch size...
        days = batchSize;
        
        % ...or the remainder if on the final iteration
        if (lastIterationDays ~= 0) && (i == numberIterations)
            days = lastIterationDays;
        end
        
        heights = port.Heights(days,interval);
            
        % Get the datetimes. Convert each to a valid MATLAB format
        % Use a cell array since these are strings
        %
        for t = 1:heights.Count
            dataSeries.time(end+1) = TotalTide.datenum(heights.Item(t).Time); 
        end    

        for t = 1:heights.Count
            dataSeries.height(end+1) = heights.Item(t).Height;
        end
    end
    
    % Remove possible duplicate midnight records (TotalTide version 7)
    indices2Keep = [true,diff(dataSeries.time)>0]; % false if date of a record is same as previous i.e. is a duplicate
    % no duplicates 
    dataSeries.time = dataSeries.time(indices2Keep);
    dataSeries.height = dataSeries.height(indices2Keep);        
end

