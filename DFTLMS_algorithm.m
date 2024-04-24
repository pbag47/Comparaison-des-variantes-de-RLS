function [Error, t] = DFTLMS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_Lambda = variables(1) ;
    theta_DFT = variables(2)  ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(filter_length, 1) ;
    H_DFT = zeros(filter_length, 1) ;
    Lambda_DFT = 10*eye(filter_length) ;

    DFT_matrix = 1/sqrt(filter_length) * dftmtx(filter_length) ;

    %% DFTLMS algorithm
    % DFT_matrix^-1 = transpose(conj(DFT_matrix))
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) ; X(1:filter_length-1)] ;
        X_DFT = DFT_matrix * X ;
        Lambda_DFT = diag(diag( (1-beta_Lambda) * X_DFT * transpose(conj(X_DFT)) + beta_Lambda * Lambda_DFT )) ;
        Error(i) = Expected_result(i) - real(transpose(H_DFT) * conj(X_DFT)) ;
        H_DFT = H_DFT + theta_DFT/filter_length * Error(i) * Lambda_DFT^(-1) * X_DFT ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm run-time : ', num2str(t), ' s'])
end