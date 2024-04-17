function [Error, t] = ARLS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_R = variables(1) ;
    theta = variables(2) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    R = 10*eye(filter_length) ;
    X = zeros(filter_length, 1) ;
    H = zeros(filter_length, 1) ;
    
    %% ARLS algorithm
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) ; X(1:filter_length-1)] ;
        R = diag(diag((1-beta_R) * X * transpose(X) + beta_R * R)) ;
        Error(i) = Expected_result(i) - transpose(X)*H ;
        H = H + theta/filter_length * Error(i) * R^-1 * X ;

        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end