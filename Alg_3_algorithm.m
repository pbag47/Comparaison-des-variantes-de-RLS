function [Error, t] = Alg_3_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_R = variables(1) ;
    beta_E = variables(2) ;
    epsilon = 2 ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    w_E = 0 ;
    psi_E = 0 ;

    %% "Bias-corrected NLMS" algorithm
    % Correction of the bias induced by the recursive estimate of the
    % energy
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        psi_E = beta_E * psi_E + 1 ;
        w_E = filter_length * Input(i)^2 + beta_E * w_E ;
        E = w_E / psi_E ;
        Error(i) = Expected_result(i) - X*H ;
        H = H + (1-beta_R)*epsilon/E * Error(i) * X' ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end