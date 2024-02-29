function [Error, t] = Alg_2_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_R = variables(1) ;
    beta_Lambda = variables(2) ;
    epsilon = 1/filter_length ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    H_transform = zeros(filter_length, 1) ;
    w_Lambda = eye(filter_length, filter_length) ;
    psi_Lambda = 0 ;

    %% Proposed DFTLMS algorithm, separated memory factors
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        X_transform = fft(X) / sqrt(filter_length) ;
        psi_Lambda = 1 + beta_Lambda * psi_Lambda ;
        w_Lambda = (1-beta_Lambda) * diag(diag(X_transform.*conj(X_transform))) + beta_Lambda*w_Lambda ;
        Lambda = w_Lambda/psi_Lambda ;
        Error(i) = Expected_result(i) - real(conj(X_transform) * H_transform) ;
        H_transform = H_transform + (1-beta_R)*epsilon/filter_length * Error(i) * Lambda^(-1) * transpose(X_transform) ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end