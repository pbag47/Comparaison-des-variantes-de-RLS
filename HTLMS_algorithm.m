function [Error, t] = HTLMS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_Lambda = variables(1) ;
    theta_HT = variables(2)  ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(filter_length, 1) ;
    H_HT = zeros(filter_length, 1) ;
    Lambda_HT = 10*eye(filter_length) ;

    HT_matrix = 1/sqrt(filter_length) * hadamard(filter_length) ;

    %% HTLMS algorithm
    % HT_matrix^-1 = HT_matrix
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) ; X(1:filter_length-1)] ;
        X_HT = HT_matrix * X ;
        Lambda_HT = diag(diag((1-beta_Lambda) * X_HT * transpose(X_HT) + beta_Lambda * Lambda_HT)) ;
        Error(i) = Expected_result(i) - transpose(H_HT) * X_HT ;
        H_HT = H_HT + theta_HT/filter_length * Error(i) * Lambda_HT^(-1) * X_HT ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end