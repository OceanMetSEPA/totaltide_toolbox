function [ fullyQualifiedDateNum ] = datenum( totalTideDateTime )
    % Converts a TotalTide datetime string into a MATLAB datenum. 
    %
    % Since the TotalTide datetime format is non-standard, it has to be declared
    % in the datenum conversion. However, midnight times - which deviate
    % from the general format by missing the time component - need to be
    % handled explictly, hence the special logic for datenums from
    % TotalTide.
    %
    % Usage:
    % TotalTides.datenum(totalTideDateTime) 
    %   where totalTideDateTime is a datetime string in the format 
    %   'DD/MM/YYYY HH:MM:SS' (or 'DD/MM/YYYY' for midnight times).
    %
    % OUTPUT:
    %    A MATLAB datenum describing a datetime passed in
    %
    % EXAMPLES:
    %
    %    ttDate   = '10/12/2010';
    %    mtlbDateNum = TotalTide.datenum(ttDate)
    %        -> 734482
    %
    %
    %    ttDate   = '10/12/2010 12:10:56';
    %    mtlbDateNum = TotalTide.datenum(ttDate)
    %        -> 7.344825075925926e+05
    %
    % DEPENDENCIES:
    % 
    %    None
    %
    
    % Time format from TotalTide is
    %
    %  22/05/2006 23:40:00
    %
    % or, for midnight datetimes
    %
    %  23/05/2006
    %

    if nargin==0
      help TotalTide.datenum
      return
    end
    
    if length(totalTideDateTime) == 10;
        % Add some time padding if required
        totalTideDateTime = strcat(totalTideDateTime,' 00:00:00');
    end

    % Convert to datenum
    fullyQualifiedDateNum = datenum(totalTideDateTime,'dd/mm/yyyy HH:MM:SS');
end

