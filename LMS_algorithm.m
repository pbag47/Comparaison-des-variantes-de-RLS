function [Error, t] = LMS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    mu = variables(1) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    
    %% LMS algorithm
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        Error(i) = Expected_result(i) - X*H ;
        H = H + mu * Error(i) * X' ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end