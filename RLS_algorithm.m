function [Error, t] = RLS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    lambda = variables(1) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    P = eye(filter_length) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    
    %% RLS algorithm
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        Error(i) = Expected_result(i) - X*H ;
        px = P*X' ;
        G = px * (lambda + X*px)^(-1) ;
        P = (P - G*X*P)/lambda ;
        H = H + Error(i) * G ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end