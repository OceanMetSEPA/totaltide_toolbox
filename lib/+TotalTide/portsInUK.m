function [ results ] = portsInUK()
    % Returns all of the "port" stations represented within TotalTide which
    % lie within the UK. 
    %
    % Usage:
    % TotalTide.portsInScotland()
    %
    % OUTPUT:
    %    An instance of TotalTide::IStations. See http://www.chersoft.co.uk/totaltidesdk/reference/interface_total_tide_1_1_i_stations.html
    %
    % EXAMPLES:
    %
    %    list = TotalTide.portsInScotland()
    %    portName = list.Item(1).Name     
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - TotalTide.connection.m

    ne = [61.312452,  2.2961426];
    sw = [48.297812, -7.3278809];
        
    results = TotalTide.portsInBounds(sw(2), sw(1), ne(2),  ne(1));
end

