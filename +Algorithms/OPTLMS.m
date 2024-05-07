function [Error, t] = OPTLMS(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    beta = variables(1) ;
    theta_OPT = variables(2)  ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(filter_length, 1) ;
    H_OPT = zeros(filter_length, 1) ;
    Lambda_OPT = 10*eye(filter_length) ;
    
    load('Noise_samples.mat', 'eigenelements')

    inv_OPT_matrix = eigenelements.White_noise.eigenvectors ;
    % inv_OPT_matrix = eigenelements.Pink_noise.eigenvectors ;
    % inv_OPT_matrix = eigenelements.Brownian_noise.eigenvectors ;
    % inv_OPT_matrix = eigenelements.Tonal_input.eigenvectors ;
    % inv_OPT_matrix = eigenelements.UAV_noise.eigenvectors ;
    % inv_OPT_matrix = eigenelements.test.eigenvectors ;
    
    % The optimal basis is defined as the left eigenvectors set in
    % rows, which is the inverse of the (right) eigenvectors matrix 
    % returned by the 'eig()' function in Matlab.
    OPT_matrix = inv_OPT_matrix^-1 ;

    %% OPTLMS algorithm
    % TDLMS that uses the estimated eigenvectors of the input signal
    % autocorrelation matrix.
    % Make sure to load the correct projection matrix according to the
    % input signal.
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) ; X(1:filter_length-1)] ;
        Lambda_OPT = diag(diag( (1-beta) * OPT_matrix * X * transpose(X) * OPT_matrix^-1 + beta * Lambda_OPT )) ;
        Error(i) = Expected_result(i) - transpose(H_OPT) * transpose(OPT_matrix^-1) * X ;
        H_OPT = H_OPT + theta_OPT/filter_length * Error(i) * Lambda_OPT^(-1) * OPT_matrix * X ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm run-time : ', num2str(t), ' s'])
end