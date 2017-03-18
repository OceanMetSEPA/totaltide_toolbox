function dataSeries = getSlackHeights(port, startDate, numDays)
    % This function builds a times-series of heigh and low water levels for 
    % the requested station across the requested time-period. This can be 
    % used to generate either historical or future water level variations.
    %
    % The output is a struct with 3 vectors describing the times, heights
    % and stages (high or low) of the water levels respectively.
    %
    % For a more general station height data record see
    % TotalTide.getHeights() which returns height records at a
    % specified time resolution (mins)
    %
    % Usage:
    % TotalTides.getSlackHeights(station, startDate, numDays) 
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
    % OUTPUT:
    %    A struct containing three data vectors
    %      - .time (datenum)
    %      - .height (double)
    %      - .highWater (boolean (i.e. 0/1))
    %
    % EXAMPLES:
    %
    %    tt   = TotalTide.connection;
    %    port = tt.StationByNumber('0345')
    %    tide = TotalTides.getSlackHeights(port,'16/05/2006',100)
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - TotalTide.connection.m
    %  - TotalTide.datenum.m
    
    if nargin==0
      help TotalTide.getSlackHeights
      return
    end
    
    dataSeries = struct;
    
    batchSize = 7; % number of days to retreive in each TotalTide query (max = 7)
    
    tt = TotalTide.connection;

    numberIterations  = ceil(numDays/batchSize);
    lastIterationDays = mod(numDays, batchSize);
    
    dataSeries.time      = [];
    dataSeries.height    = [];
    dataSeries.highWater = [];

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
        
        % Memoize the required event objects from TotalTide to prevent multiple 
        % calls being required
        events = port.TidalEvents(days);

        % Get the datetimes. Convert each to a valid MATLAB format
        % Use a cell array since these are strings
        %
        for t = 1:events.Count
            dataSeries.time(end+1) = TotalTide.datenum(events.Item(t).Time); 
        end    

        for t = 1:events.Count
            dataSeries.height(end+1) = events.Item(t).Height;
        end
        
        for t = 1:events.Count
            dataSeries.highWater(end+1) = events.Item(t).HighWater;
        end
    end
        
end

