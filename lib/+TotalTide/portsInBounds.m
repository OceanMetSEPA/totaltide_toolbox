function [ results ] = portsInBounds(swLon, swLat, neLon, neLat)
    % Returns all of the "port" stations represented within TotalTide which
    % lie within the bounding box specified.
    %
    % Usage:
    % TotalTide.portsInBounds(swLon, swLat neLon, neLat)
    %
    % OUTPUT:
    %    An instance of TotalTide::IStations. See http://www.chersoft.co.uk/totaltidesdk/reference/interface_total_tide_1_1_i_stations.html
    %
    % EXAMPLES:
    %
    %    list = TotalTide.portsInBounds(-1.0, 55.0, 1.0, 60.0)
    %    portName = list.Item(1).Name     
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - TotalTide.connection.m
    
    
    if nargin < 4
      help TotalTide.portsInBounds
      return
    end
    
    searchType = 0; % Ports only
    
    tt      = TotalTide.connection;
    results = tt.StationsInExtent(neLat, swLat, neLon, swLon, searchType);
end

