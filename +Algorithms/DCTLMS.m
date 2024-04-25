function [Error, t] = DCTLMS(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_Lambda = variables(1) ;
    theta_DCT = variables(2)  ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(filter_length, 1) ;
    H_DCT = zeros(filter_length, 1) ;
    Lambda_DCT = 10*eye(filter_length) ;

    DCT_matrix = dctmtx(filter_length) ;

    %% DCTLMS algorithm
    % DCT_matrix^-1 = transpose(DCT_matrix)
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) ; X(1:filter_length-1)] ;
        X_DCT = DCT_matrix * X ;
        Lambda_DCT = diag(diag( (1-beta_Lambda) * X_DCT * transpose(X_DCT) + beta_Lambda * Lambda_DCT )) ;
        Error(i) = Expected_result(i) - transpose(H_DCT) * X_DCT ;
        H_DCT = H_DCT + theta_DCT/filter_length * Error(i) * Lambda_DCT^(-1) * X_DCT ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm run-time : ', num2str(t), ' s'])
end