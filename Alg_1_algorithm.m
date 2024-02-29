function [Error, t] = Alg_1_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta_R = variables(1) ;
    beta_C = variables(2) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    w_R = eye(filter_length) ;
    w_C = zeros(filter_length, 1) ;
    psi_R = 0 ;
    psi_C = 0 ;
    
    %% Algorithm 1 : Straightforward estimation of the Wiener filter
    % Very slow algorithm because of the inversion of R
    % Similar performance with the RLS in terms of convergence and
    % residuals
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        Error(i) = Expected_result(i) - X*H ;
        
        % Recursive estimation of the autocorrelation matrix
        w_R = transpose(X) * X + beta_R*w_R ; 
        psi_R = 1 + beta_R*psi_R ;
        R = 1/psi_R * w_R ;
        
        % Recursive estimation of the cross-correlation vector
        w_C = Expected_result(i) * transpose(X) + beta_C*w_C ;
        psi_C = 1 + beta_C*psi_C ;
        C = 1/psi_C * w_C ;
        
        H = R^-1 * C ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end