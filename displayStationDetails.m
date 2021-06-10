function displayStationDetails( station )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   displayStationDetails.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 12:23:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Simple function to display location and water level information
    % relating to a single TotalTide station.
    %
    % Usage:
    % TotalTide.displayStationDetails( station )
    %   where
    %     station is an instance of TotalTide::IPort
    
    if nargin==0
      help TotalTide.displayStationDetails
      return
    end


    disp(sprintf('\n'))
    disp(['Name: ', num2str(station.Name)])
    disp(['Number: ', station.Number])
    disp(['Latitude: ', num2str(station.Latitude)])
    disp(['Longitude: ', num2str(station.Longitude)])
    disp(['Country: ', station.Country])
    disp(['Station Type: ', station.StationType])
    disp(sprintf('\n'))
    
    disp('Water level benchmarks (m above CD)')
    disp('----------------------------------')
    disp(['Highest Astronomical Tide   ', num2str(station.HighestAstronomicalTide)])
    disp(['Highest High Water          ', num2str(station.HighestHighWater)])
    disp(['Lowest High Water           ', num2str(station.LowestHighWater)])
    disp(['Mean Sea Level              ', num2str(station.MeanSeaLevel)])
    disp(['Highest Low Water           ', num2str(station.HighestLowWater)])
    disp(['Lowest Low Water            ', num2str(station.LowestLowWater)])
    disp(['Lowest Astronomical Tide    ', num2str(station.LowestAstronomicalTide)])
    disp(sprintf('\n'))
    
end

