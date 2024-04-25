function [Expected_output] = get_expected_output(Input, Sh)
    % Desired signal calculation from the real filter (supposed unknown)
    Expected_output = zeros(length(Input), 1) ;
    Buffer = zeros(1, length(Sh)) ;
    for i = 1:length(Input)
        Buffer = [Input(i) Buffer(1:length(Buffer)-1)] ;
        Expected_output(i) = Buffer * Sh ;
    end
end

