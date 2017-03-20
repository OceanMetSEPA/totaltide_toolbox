function plotHeights(data, portName)
    % Generates a plot of water height data based on a struct containing .time
    % and .height vectors. This function is intended to be used with the
    % TotalTide.getHeights() and TotalTide.getSlackHeights()
    % functions since they return the required data structures.
    %
    % Usage:
    % TotalTide.plotHeights(data, portName)
    %   where
    %     data is a struct containing .time and .height vectors
    %     name is a string describing the station name (optional)
    %
    % OUTPUT:
    %    Timeseries plot
    %
    % EXAMPLES:
    %
    %    port = TotalTide.closestPort(58.123456, -5132456)
    %    waterHeights = TotalTide.getHeights(port, '16/05/2006', 65, 20)
    %    TotalTide.plotHeights(waterHeights, port.Name)
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % This function uses the output from the functions 
    % TotalTide.getHeights() and TotalTide.getSlackHeights().
    %
    
    if nargin==0
      help TotalTide.plotHeights
      return
    end

    plot(data.time, data.height);
    xlabel('Date');
    ylabel('Water level (m above CD)');
    
    xpts = [linspace(data.time(1),data.time(end),5)];
    set(gca,'XTick',xpts,'XTickLabel',datestr(xpts, 'dd/mm/yy HH:MM'));
    
    if nargin < 2
      title('Unnamed station');
    else
      title(portName);
    end
    
    grid on
    
    % Make sure the y-axis starts at CD
    defaultYLimits = ylim;
    ylim([0,defaultYLimits(2)]);
end

