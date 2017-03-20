function [ tt ] = connection()
    % Simple wrapper for instantiating a connection to the TotalTide COM
    % API
    %
    % Usage:
    % tt = TotalTide.connection
    %
    % OUTPUT:
    %    An instance of COM.TotalTide_Application
    %
    % EXAMPLES:
    %
    %    tt   = TotalTide.connection;
    %    port = tt.StationByNumber('0345')
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %

    tt = actxserver('TotalTide.Application');
end

