function [Error, t] = Alg_1_algorithm(Input, Expected_result, ANC_start_sample, filter_length, lambda)
    %% Initialization
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    P = eye(filter_length) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    
    %% RLS_v2 algorithm
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        Error(i) = Expected_result(i) - X*H ;
        px = P*X' ;
        g = (1-lambda)/(lambda + (1-lambda)*X*px) ;
        P = (P - g*(px*px')) / lambda ; % Highlighted calculation of 
            % (px*px') to make sure that Matlab interprets the result as a 
            % perfectly symmetric matrix 
            % (removes asymmetry induced by rounding errors)
        H = H + Error(i) * g*px ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end